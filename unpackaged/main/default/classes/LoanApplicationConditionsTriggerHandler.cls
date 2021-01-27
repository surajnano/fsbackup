public with sharing class LoanApplicationConditionsTriggerHandler extends TriggerHandler {
    private List<LoanApplicationConditions__c> newLoanAppConditions;

    public LoanApplicationConditionsTriggerHandler(){
        this.newLoanAppConditions = Trigger.new;
    }

    public override void beforeInsert() {
        VertevaUtils.setUUID(newLoanAppConditions, 'ExternalId__c');
    }
}