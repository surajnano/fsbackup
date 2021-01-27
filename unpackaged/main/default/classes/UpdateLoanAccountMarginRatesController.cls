public with sharing class UpdateLoanAccountMarginRatesController {
    

    @AuraEnabled
    public static clcommon__Rate_Schedule__c getRateSchedule(String rateId){
        return [SELECT  Id, clcommon__Effective_Date__c, clcommon__Interest_Rate__c, clcommon__Margin_Rate__c, 
                        clcommon__Terms__c, clcommon__Unit__c, loan__Loan_Product__c, Property_Purpose__c, Repayment_Type__c 
                FROM    clcommon__Rate_Schedule__c where id = :rateId];
    }


    @AuraEnabled
    public static String executeBatch(String rateId){
        clcommon__Rate_Schedule__c rate = getRateSchedule(rateId);
        if(rate.clcommon__Margin_Rate__c != null && rate.Property_Purpose__c != null && rate.Repayment_Type__c != null){

            BatchUpdateLoanAccountRates bular = new BatchUpdateLoanAccountRates();
            bular.query = 'SELECT ID, loan__Due_Day__c FROM loan__Loan_Account__c WHERE PropertyPurpose__c = \'' + rate.Property_Purpose__c + '\' AND CurrentPaymentType__c = \'' + rate.Repayment_Type__c + '\' ';
            bular.effectiveDate = rate.clcommon__Effective_Date__c;
            bular.marginRate = rate.clcommon__Margin_Rate__c;
            bular.maintainDeliquencyFlag = true;

            return Database.executeBatch(bular, 5);

        }

        return null;

    }

}