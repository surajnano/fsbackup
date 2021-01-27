@IsTest
private class ApplicantsControllerTest {
    


    @TestSetup
    static void makeData(){
        Account individual = TestDataFactory.createPersonAccount('Seth', 'Testing', 'testing@verteva.com.au', '456456456');
        Application__c application = TestDataFactory.createApplication(individual.Id);
        TestDataFactory.addApplicant(application.Id);
    }

    @IsTest
    static void testApplicants(){
        
        Test.startTest();
            application__c app = [select id from application__c];
            List<Applicant__c> applicants = ApplicantsController.getApplicants(app.id);
            system.debug( applicants );
            system.assertEquals(applicants.size() > 0, true);
            
        Test.stopTest();   
        
    }

}