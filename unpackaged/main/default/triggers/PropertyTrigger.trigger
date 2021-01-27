trigger PropertyTrigger on Property__c (before insert) {
    new PropertyTriggerHandler().run();
}