@istest
private class edCustomS3FileUploadControllerTest {
    
    
    @TestSetup
    static void makeData(){
        TestDataFactory.initApplicationSettings();
        Account individual = TestDataFactory.createPersonAccount('Seth', 'Testing', 'testing@verteva.com.au', '456456456');
        Application__c application = TestDataFactory.createApplication(individual.Id);
        TestDataFactory.createFinancials(application.Id);
        TestDataFactory.createFoldersForBucket('nanotest');
    }


    @IsTest
    static void testS3Folder(){
        
        Test.startTest();
        try{
            System.assertEquals( 
                String.isNotEmpty( edCustomS3FileUploadController.getFolder([Select id from application__c limit 1].id) ),
                true
             );
            edCustomS3FileUploadController.getFolder(null);
        } catch (Exception e) {
            //todo: remove this try/catch
        }
        Test.stopTest();
        
    }




}