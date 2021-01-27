trigger ApplicationBankAccountTrigger on ApplicationBankAccount__c (before insert) {
    new ApplicationBankAccountTriggerHandler().run();
}