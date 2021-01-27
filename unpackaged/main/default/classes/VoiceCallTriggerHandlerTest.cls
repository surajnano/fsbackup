@isTest
private class VoiceCallTriggerHandlerTest {

    @isTest
    static void testPopulateRelatedRecordFromCaller() {
        List<CallCenter> cc = [SELECT Id FROM CallCenter LIMIT 1];

        Account a = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '+61412345678');

         Contact c = new Contact();
         c.FirstName = 'FirstNamexcvb';
         c.LastName = 'LastNamexcvb';
         insert c;


        Test.startTest();

        if (cc.size() > 0) {
            List<VoiceCall> vcList = new List<VoiceCall> {
                new VoiceCall (
                    CallCenterId = cc[0].Id,
                    VendorType = 'ContactCenter',
                    CallStartDateTime = System.now().addHours(-10),
                    CallEndDateTime = System.now().addHours(-9),
                    FromPhoneNumber = '+61412345678',
                    ToPhoneNumber = '+61401111111',
                    CallType = 'Inbound'
                ),
                new VoiceCall (
                    CallCenterId = cc[0].Id,
                    VendorType = 'ContactCenter',
                    CallStartDateTime = System.now().addHours(-10),
                    CallEndDateTime = System.now().addHours(-9),
                    FromPhoneNumber = '+61487654321',
                    ToPhoneNumber = '+61401111111',
                    CallType = 'Inbound'
                ),
                new VoiceCall (
                    CallCenterId = cc[0].Id,
                    VendorType = 'ContactCenter',
                    CallStartDateTime = System.now().addHours(-10),
                    CallEndDateTime = System.now().addHours(-9),
                    FromPhoneNumber = '+61400000000',
                    ToPhoneNumber = '+61412345678',
                    CallType = 'Outbound'
                )
            };

            insert vcList; 
            vcList[1].RelatedRecordId = c.Id;
            update vcList;
        }

        System.assertEquals(2, [SELECT count() FROM VoiceCall WHERE Account__c = :a.Id]);


        Test.stopTest();
    }
}