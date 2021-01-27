@istest
private class CalloutWrapperTest {

    @TestSetup
    static void makeData(){
        Account individual = TestDataFactory.createPersonAccount('John', 'lastName', 'testing@nano.com.au', '456456456');
        TestDataFactory.createApplication(individual.id);
    }
    

    @IsTest
    static void testCallout(){
        
        Test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(200, 'OK');
            Test.setMock(HTTPCalloutMock.class, testMock);

            Application__c app = [SELECT ID, ExternalId__c from Application__c LIMIT 1];
            CalloutWrapper.makeCallout('LVRCalc', app.externalId__c);
        Test.stopTest();
        
    }


    @IsTest
    static void testGetInterval(){
        
        Test.startTest();
            CalloutWrapper.getCalloutIntervalWait();
        Test.stopTest();
        
    }




}