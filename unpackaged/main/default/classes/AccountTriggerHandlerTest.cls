@isTest
private class AccountTriggerHandlerTest {
    
    @IsTest
    static void testValidPhoneNumber(){
        
        Test.startTest();
            Account someone = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
            someone.Phone = '02 9090 9090';
            update someone;

            Account acc = [select personmobilephone, phone from account limit 1];
            system.assertEquals(acc.PersonMobilePhone.contains('+61'), true);
            system.assertEquals(acc.Phone.contains('+61'), true);

            system.debug(acc.phone);
        Test.stopTest();
        
    }

    @IsTest
    static void testInvalidMobilePhoneNumber(){
        
        Test.startTest();
            DmlException fieldValidationExc;
            Account someone = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
            
            try {
                someone.PersonMobilePhone = 'f98h27849hf928f';
                update someone;
            } catch (DmlException dmle) {
                fieldValidationExc = dmle;
            }
            
            system.assertEquals(fieldValidationExc != null, true);

        Test.stopTest();
        
    }

    @IsTest
    static void testInvalidPhoneNumber(){
        
        Test.startTest();
            DmlException fieldValidationExc;
            Account someone = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
            
            try {
                someone.Phone = 'o0987ytghju876';
                update someone;
            } catch (DmlException dmle) {
                fieldValidationExc = dmle;
            }
            
            system.assertEquals(fieldValidationExc != null, true);

        Test.stopTest();
        
    }

    @isTest
    static void testEntitlementCreation() {

        //testing entitlement creation on insert
        Account someone = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
        
        List<Entitlement> entitlements = [SELECT Id FROM Entitlement WHERE AccountId = :someone.Id];
        System.assertEquals(1, entitlements.size());

        //testing entitlement creation on insert
        Test.startTest();

        delete entitlements;
        System.assertEquals(0, [SELECT count() FROM Entitlement WHERE AccountId = :someone.Id]);

        someone.FirstName = 'Firstname';
        update someone;

        System.assertEquals(1, [SELECT count() FROM Entitlement WHERE AccountId = :someone.Id]);
        delete someone;

        Test.stopTest();
    }
}