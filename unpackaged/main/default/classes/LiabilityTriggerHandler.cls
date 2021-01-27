public with sharing class LiabilityTriggerHandler extends TriggerHandler{

    private List<Liability__c> newLiabilities;

    public LiabilityTriggerHandler(){
        this.newLiabilities = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newLiabilities, 'ExternalId__c');
    }
}