global class DirectCreditBankFilegen extends loan.FileGenerator {
    
    //BankFileUtil is the utility class to handle all generic operation related to a bank file.
    BankFileUtil bfu = new BankFileUtil();

    //Below are required global parameters for bank file generation
    loan__Automated_Payment_Configuration__c apc;
    Integer countOfRecords = 0;
    Decimal creditAmount = 0;
    Decimal debitAmount = 0;

    /***
     * getEntries This is an overriden method which is called from FileGenerator class which passes scope of batch job
     * @param  state internal package code variable
     * @param  scope Actual scope from batch job is passed
     * @return       return List of record lines items
     */
    public override List<String> getEntries(loan.TransactionSweepToACHState state, List<SObject> scope) { 
        try{
            Map<Id, List<SObject>> mapReturnObject = requeryScope(scope);   
            
            Decimal totalSumOfAmount = 0;
            Integer recordCount = 0;

            List<BankFileUtil.LineItemInfo> listSObjValidScope = new List<BankFileUtil.LineItemInfo>();
            for (SObject sObj : scope) {
                //Start - Code which needs to be changed for specific bank file
                loan__Loan_Disbursal_Transaction__c ldt = (loan__Loan_Disbursal_Transaction__c) sObj;
                List<SObject> sObjMapValue = mapReturnObject.get(ldt.id);
                List<loan__Disbursal_Txn_Distribution__c> dtdList = (List<loan__Disbursal_Txn_Distribution__c>) sObjMapValue;

                Boolean isValid = true;
                Decimal tempTotalSum = 0;
                Integer tempNumberOfRec = 0;

                List<BankFileUtil.LineItemInfo> tempListLII = new List<BankFileUtil.LineItemInfo>();
                for(loan__Disbursal_Txn_Distribution__c dtd : dtdList){
                    if(dtd.loan__Bank_Account__c == null){
                        addToInvalidScope(ldt, 'Bank Account not present for:' + dtd.name);
                        isValid = false;
                        break;
                    }
                    else if(!bfu.isBankAccountValid(dtd)){
                        addToInvalidScope(ldt, 'Invalid bank account details for:' + dtd.name);
                        isValid = false;
                        break;
                    }
                    else if(dtd.loan__Distribution_Amount__c <= 0){
                        addToInvalidScope(ldt, 'Distribution amount not correct for:' + dtd.name);
                        isValid = false;
                        break;
                    }
                    tempTotalSum += dtd.loan__Distribution_Amount__c;
                    tempNumberOfRec++;

                    BankFileUtil.LineItemInfo lineItem = new BankFileUtil.LineItemInfo();
                    lineItem.bsbNumber = dtd.loan__Bank_Account__r.BSB__c;
                    lineItem.bankAccountNumber = dtd.loan__Bank_Account__r.loan__Bank_Account_Number__c;
                    lineItem.titleOfAccount = dtd.loan__Bank_Account__r.Account_Holder_Name__c;
                    lineItem.txnAmount = dtd.loan__Distribution_Amount__c;
                    lineItem.nameOfEntity = dtd.loan__Reference__c;

                    tempListLII.add(lineItem);
                }

                if(isValid){
                    listSObjValidScope.addAll(tempListLII);
                    addToValidScope(sObj);
                    totalSumOfAmount += tempTotalSum;
                    recordCount += tempNumberOfRec;
                }
                //End - Code which needs to be changed for specific bank file
            }

            countOfRecords = recordCount;
            creditAmount = totalSumOfAmount;
            debitAmount = totalSumOfAmount;
            
            List<String> listLineItems = bfu.getLineRecords(listSObjValidScope, apc);
            for (String lineItem : listLineItems) {
                lineItem = lineItem + '\r\n';
                addEntry(lineItem);
            }
            
            return listLineItems;
        }
        catch(Exception e){
            bfu.logException(e, 'EXCEPTION');
            return null;
        }
    }
    
    /***
     * requeryScope Requeries the data basis the scope passed
     * @param  scope Actual scope passed from the batch job
     * @return       return Map of scope object id and value as related information
     */
    private Map<Id, List<SObject>> requeryScope(List<SObject> scope) {
        try{
            Set<Id> setSObjectIds = new Set<Id>();
            for (loan__Loan_Disbursal_Transaction__c ldt : (List<loan__Loan_Disbursal_Transaction__c>) scope) {
                setSObjectIds.add(ldt.Id);
            }
            Map<Id, List<SObject>> returnObject = new Map<Id, List<SObject>>();
            String paymentMode = '';

            //Start - Code which needs to be changed for specific bank file
            for (loan__Disbursal_Txn_Distribution__c dtd : [SELECT Id,
                                                                   Name,
                                                                   loan__Loan_Disbursal_Transaction__c,
                                                                   loan__Distribution_Amount__c,
                                                                   loan__Distribution_Type__c,
                                                                   loan__Reference__c,
                                                                   loan__Name_of_Entity__c,
                                                                   loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Account__c,
                                                                   loan__Loan_Disbursal_Transaction__r.loan__Mode_of_Payment__c,
                                                                   loan__Bank_Account__c,
                                                                   loan__Bank_Account__r.BSB__c,
                                                                   loan__Bank_Account__r.Account_Holder_Name__c,
                                                                   loan__Bank_Account__r.loan__Bank_Account_Number__c
                                                              FROM loan__Disbursal_Txn_Distribution__c 
                                                             WHERE loan__Loan_Disbursal_Transaction__c IN :setSObjectIds
                                                               AND loan__Sent_To_ACH__c = false
                                                           ]) {
                paymentMode = dtd.loan__Loan_Disbursal_Transaction__r.loan__Mode_of_Payment__c; 
                List<loan__Disbursal_Txn_Distribution__c> listDTD;
                if(returnObject.containsKey(dtd.loan__Loan_Disbursal_Transaction__c)){
                    listDTD = (List<loan__Disbursal_Txn_Distribution__c>) returnObject.get(dtd.loan__Loan_Disbursal_Transaction__c);
                    listDTD.add(dtd);
                }
                else{
                    listDTD = new List<loan__Disbursal_Txn_Distribution__c>{dtd};
                }

                returnObject.put(dtd.loan__Loan_Disbursal_Transaction__c, listDTD);
            }   
            
            apc = bfu.getAPCData(loan.LoanConstants.LOAN_DISBURSAL, paymentMode);
            //End - Code which needs to be changed for specific bank file
            
            return returnObject;                       
        }
        catch(Exception e) {
            throw new CommonUtility.CustomException('[DirectCreditBankFilegen.requeryScope] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }       
    }

    /***
     * getSimpleFileName Generic method that returns inital prefix of the file name
     * @return   return Prefix of filename
     */
    public override String getSimpleFileName() {
        try{
            return (String.isBlank(apc.Filename_Prefix__c) ? 'DefaultNameDirectCredit' : apc.Filename_Prefix__c);
        }
        catch(Exception e){
            bfu.logException(e, 'EXCEPTION');
            return null;
        } 
    }
    
    /***
     * getHeader Generic method returns header record for the file
     * @param  state state description
     * @param  scope scope description
     * @return       return Returns header record for the file.
     */
    public override String getHeader(loan.TransactionSweepToACHState state, List<SObject> scope) {
        try{
            List<SObject> lineRecords = getValidScope();
            
            state.o1 = apc;
            Map<String, Integer> countMap = (Map<String, Integer>) state.o2;
            if(countMap.get(String.valueOf(apc.loan__Payment_Mode__r.name)) == null){
                countMap.put(apc.loan__Payment_Mode__r.name, 0);
                state.o2 = countMap;
            }
            
            if(lineRecords.size() > 0){
                return bfu.getHeaderRecord(apc);
            }
            return null;
        }
        catch(Exception e){
            bfu.logException(e, 'EXCEPTION');
            return null;
        }
    }
    
    /***
     * getTrailer Generic method returns trailer record for the file
     * @param  state state description
     * @param  scope scope description
     * @return       return Returns trailer record for the file.
     */
    public override String getTrailer(loan.TransactionSweepToACHState state, List<SObject> scope) { 
        try{
            List<SObject> lineRecords = getValidScope();
            
            if(lineRecords.size() > 0){
                return bfu.getTrailerRecord(creditAmount, debitAmount, countOfRecords, apc);
            }
            return null;
        }
        catch(Exception e){
            bfu.logException(e, 'EXCEPTION');
            return null;
        }
    }
}