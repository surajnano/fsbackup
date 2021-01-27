@isTest
private class WSApplicationEnumsTest {
    
    @IsTest
    static void enumsApplicationError(){

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        
        Test.startTest();
            WSApplicationEnums.getApplicationEnums();

            RestResponse res = RestContext.response;
            System.assertEquals( res.responseBody.toString().contains('application configuration error'), true );

        Test.stopTest();
        
    }

    @IsTest
    static void getEnums(){

        TestDataFactory.initApplicationSettings();

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        
        Test.startTest();
            WSApplicationEnums.getApplicationEnums();

            RestResponse res = RestContext.response;
            System.assertEquals( res.responseBody.toString().contains('value'), true );
            System.assertEquals( res.responseBody.toString().contains('name'), true );
            System.assertEquals( res.responseBody.toString().contains('label'), true );

        Test.stopTest();
        
    }


}