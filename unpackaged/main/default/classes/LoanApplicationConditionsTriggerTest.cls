@isTest
private class LoanApplicationConditionsTriggerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.initApplicationSettings();
        Account individual = TestDataFactory.createPersonAccount('Seth', 'Testing', 'testing@verteva.com.au', '456456456');
        Application__c application = TestDataFactory.createApplication(individual.Id);
        TestDataFactory.createFinancials(application.Id);
        TestDataFactory.createFoldersForBucket('nanotest');
    }

    @isTest
    static void testExtId() {
        LoanApplicationConditions__c lap = new LoanApplicationConditions__c(
            Application__c = [Select id from application__c limit 1].id
        );

        insert lap;

        System.assert(String.isNotBlank([SELECT ExternalId__c FROM LoanApplicationConditions__c WHERE Id = :lap.Id].ExternalId__c));
    }
}