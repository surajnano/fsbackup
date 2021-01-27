trigger ApplicantEmploymentTrigger on ApplicantEmployment__c (before insert) {
    new ApplicantEmploymentTriggerHandler().run();
}