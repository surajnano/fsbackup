trigger ApplicationTrigger on Application__c (before insert) {
    new ApplicationTriggerHandler().run();
}