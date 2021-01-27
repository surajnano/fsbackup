public with sharing class ApplicationInterestRateTriggerHandler extends TriggerHandler {
    private List<ApplicationInterestRate__c> newAppIntRate;

    public ApplicationInterestRateTriggerHandler(){
        this.newAppIntRate = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newAppIntRate, 'ExternalId__c');
    }
}