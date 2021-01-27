/**
 * Created by Muhammad on 12/11/20.
 */

public with sharing class LoanCoborrowerTriggerHandler extends TriggerHandler {
   public LoanCoborrowerTriggerHandler() {

        Set<Id> Ids = new Set<Id>();
        if (Trigger.isInsert) {
            for (loan__Coborrower__c l : (List<loan__Coborrower__c>) Trigger.new) {
                if (!Ids.contains(l.loan__Loan__c)) {
                    Ids.add(l.loan__Loan__c);
                }
            }
        } else if (Trigger.isDelete) {
            for (loan__Coborrower__c l : (List<loan__Coborrower__c>) Trigger.old) {
                if (!Ids.contains(l.loan__Loan__c)) {
                    Ids.add(l.loan__Loan__c);
                }
            }
        }
        List<loan__Loan_Account__c> loanAccount = new List<loan__Loan_Account__c>();

        for (loan__Loan_Account__c loanAcc : [
                SELECT
                        Id, (SELECT Id FROM loan__Coborrowers__r)
                FROM loan__Loan_Account__c
                WHERE Id = :Ids
        ]) {
            loanAcc.TotalNoofBorrowers__c = loanAcc.loan__Coborrowers__r.size();
            loanAccount.add(loanAcc);
        }
        try {
            update loanAccount;
        } catch (Exception e) {
            System.debug(e);
        }
    }
}