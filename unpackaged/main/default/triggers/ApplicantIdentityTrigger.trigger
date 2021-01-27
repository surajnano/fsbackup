trigger ApplicantIdentityTrigger on ApplicantIdentity__c (before insert) {
    new ApplicantIdentityTriggerHandler().run();
}