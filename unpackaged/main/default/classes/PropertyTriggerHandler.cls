public with sharing class PropertyTriggerHandler extends TriggerHandler {
    private List<Property__c> newProperties;

    public PropertyTriggerHandler(){
        this.newProperties = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newProperties, 'ExternalId__c');
    }
}