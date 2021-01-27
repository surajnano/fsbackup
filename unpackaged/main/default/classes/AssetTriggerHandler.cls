public with sharing class AssetTriggerHandler extends TriggerHandler {

    private List<Asset__c> newAssets;

    public AssetTriggerHandler(){
        this.newAssets = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newAssets, 'ExternalId__c');
    }
        
}