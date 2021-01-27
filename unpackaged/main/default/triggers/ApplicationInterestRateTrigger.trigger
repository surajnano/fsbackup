trigger ApplicationInterestRateTrigger on ApplicationInterestRate__c (before insert) {
    new ApplicationInterestRateTriggerHandler().run();
}