/**
 * Created by Muhammad on 17/11/20.
 */

@IsTest
private class UpdateApplicationRatesControllerTest {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(200, 'OK');
        Test.setMock(HTTPCalloutMock.class, testMock);
        UpdateApplicationRatesController.executeBatch();
        Test.stopTest();
    }
}