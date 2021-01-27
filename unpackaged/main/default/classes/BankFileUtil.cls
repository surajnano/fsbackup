public class BankFileUtil {

    /***
     * getAPCData Returns single record for automated payment configuration
     * @param  eventName   Name of event
     * @param  paymentMode paymentMode 
     * @return             return single record of automated payment configuration
     */
    public loan__Automated_Payment_Configuration__c getAPCData(String eventName, String paymentMode){
        try{
            mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
            mfiflexUtil.ObjectCache sObjOC = ec.getObject('Automated-Payment-Config');
            
            if(sObjOC != null){
                ec.deleteObject('Automated-Payment-Config');
            }

            mfiflexUtil.ObjectCache apcCache = ec.createObject('Automated-Payment-Config', 'loan__Automated_Payment_Configuration__c', '');
            String whereClause = '';
                
            SObjectType apcObj = Schema.getGlobalDescribe().get('loan__Automated_Payment_Configuration__c');
            Map<String,Schema.SObjectField> mfields = apcObj.getDescribe().fields.getMap();
            for(String field : mfields.keyset()){
                if(field.endsWith('__c')){
                    apcCache.addFields(field);
                }            
            }

            apcCache.addFields('loan__Payment_Mode__r.Name');
            apcCache.addFields('loan__Bank_Account__r.BSB__c');
            apcCache.addFields('loan__Bank_Account__r.loan__Bank_Account_Number__c');
            apcCache.addFields('loan__Bank_Account__r.Account_Holder_Name__c');
            
            apcCache.addNamedParameter('eventName', eventName);
            apcCache.addNamedParameter('paymentMode', paymentMode);

            whereClause = 'loan__Event__c = :eventName AND loan__Active__c = true AND loan__Payment_Mode__c = :paymentMode'; 

            apcCache.setWhereClause(whereClause);
            apcCache.buildQuery();
                
            return (loan__Automated_Payment_Configuration__c) apcCache.executeQuery().getRecords().get(0);   
        }
        catch(Exception e){
			throw new CommonUtility.CustomException('[BankFileUtil.getAPCData] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }
    }

    /***
     * getCustomerBankAccounts Gets the active bank accounts for the accounts passed
     * @param  customerAccIds customer account ids
     * @return                Returns map of borrower account id to corresponding bank account
     */
    public Map<Id, loan__Bank_Account__c> getCustomerBankAccounts(Set<Id> customerAccIds){
        try{
            List<loan__Bank_Account__c> customBankAccounts = [SELECT id,
                                                                     Name,
                                                                     BSB__c,
                                                                     Account_Holder_Name__c,
                                                                     loan__Bank_Account_Number__c,
                                                                     loan__Account__c
                                                                FROM loan__Bank_Account__c
                                                               WHERE loan__Active__c = true
                                                                 AND loan__Account__c IN :customerAccIds
                                                             ];

            Map<Id, loan__Bank_Account__c> mapCustomerBankAccts = new Map<Id, loan__Bank_Account__c>();
            for(loan__Bank_Account__c bankAcc : customBankAccounts){
                mapCustomerBankAccts.put(bankAcc.loan__Account__c, bankAcc);
            }

            return mapCustomerBankAccts;
        }
        catch(Exception e){
			throw new CommonUtility.CustomException('[BankFileUtil.getCustomerBankAccounts] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }
    }

    /***
     * getHeaderRecord Forms the header part of the file
     * @param  apcRecord apcRecord description
     * @return           Return string header
     */
    public String getHeaderRecord(loan__Automated_Payment_Configuration__c apcRecord){
        try{
            ABA_File_Header__c abaFileHeader = new ABA_File_Header__c();
            abaFileHeader.Name_of_Financial_Institution__c = apcRecord.Name_of_Financial_Institution__c;
            abaFileHeader.Name_of_user_supplying_file__c = apcRecord.Name_of_user_supplying_file__c;
            abaFileHeader.Number_of_user_supplying_file__c = apcRecord.Number_of_user_supplying_file__c;
            abaFileHeader.Description_of_entries__c = apcRecord.Description_of_entries__c;
            abaFileHeader.Processing_Date__c = CommonUtility.getDateValue(null, 'DDMMYY');
           
            List<SObject> headerRecs = new List<SObject>();
            headerRecs.add(abaFileHeader);
            
            filegen.CreateSegments headerSegments = new filegen.CreateSegments(headerRecs);
            List<String> headerStrings = headerSegments.retString();
            String finalHeader = '';
            for(String header : headerStrings){
                finalHeader += header + '\r\n';
            }
            
            return finalHeader;
        }
        catch(Exception e){
			throw new CommonUtility.CustomException('[BankFileUtil.getHeaderRecord] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }
    }
    
    /***
     * getLineRecords Generates line records of the file
     * @return   Return list of line records
     */
    public List<String> getLineRecords(List<LineItemInfo> listLineRecords, loan__Automated_Payment_Configuration__c apcRecord){
        try{
            List<SObject> lineRecords = new List<SObject>();
            for(LineItemInfo lineItem : listLineRecords){
                ABA_File_Details_Record__c abaFileDetailsRecord = new ABA_File_Details_Record__c();

                abaFileDetailsRecord.BSB_Number__c = lineItem.bsbNumber;
                abaFileDetailsRecord.Account_Number__c = lineItem.bankAccountNumber;
                abaFileDetailsRecord.Title_of_Account__c = lineItem.titleOfAccount;
                abaFileDetailsRecord.Amount__c = lineItem.txnAmount;
                abaFileDetailsRecord.Lodgement_Reference__c = lineItem.nameOfEntity;
                
                abaFileDetailsRecord.Indicator__c = apcRecord.Indicator__c;
                abaFileDetailsRecord.Transaction_Code__c = apcRecord.Transaction_Code__c;
                abaFileDetailsRecord.Trace_record_bsb_number__c = apcRecord.loan__Bank_Account__r.BSB__c;
                abaFileDetailsRecord.Trace_record_account_number__c = apcRecord.loan__Bank_Account__r.loan__Bank_Account_Number__c;
                abaFileDetailsRecord.Name_of_Remitter__c = apcRecord.loan__Bank_Account__r.Account_Holder_Name__c;
            
                lineRecords.add(abaFileDetailsRecord);
            }

            filegen.CreateSegments lineSegments = new filegen.CreateSegments(lineRecords);
            List<String> listLineItems = lineSegments.retString();
            return listLineItems;
        }
        catch(Exception e){
			throw new CommonUtility.CustomException('[BankFileUtil.getLineRecord] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }
    }

    /***
     * getTrailerRecord Generates trailer record of the file
     * @param  creditAmount   creditAmount description
     * @param  debitAmount    debitAmount description
     * @param  countOfRecords countOfRecords description
     * @param  apcRecord      automated payment config record
     * @return                Returns string of trailer record
     */
    public String getTrailerRecord(Decimal creditAmount, Decimal debitAmount, Integer countOfRecords, loan__Automated_Payment_Configuration__c apcRecord){
        try{
            List<SObject> trailerRecs = new List<SObject>();
            
            if(apcRecord.Is_Debalancing_Record_Required__c){
                ABA_File_Details_Record__c abaFileDetailsRecord = new ABA_File_Details_Record__c();

                abaFileDetailsRecord.BSB_Number__c = apcRecord.loan__Bank_Account__r.BSB__c;
                abaFileDetailsRecord.Account_Number__c = apcRecord.loan__Bank_Account__r.loan__Bank_Account_Number__c;
                abaFileDetailsRecord.Title_of_Account__c = apcRecord.loan__Bank_Account__r.Account_Holder_Name__c;
                abaFileDetailsRecord.Amount__c = creditAmount;
                abaFileDetailsRecord.Lodgement_Reference__c = System.label.ABA_FILE_DEBAL_REFERENCE;
                abaFileDetailsRecord.Indicator__c = apcRecord.Indicator__c;
                abaFileDetailsRecord.Transaction_Code__c = apcRecord.Transaction_Code_Debalancing__c;
                abaFileDetailsRecord.Trace_record_bsb_number__c = apcRecord.loan__Bank_Account__r.BSB__c;
                abaFileDetailsRecord.Trace_record_account_number__c = apcRecord.loan__Bank_Account__r.loan__Bank_Account_Number__c;
                abaFileDetailsRecord.Name_of_Remitter__c = apcRecord.loan__Bank_Account__r.Account_Holder_Name__c;
                trailerRecs.add(abaFileDetailsRecord);

                countOfRecords++;
            }

            ABA_File_Trailer__c abaFileTrailer = new ABA_File_Trailer__c();
            abaFileTrailer.Credit_Total_Amount__c = creditAmount == null ? 0 : creditAmount;
            abaFileTrailer.Debit_Total_Amount__c = debitAmount == null ? 0 : debitAmount;
            abaFileTrailer.Net_Total_Amount__c = Math.abs(abaFileTrailer.Credit_Total_Amount__c - abaFileTrailer.Debit_Total_Amount__c);
            abaFileTrailer.Count_of_Records__c = countOfRecords;
            
            trailerRecs.add(abaFileTrailer);
            
            filegen.CreateSegments trailerSegments = new filegen.CreateSegments(trailerRecs);
            List<String> trailerStrings = trailerSegments.retString();
            String finalTrailer = '';
            for(String trailer : trailerStrings){
                finalTrailer += trailer + '\r\n';
            }
            
            return finalTrailer;
        }
        catch(Exception e){
			throw new CommonUtility.CustomException('[BankFileUtil.getTrailerRecord] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }
    }

    /**
     * logException Logs exception related to file generation in batch process log table
     * @param  e    e description
     * @param  type EXCEPTION needs to be passed
     */
    public void logException(Exception e, String type){
        try{
            filegen__Batch_Process_log__c log = new filegen__Batch_Process_Log__c();
            log.filegen__Message__c = e.getMessage() + ', line number:'+ e.getLineNumber() + ', cause:'+ e.getCause() + ', stacktrace:' + e.getStackTraceString();
            log.filegen__Time__c = System.Now();
            log.filegen__Type__c = type;
            insert log;
        }
        catch(Exception e1){
            throw new CommonUtility.CustomException('[BankFileUtil.logException] Exception:' + e1.getMessage() + ', at line: ' + e1.getLineNumber());
        }
    }

    /**
     * isBankAccountValid Validates if a bank account data passed is correct or wrong
     * @param  sObj sObj description
     * @return      Returns boolean decision
     */
    public boolean isBankAccountValid(SObject sObj){
        try{
            String accountHolderName = '';
            String bsbNumber = '';
            String bankAccountNumber = '';

            if(sObj instanceof loan__Disbursal_Txn_Distribution__c){
                loan__Disbursal_Txn_Distribution__c dtd = (loan__Disbursal_Txn_Distribution__c) sObj;
                accountHolderName = dtd.loan__Bank_Account__r.Account_Holder_Name__c;
                bsbNumber = dtd.loan__Bank_Account__r.BSB__c;
                bankAccountNumber = dtd.loan__Bank_Account__r.loan__Bank_Account_Number__c;
            }
            else if(sObj instanceof loan__Bank_Account__c){ 
                loan__Bank_Account__c bankAcc = (loan__Bank_Account__c) sObj;
                accountHolderName = bankAcc.Account_Holder_Name__c;
                bsbNumber = bankAcc.BSB__c;
                bankAccountNumber = bankAcc.loan__Bank_Account_Number__c;
            }

            if(String.isBlank(accountHolderName)){
                return false;
            }

            if(String.isBlank(bsbNumber)){
                return false;
            }

            if(String.isBlank(bankAccountNumber) || bankAccountNumber.length() > 9){
                return false;
            }
            return true;
        }
        catch(Exception e){
            throw new CommonUtility.CustomException('[DirectCreditBankFilegen.isBankAccountValid] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }
    }    

    /**
     * Inner class to hold data for line record depending on different types of objects.
     */
    public class LineItemInfo{
        public String bsbNumber;
        public String bankAccountNumber;
        public String titleOfAccount;
        public Decimal txnAmount;
        public String nameOfEntity;
    }
}