@isTest
private class CaseTriggerHandlerTest {

    @isTest
    static void testEntitlementPopulationFromAccount() {
        Account a = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
        
        List<Entitlement> entitlements = [SELECT Id FROM Entitlement WHERE AccountId = :a.Id];
        System.assertEquals(1, entitlements.size());

        Test.startTest();

        Case newCase 	= new Case();
 		newCase.Status	= 'New';
        newCase.Origin	= 'Email'; 
        newCase.AccountId = a.Id;
        insert newCase;

        Test.stopTest();

        System.assertEquals(entitlements[0].Id, [SELECT EntitlementId FROM Case WHERE Id = :newCase.Id].EntitlementId);
    }

    @isTest
    static void testEntitlementPopulationFromContact() {
        Account a = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
        
        List<Entitlement> entitlements = [SELECT Id FROM Entitlement WHERE AccountId = :a.Id];
        System.assertEquals(1, entitlements.size());

        Contact c = new Contact();
        c.FirstName = 'FirstNamexcvb';
        c.LastName = 'LastNamexcvb';
        insert c;

        EntitlementContact ec = new EntitlementContact(
            EntitlementId = entitlements[0].Id,
            ContactId = c.Id
        );
        insert ec;

        Test.startTest();

        Case newCase 	= new Case();
 		newCase.Status	= 'New';
        newCase.Origin	= 'Email'; 
        newCase.ContactId = c.Id;
        insert newCase;

        Test.stopTest();

        System.assertEquals(entitlements[0].Id, [SELECT EntitlementId FROM Case WHERE Id = :newCase.Id].EntitlementId);
    }
    
    @isTest
    static void testEntitlementCreationOnInsert() {
        Account a = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
        
        //deleting the entitlement entitlement created when account is inserted
        delete [SELECT Id FROM Entitlement WHERE AccountId = :a.Id];
        System.assertEquals(0, [SELECT count() FROM Entitlement WHERE AccountId = :a.Id]);

        Test.startTest();

        Case newCase 	= new Case();
 		newCase.Status	= 'New';
        newCase.Origin	= 'Email'; 
        newCase.AccountId = a.Id;
        insert newCase;

        Test.stopTest();

        List<Entitlement> entitlements = [SELECT Id FROM Entitlement WHERE AccountId = :a.Id];
        System.assertEquals(entitlements[0].Id, [SELECT EntitlementId FROM Case WHERE Id = :newCase.Id].EntitlementId);
    }

    @isTest
    static void testEntitlementCreationOnUpdate() {
        Account a = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
        
        //deleting the entitlement entitlement created when account is inserted
        delete [SELECT Id FROM Entitlement WHERE AccountId = :a.Id];
        System.assertEquals(0, [SELECT count() FROM Entitlement WHERE AccountId = :a.Id]);

        Test.startTest();

        Case newCase 	= new Case();
 		newCase.Status	= 'New';
        newCase.Origin	= 'Email'; 
        insert newCase;

        System.assert(String.isBlank([SELECT EntitlementId FROM Case WHERE Id = :newCase.Id].EntitlementId));

        newCase.AccountId = a.Id;
        update newCase;

        Test.stopTest();

        List<Entitlement> entitlements = [SELECT Id FROM Entitlement WHERE AccountId = :a.Id];
        System.assertEquals(entitlements[0].Id, [SELECT EntitlementId FROM Case WHERE Id = :newCase.Id].EntitlementId);
    }

