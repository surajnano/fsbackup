public with sharing class ApplicantAddressTriggerHandler extends TriggerHandler {

    private List<ApplicantAddress__c> newApplicantAddresses;

    public ApplicantAddressTriggerHandler(){
        this.newApplicantAddresses = Trigger.new;
    }

    public override void beforeInsert(){
        VertevaUtils.setUUID(newApplicantAddresses, 'ExternalId__c');
    }
        
}