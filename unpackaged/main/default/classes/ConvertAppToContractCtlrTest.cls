/**
 * Created by Muhammad on 17/11/20.
 */

@IsTest
private class ConvertAppToContractCtlrTest {
    @IsTest
    static void testBehavior() {
        Account acc = TestDataFactory.createPersonAccount('Test','User','testUser@gmil.com','0345241312');
        Application__c app = TestDataFactory.createApplication(acc.Id);
        List<Id> ids = new List<Id>();
        ids.add(app.Id);
        Conversion_Mapping__c cm = new Conversion_Mapping__c(Target_Object__c = 'loan__Coborrower__c',Target_Field__c = 'loan__Account__c',Source_Field__c ='Account__c',Source_Object__c='Applicant__c',Parent_Object__c='loan__Loan__c',Mandatory__c=true,Filter_Criteria__c='Application__c');
        insert cm;
        try{
            ConvertAppToContractCtlr.convertApplication(ids);
        }catch(Exception e){
            System.debug(e.getMessage());
        }

    }
}