global class DirectDebitBankFilegen extends loan.FileGenerator {
    
    //BankFileUtil is the utility class to handle all generic operation related to a bank file.
    BankFileUtil bfu = new BankFileUtil();

    //Below are required global parameters for bank file generation
    loan__Automated_Payment_Configuration__c apc;
    Integer countOfRecords = 0;
    Decimal creditAmount = 0;
    Decimal debitAmount = 0;
    Map<Id, loan__Bank_Account__c> mapCustomerBankAccounts;

    /***
     * getEntries This is an overriden method which is called from FileGenerator class which passes scope of batch job
     * @param  state internal package code variable
     * @param  scope Actual scope from batch job is passed
     * @return       return List of record lines items
     */
    public override List<String> getEntries(loan.TransactionSweepToACHState state, List<SObject> scope) { 
        try{
            Map<Id, SObject> mapReturnObject = requeryScope(scope);   
            
            Decimal totalSumOfAmount = 0;
            Integer recordCount = 0;

            if(mapCustomerBankAccounts == null){
                throw new CommonUtility.CustomException('[DirectDebitBankFilegen.getEntries] Bank Accounts missing for LPTs');
            }

            List<BankFileUtil.LineItemInfo> listSObjValidScope = new List<BankFileUtil.LineItemInfo>();
            for (SObject sObj : scope) {
                //Start - Code which needs to be changed for specific bank file
                loan__Loan_Payment_Transaction__c lptObj = (loan__Loan_Payment_Transaction__c) sObj;
                loan__Loan_Payment_Transaction__c lpt = (loan__Loan_Payment_Transaction__c) mapReturnObject.get(lptObj.id);

                if(lpt != null){
                    loan__Bank_Account__c custBankAcc = mapCustomerBankAccounts.get(lpt.loan__Loan_Account__r.loan__Account__c);

                    if(custBankAcc == null){
                        addToInvalidScope(lpt, 'Bank Account not present for:' + lpt.name);
                        continue;
                    }
                    else if(!bfu.isBankAccountValid(custBankAcc)){
                        addToInvalidScope(lpt, 'Invalid bank account details for:' + lpt.name);
                        continue;
                    }
                    else if(lpt.loan__Transaction_Amount__c <= 0){
                        addToInvalidScope(lpt, 'Transaction amount not correct for:' + lpt.name);
                        continue;
                    }

                    totalSumOfAmount += lpt.loan__Transaction_Amount__c;
                    recordCount++;
                    addToValidScope(sObj);

                    BankFileUtil.LineItemInfo lineItem = new BankFileUtil.LineItemInfo();
                    lineItem.bsbNumber = custBankAcc.BSB__c;
                    lineItem.bankAccountNumber = custBankAcc.loan__Bank_Account_Number__c;
                    lineItem.titleOfAccount = custBankAcc.Account_Holder_Name__c;
                    lineItem.txnAmount = lpt.loan__Transaction_Amount__c;
                    lineItem.nameOfEntity = lpt.loan__Loan_Account__r.CRN_Number__c;

                    listSObjValidScope.add(lineItem);
                }
                //End - Code which needs to be changed for specific bank file
            }

            countOfRecords = recordCount;
            debitAmount = totalSumOfAmount;
            creditAmount = totalSumOfAmount;
            
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
    private Map<Id, SObject> requeryScope(List<SObject> scope) {
        try{
            Set<Id> setSObjectIds = new Set<Id>();
            Map<Id, SObject> returnObject = new Map<Id, SObject>();
            String paymentMode = '';
            
            //Start - Code which needs to be changed for specific bank file
            for (loan__Loan_Payment_Transaction__c lpt : (List<loan__Loan_Payment_Transaction__c>) scope) {
                setSObjectIds.add(lpt.Id);
            }

            Set<Id> setCustomerIds = new Set<Id>();
            for (loan__Loan_Payment_Transaction__c lpt : [SELECT Id,
                                                                 Name,
                                                                 loan__Payment_Mode__c,
                                                                 loan__Transaction_Amount__c,
                                                                 loan__Loan_Account__r.name,
                                                                 loan__Loan_Account__r.loan__Account__c,
                                                                 loan__Loan_Account__r.CRN_Number__c
                                                            FROM loan__Loan_Payment_Transaction__c 
                                                           WHERE id IN :setSObjectIds
                                                             AND loan__Cleared__c = true
                                                             AND loan__Reversed__c = false
                                                             AND loan__Rejected__c = false
                                                        ]) {
                paymentMode = lpt.loan__Payment_Mode__c;
                setCustomerIds.add(lpt.loan__Loan_Account__r.loan__Account__c);
                returnObject.put(lpt.id, lpt);
            }    

            mapCustomerBankAccounts = bfu.getCustomerBankAccounts(setCustomerIds);
            apc = bfu.getAPCData(loan.LoanConstants.LOAN_PAYMENT, paymentMode);
            //End - Code which needs to be changed for specific bank file
            
            return returnObject;                       
        }
        catch(Exception e) {
            throw new CommonUtility.CustomException('[DirectDebitBankFilegen.requeryScope] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }       
    }

    /***
     * getSimpleFileName Generic method that returns inital prefix of the file name
     * @return   return Prefix of filename
     */
    public override String getSimpleFileName() {
        try{
            return (String.isBlank(apc.Filename_Prefix__c) ? 'DefaultNameDirectDebit' : apc.Filename_Prefix__c);
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