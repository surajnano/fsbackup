@IsTest 
private class BatchUpdateApplicationRatesTest {
    

    @TestSetup
    static void makeData(){
        TestDataFactory.createNewRate(null, 2.231, System.today().addDays(-365), System.today().addDays(-1));
        TestDataFactory.createRateSchedule(System.today().addDays(-365), 2.231, 0.5, 1, 60, 'Months', [select id from loan__Floating_Rate_Index__c LIMIT 1] );
    }

    @IsTest
    static void queueDAGJobs(){

        clcommon__DAG_Schedule__c dagSchedule = new clcommon__DAG_Schedule__c(
            clcommon__DAG_Name__c = 'Testing DAG'
        );
        insert dagSchedule;
        clcommon__Job__c dagJob = new clcommon__Job__c(
            clcommon__DAG__c = dagSchedule.id,
            clcommon__Batch_Size__c = 1,
            clcommon__Class__c = 'BatchUpdateApplicationRates',
            clcommon__Fail_Type__c = 'Logging',
            clcommon__Label__c = 'BatchUpdateApplicationRates',
            clcommon__Number_Of_Instances__c = 1
        );
        insert dagJob;

        clcommon__Job_Dependency__c dagJobDep = new clcommon__Job_Dependency__c(
            clcommon__DAG__c = dagSchedule.id,
            clcommon__Job__c = dagJob.id
        );
        insert dagJobDep;

        TestDataFactory.createNewRate([select id from loan__Floating_Rate_Index__c LIMIT 1], 2.0, System.today(), System.today().addDays(365));

       


        Test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(200, 'OK');
            Test.setMock(HTTPCalloutMock.class, testMock);

            clcommon.DynamicJobAPI5 apiHandle = clcommon.APIFactory.getDynamicJobAPI5();
            apiHandle.runOnce(dagSchedule.clcommon__DAG_Name__c);
            
                
        Test.stopTest();

        system.assertEquals( [SELECT clcommon__Status__c FROM clcommon__DAG_Logging__c WHERE clcommon__DAG__c = :dagSchedule.id].size() > 0, true);
        
    }






}