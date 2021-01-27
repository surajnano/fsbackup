public without sharing class BatchUpdateLoanAccountRates implements Database.Batchable<SObject> {

    public String query;
    public Boolean maintainDeliquencyFlag;
    public Decimal marginRate;
    public Date effectiveDate;
    public Integer dueDay;
    private Decimal marginRateAfterDiscount;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<loan__Loan_Account__c> loanAccounts) {

        for (loan__Loan_Account__c loanAccount : loanAccounts) {
            if (loanAccount.DiscountRate__c != null && loanAccount.Discount__c) {
                marginRateAfterDiscount = marginRate - loanAccount.DiscountRate__c;
                BulkRescheduleAction.RescheduleLoanAction(loanAccount.Id, maintainDeliquencyFlag, marginRateAfterDiscount, effectiveDate, Integer.valueOf(loanAccount.loan__Due_Day__c));
            }else{
                BulkRescheduleAction.RescheduleLoanAction(loanAccount.Id, maintainDeliquencyFlag, marginRate, effectiveDate, Integer.valueOf(loanAccount.loan__Due_Day__c));
            }
        }
    }
    public void finish(Database.BatchableContext BC) {
    }
}