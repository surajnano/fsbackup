public with sharing class FinancialsController {

    @AuraEnabled
    public static Application__c getApplication(String applicationId){
        return [
            SELECT Id, 
            Name, 
            FinancialLastModifiedDate__c, 
            FinancialLastModifiedBy__c, 
            FinancialLastModifiedBy__r.Name, 
            SubmittedDate__c,
            Serviceability__c,
            MonthlyIncome__c,
            MonthlyExpenses__c,
            MonthlyLiabilities__c,
            ExpensesHEM__c
            FROM Application__c 
            where Id = :applicationId
        ];
    }


    @AuraEnabled
    public static String getExpenses(String applicationId){

        Map<String, FinanceRecord> recordsByCategory = new Map<String, FinanceRecord>();
        
        for( Expense__c e : [SELECT Id, Applicant__r.Account__r.Name, BasiqAmount__c, Amount__c, Notes__c, AssessedAmount__c, AssessedNotes__c, Exclude__c
                               FROM Expense__c 
                              WHERE Application__c = :applicationId]){

        // for( Expense__c e : [SELECT Id, Category__c, SubCategory__c, Applicant__r.Account__r.Name, BasiqAmount__c, Amount__c, Notes__c, AssessedAmount__c, AssessedNotes__c, Exclude__c
        //                        FROM Expense__c 
        //                       WHERE Application__c = :applicationId ORDER BY Category__c, SubCategory__c NULLS FIRST]){

            // if(!recordsByCategory.containsKey(e.Category__c))
            //     recordsByCategory.put(e.Category__c, new FinanceRecord(e));
            // else
            //     recordsByCategory.get(e.Category__c).childRecords.add(new FinanceRecord(e));
             
        }

        return JSON.serialize(recordsByCategory.values());
        
    }
    @AuraEnabled
    public static String getIncomes(String applicationId){

        List<FinanceRecord> records = new List<FinanceRecord>(); 
        
        for( Income__c e : [SELECT Id, Name, Type__c, Applicant__r.Account__r.Name, BasiqAmount__c, Amount__c, Notes__c, AssessedAmount__c, AssessedNotes__c, Exclude__c
                               FROM Income__c 
                              WHERE Application__c = :applicationId ORDER BY CreatedDate ]){

           records.add( new FinanceRecord ( e ) );
             
        }

        return JSON.serialize( records );
        
    }

    @AuraEnabled
    public static String getLiabilities(String applicationId){

        List<FinanceRecord> records = new List<FinanceRecord>(); 
        
        for( Liability__c e : [SELECT Id, Class__c, Applicant__r.Account__r.Name, BasiqBalance__c, BasiqRepayment__c, Balance__c, Repayment__c, Notes__c, AssessedBalance__c, AssessedRepayment__c, AssessedNotes__c, Exclude__c
                               FROM Liability__c 
                              WHERE Application__c = :applicationId ORDER BY CreatedDate ]){

           records.add( new FinanceRecord ( e ) );
             
        }

        return JSON.serialize( records );
        
    }
    @AuraEnabled
    public static void deleteRecord(String recordId, String sObjectName){
        String query = 'SELECT Id FROM '+ sObjectName +  ' WHERE Id=: recordId';

            delete Database.query(query);
    }
    @AuraEnabled
    public static String getAssets(String applicationId){

        List<FinanceRecord> records = new List<FinanceRecord>(); 
        
        for( Asset__c e : [SELECT Id, Class__c, Applicant__r.Account__r.Name, BasiqValue__c, Value__c, Notes__c, AssessedValue__c, AssessedNotes__c, Exclude__c
                            FROM  Asset__c 
                            WHERE Application__c = :applicationId ORDER BY CreatedDate ]){

           records.add( new FinanceRecord ( e ) );
             
        }

        return JSON.serialize( records );
        
    }

    @AuraEnabled
    public static void saveNewAsset(String payload){

        system.debug(payload);

        try {
            Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(payload);
            if((String) payloadMap.get('applicantId') == ''){
                Applicant__c applicant = [SELECT Id FROM Applicant__c WHERE Application__c=:(String) payloadMap.get('applicationId') LIMIT 1];
                payloadMap.put('applicantId',applicant.Id);
            }
            if(payloadMap != null){

                Asset__c newAsset = new Asset__c(
                    Application__c = (String) payloadMap.get('applicationId'),
                    Applicant__c = (String) payloadMap.get('applicantId'),
                    UnitNumber__c  = (String) payloadMap.get('unitNumber'),
                    StreetNumber__c = (String) payloadMap.get('streetNumber'),
                    StreetName__c = (String) payloadMap.get('streetName'),
                    StreetType__c = (String) payloadMap.get('streetType'),
                    Suburb__c = (String) payloadMap.get('suburb'),
                    PostalCode__c = (String) payloadMap.get('postalCode'),
                    City__c = (String) payloadMap.get('city'),
                    State__c = (String) payloadMap.get('state'),
                    Country__c = (String) payloadMap.get('country'),
                    AssessedValue__c = Decimal.valueOf( (String) payloadMap.get('propertyValue') ),
                    AssessedNotes__c = (String) payloadMap.get('loanNotes')
                );
                insert newAsset;

                // LIABILITY SECTION
                boolean hasLoan = Boolean.valueOf( (String) payloadMap.get('hasLoan') );
                if(hasLoan){

                    Liability__c liability = new Liability__c(
                        Application__c = (String) payloadMap.get('applicationId'),
                        Applicant__c = (String) payloadMap.get('applicantId'),
                        Asset__c = newAsset.Id,
                        Class__c = (String) payloadMap.get('class'),
                        AssessedRepayment__c = Decimal.valueOf( (String) payloadMap.get('loanMonthlyRepayments') ),
                        AssessedBalance__c = Decimal.valueOf( (String) payloadMap.get('loanBalance') ),
                        AssessedNotes__c = (String) payloadMap.get('loanNotes')
                    );
                    insert liability;
                }
                // END LIABILITY SECTION 


                // INCOME SECTION 
                boolean hasRentalIncome = Boolean.valueOf( (String) payloadMap.get('hasRentalIncome') );
                if(hasRentalIncome){

                    Income__c income = new Income__c(
                        Name = 'Rental Income', 
                        Type__c = OnboardingConstants.INCOME_TYPE_REGULAR, 
                        Application__c = (String) payloadMap.get('applicationId'),
                        Applicant__c = (String) payloadMap.get('applicantId'),
                        AssessedAmount__c = Decimal.valueOf( String.valueOf( payloadMap.get('monthlyRentalIncome') ) ), 
                        AssessedNotes__c = (String) payloadMap.get('incomeNotes')
                    );
                    insert income;
                }
                // END INCOME SECTION 


            } 
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void saveFinanceRecords(String payload){
        try {
            
            System.debug(payload);
            List<SObject> toUpdate = new List<SObject>();
            if(payload != null){
                List<FinanceRecord> financeRecords = (List<FinanceRecord>) JSON.deserialize(payload, List<FinanceRecord>.class);
                for(financeRecord fr : financeRecords)
                    if(fr.hasChanged)
                        toUpdate.add(fr.detail);

                if(!toUpdate.isEmpty())
                    update toUpdate;
            }

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static Map<String, Decimal> getServiceabilityCalc(String applicationId) {

        ApplicationSettings__c appSettings = ApplicationSettings__c.getInstance();
        
        AggregateResult income = [SELECT SUM(BasiqAmount__c) basiq, SUM(Amount__c) applicant, SUM(AssessedAmount__c) assessed FROM Income__c where Application__c = :applicationId AND Exclude__c = false];
        AggregateResult expense = [SELECT SUM(BasiqAmount__c) basiq, SUM(Amount__c) applicant, SUM(AssessedAmount__c) assessed FROM Expense__c where Application__c = :applicationId AND Exclude__c = false];
        AggregateResult liability = [SELECT SUM(BasiqRepayment__c) basiq, SUM(Repayment__c) applicant, SUM(AssessedRepayment__c) assessed FROM Liability__c where Application__c = :applicationId AND Exclude__c = false];

        Map<String, Decimal> totals = new Map<String, Decimal>{
            'surplusBalance' => appSettings.SurplusBalance__c,
            'basiq' => getSurplusAmount( toDecimal( income.get('basiq') ), toDecimal( expense.get('basiq') ), toDecimal( liability.get('basiq') ) ),
            'applicant' => getSurplusAmount( toDecimal( income.get('applicant') ), toDecimal( expense.get('applicant') ), toDecimal( liability.get('applicant') ) ),
            'assessed' => getSurplusAmount( toDecimal( income.get('assessed') ), toDecimal( expense.get('assessed') ), toDecimal( liability.get('assessed') ) )
        };

        return totals;
    }

    private static Decimal getSurplusAmount(Decimal totalIncome, Decimal totalExpense, Decimal totalLiability){
        return totalIncome - ( totalExpense + totalLiability );
    }
    
    private static Decimal toDecimal(Object val){
        return val != null ? (decimal) val : 0;
    }

    public class FinanceRecord {
        public sObject detail;
        public boolean hasChanged;
        public List<FinanceRecord> childRecords;
        public FinanceRecord(sObject detail){ 
            this.hasChanged = false;
            this.detail = detail;
            childRecords = new List<FinanceRecord>();
        }
    }


    

}