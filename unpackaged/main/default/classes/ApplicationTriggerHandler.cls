public with sharing class ApplicationTriggerHandler extends TriggerHandler {

    private List<Application__c> newApplications;

    public ApplicationTriggerHandler(){
        this.newApplications = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newApplications, 'ExternalId__c');
    }
        
}