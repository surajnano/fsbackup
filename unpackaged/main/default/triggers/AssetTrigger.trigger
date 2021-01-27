trigger AssetTrigger on Asset__c (before insert) {
    new AssetTriggerHandler().run();
}