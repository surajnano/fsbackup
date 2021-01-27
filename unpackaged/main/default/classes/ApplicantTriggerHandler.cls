public with sharing class ApplicantTriggerHandler extends TriggerHandler {
    private List<Applicant__c> newApplicants;

    public ApplicantTriggerHandler(){
        this.newApplicants = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newApplicants, 'ExternalId__c');
    }

}