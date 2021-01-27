@isTest
private class UpdateLoanAccountMarginRatesCtrTest {
    

    @TestSetup
    static void makeData(){
        
        insert new clcommon__Rate_Schedule__c( 
            clcommon__Effective_Date__c = system.today().addDays(-365),
            clcommon__Interest_Rate__c = 2.1,
            clcommon__Margin_Rate__c = 0.2,
            clcommon__Terms__c = 60,
            Property_Purpose__c = 'Investment',
            Repayment_Type__c = 'Interest Only'
        );

    }

    @IsTest
    static void getRateSchedule(){

        clcommon__Rate_Schedule__c dbRate  = [SELECT ID, clcommon__Interest_Rate__c FROM clcommon__Rate_Schedule__c LIMIT 1];
        
        Test.startTest();
            clcommon__Rate_Schedule__c newRate = UpdateLoanAccountMarginRatesController.getRateSchedule(dbRate.id);
            system.assertEquals(dbRate.clcommon__Interest_Rate__c, newRate.clcommon__Interest_Rate__c);
        Test.stopTest();
        
    }

    @IsTest
    static void execBatch(){

        clcommon__Rate_Schedule__c dbRate  = [SELECT ID, clcommon__Interest_Rate__c FROM clcommon__Rate_Schedule__c LIMIT 1];
        
        Test.startTest();
            String jobId = UpdateLoanAccountMarginRatesController.executeBatch(dbRate.id);
            system.assertEquals(String.isEmpty(jobId), false);
        Test.stopTest();
        
    }


}