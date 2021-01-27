trigger LoanApplicationConditionsTrigger on LoanApplicationConditions__c (before insert) {
    new LoanApplicationConditionsTriggerHandler().run();
}