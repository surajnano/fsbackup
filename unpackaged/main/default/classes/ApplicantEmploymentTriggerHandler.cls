public with sharing class ApplicantEmploymentTriggerHandler extends TriggerHandler {
    
    private List<ApplicantEmployment__c> newApplicantEmployments;

    public ApplicantEmploymentTriggerHandler(){
        this.newApplicantEmployments = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newApplicantEmployments, 'ExternalId__c');
    }

}