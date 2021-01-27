public with sharing class ApplicantIdentityTriggerHandler extends TriggerHandler {
    private List<ApplicantIdentity__c> newAppIdentity;

    public ApplicantIdentityTriggerHandler(){
        this.newAppIdentity = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newAppIdentity, 'ExternalID__c');
    }
}