trigger IncomeTrigger on Income__c (before insert) {
    new IncomeTriggerHandler().run();
}