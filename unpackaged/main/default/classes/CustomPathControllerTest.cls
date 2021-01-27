@isTest 
private class CustomPathControllerTest {
    

    @IsTest
    static void testCustomPath(){
        
        Test.startTest();
            System.assertEquals(
                String.isNotEmpty( CustomPathController.getPicklistValues('Application__c', 'Status__c') ),
                true
            );
        Test.stopTest();
        
    }


}