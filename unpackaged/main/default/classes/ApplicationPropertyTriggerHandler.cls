public with sharing class ApplicationPropertyTriggerHandler extends TriggerHandler {
    private List<ApplicationProperty__c> newApplicationProperties;

    public ApplicationPropertyTriggerHandler(){
        this.newApplicationProperties = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newApplicationProperties, 'ExternalId__c');
    }
}