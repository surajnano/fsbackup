@istest 
private class ExceptionLogTriggerHandlerTest {
    

    @TestSetup
    static void createFinancials(){
        TestDataFactory.initApplicationSettings();
        Account individual = TestDataFactory.createPersonAccount('Seth', 'Testing', 'testing@verteva.com.au', '456456456');
        Application__c application = TestDataFactory.createApplication(individual.Id);
        
    }

    @IsTest
    static void testExceptionMapping(){
        Test.startTest();

            String exceptionCode = 'VAL-1234';

            Application__c app = [select id from application__c limit 1];
            TestDataFactory.createChecklistConfig(exceptionCode);
            ExceptionLog__c el = TestDataFactory.createApplicationException(app.id, 'valuation error', exceptionCode);

        Test.stopTest();

        System.assertEquals([select id from Task where whatId = :app.id].size() != 0 , true);
        
    }



}