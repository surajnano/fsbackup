/**
 * Created by Muhammad on 16/11/20.
 */

@IsTest
private class LoanCoborrowerTriggerHandlerTest {
    @IsTest
    static void testBehavior() {
        Contact con = new Contact(FirstName='Moh test',LastName='Testing');
        insert con;
        loan__Coborrower__c cob = new loan__Coborrower__c();
        cob.loan__Contact__c = con.Id;
        insert cob;
        delete cob;
    }
}