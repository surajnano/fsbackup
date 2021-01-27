public with sharing class ApplicationBankAccountTriggerHandler extends TriggerHandler {
    private List<ApplicationBankAccount__c> newAppBankAccounts;

    public ApplicationBankAccountTriggerHandler(){
        this.newAppBankAccounts = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newAppBankAccounts, 'ExternalId__c');
    }

}