    @isTest
    static void testClosingEntitlements() {
        Account a = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
        
        //deleting the entitlement entitlement created when account is inserted
        delete [SELECT Id FROM Entitlement WHERE AccountId = :a.Id];

        //creating entitlement on inactive entitlement process
        List<Slaprocess> defEntProcess = [SELECT Id, NAME FROM Slaprocess WHERE IsActive = false LIMIT 1];
        Id defEntProcessId = defEntProcess.size() > 0 ? defEntProcess[0].Id : null;

        List<BusinessHours> defbusHour = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
        Id defbusHourId = defbusHour.size() > 0 ? defbusHour[0].Id : null;

        Entitlement ent = new Entitlement(
                                    Name = a.Name + ' Support Entitlement',
                                    AccountId = a.Id,
                                    BusinessHoursId = defbusHourId,
                                    SlaProcessId = defEntProcessId,
                                    StartDate = System.today().addDays(-100),
                                    EndDate = System.today().addDays(50),
                                    Type = 'Support'
                                );
        insert ent;

        Contact c = new Contact();
        c.FirstName = 'FirstNamexcvb';
        c.LastName = 'LastNamexcvb';
        insert c;

        EntitlementContact ec = new EntitlementContact(
            EntitlementId = ent.Id,
            ContactId = c.Id
        );
        insert ec;

        Test.startTest();

        List<Case> caseList = new List<Case> {
            new Case(
                Status = 'New',
                Origin = 'Email',
                AccountId = a.Id
            ), 
            new Case(
                Status = 'New',
                Origin = 'Email',
                ContactId = c.Id,
                AccountId = a.Id
            )
        };

        insert caseList;

        Test.stopTest();

        if (String.isNotBlank(defEntProcessId)) {
            System.assertEquals(System.today().addDays(-1), [SELECT EndDate FROM Entitlement WHERE Id = :ent.Id].EndDate);
            System.debug(ent.Id);
            System.debug([SELECT EntitlementId FROM Case]);
            System.assertEquals(2, [SELECT count() FROM Case WHERE EntitlementId != null AND EntitlementId != :ent.Id]);
        }
    }
    @isTest
    static void testcaseassignmentrules(){
        Account a = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');
        Case c = new Case(AccountId = a.Id, Status = 'New', Origin = 'Live Chat', Subject = 'Run Assignment Rules');
        Insert c;
        List<Id> cs = new List<Id>();
        cs.add(c.Id);
        RunCaseAssignemntRules.Caseassignmentrule(cs);
    }

    // @isTest
    // static void testDeleteInactiveEntitlement() {
    //     Account a = TestDataFactory.createPersonAccount('Johnny', 'Fandango', 'testingsf@nano.com.au', '456456456');

    //     //insert an expired entitlement
    //     List<Slaprocess> defEntProcess = [SELECT Id, NAME FROM Slaprocess WHERE IsActive = true LIMIT 1];
    //     Id defEntProcessId = defEntProcess.size() > 0 ? defEntProcess[0].Id : null;

    //     List<BusinessHours> defbusHour = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
    //     Id defbusHourId = defbusHour.size() > 0 ? defbusHour[0].Id : null;

    //     Entitlement entExpired = new Entitlement(
    //                                 Name = a.Name + ' Support Entitlement',
    //                                 AccountId = a.Id,
    //                                 BusinessHoursId = defbusHourId,
    //                                 SlaProcessId = defEntProcessId,
    //                                 StartDate = System.today().addDays(-100),
    //                                 EndDate = System.today().addDays(-50),
    //                                 Type = 'Support'
    //                             );
    //     insert entExpired;

    //     //asserting 2 entitlements on the account, 1 expired
    //     System.assertEquals(2, [SELECT count() FROM Entitlement WHERE AccountId = :a.Id]);

    //     Test.startTest();

    //     Case newCase 	= new Case();
 	// 	newCase.Status	= 'New';
    //     newCase.Origin	= 'Email'; 
    //     newCase.AccountId = a.Id;
    //     insert newCase;

    //     Test.stopTest();

    //     //asserting expired entitlement is deleted
    //     System.assertEquals(1, [SELECT count() FROM Entitlement WHERE AccountId = :a.Id]);
    //     System.assertEquals(0, [SELECT count() FROM Entitlement WHERE Id = :entExpired.Id]);
    // }
}