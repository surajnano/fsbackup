trigger ExpenseTrigger on Expense__c (before insert) {
    new ExpenseTriggerHandler().run();
}