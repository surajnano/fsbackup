trigger LiabilityTrigger on Liability__c (before insert) {
    new LiabilityTriggerHandler().run();
}