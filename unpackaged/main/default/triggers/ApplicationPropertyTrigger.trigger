trigger ApplicationPropertyTrigger on ApplicationProperty__c (before insert) {
    new ApplicationPropertyTriggerHandler().run();
}