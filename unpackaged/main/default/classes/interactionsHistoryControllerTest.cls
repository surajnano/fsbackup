/**
 * Created by muhammadbinmuzaffar on 10/12/20.
 */
@IsTest
private class interactionsHistoryControllerTest {
    @IsTest
    static void testBehavior() {
        Account ac = TestDataFactory.createPersonAccount('Test','TestLAst','test@test.com.au','0334531221');
        Case c = new Case(SuppliedName='TestCase',AccountId=ac.Id,Account=ac,Subject='teest case',Reason='None');
        insert c;
        EmailMessage em = new EmailMessage(RelatedToId = ac.Id);
        EmailMessage em2 = new EmailMessage(RelatedToId = c.Id);
        insert em;
        insert em2;
        InteractionsHistoryController.getAllCases(ac.Id);
    }
}