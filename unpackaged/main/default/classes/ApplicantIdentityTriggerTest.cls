@isTest
private class ApplicantIdentityTriggerTest {
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
        ApplicantIdentity__c lap = new ApplicantIdentity__c();

        insert lap;

        System.assert(String.isNotBlank([SELECT ExternalId__c FROM ApplicantIdentity__c WHERE Id = :lap.Id].ExternalId__c));
    }
}