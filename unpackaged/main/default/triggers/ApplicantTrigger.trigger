trigger ApplicantTrigger on Applicant__c (before insert) {
    new ApplicantTriggerHandler().run();
}