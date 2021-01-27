public with sharing class IncomeTriggerHandler extends TriggerHandler {

    private List<Income__c> newIncomes;

    public IncomeTriggerHandler(){
        this.newIncomes = Trigger.new;
    }

    public override void beforeInsert(){
        VertevaUtils.setUUID(newIncomes, 'ExternalId__c');
    }
        
}