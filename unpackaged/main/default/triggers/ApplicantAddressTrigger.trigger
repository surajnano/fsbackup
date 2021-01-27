trigger ApplicantAddressTrigger on ApplicantAddress__c (before insert) {
    new ApplicantAddressTriggerHandler().run();
}