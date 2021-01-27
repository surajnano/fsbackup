public with sharing class ExpenseTriggerHandler extends TriggerHandler {

    private List<Expense__c> newExpenses;

    public ExpenseTriggerHandler(){
        this.newExpenses = Trigger.new;
    }

    public override void beforeInsert(){
        VertevaUtils.setUUID(newExpenses, 'ExternalId__c');
    }
        
}