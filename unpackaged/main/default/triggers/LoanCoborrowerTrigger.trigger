/**
 * Created by Muhammad on 12/11/20.
 */

trigger LoanCoborrowerTrigger on loan__Coborrower__c (after insert, after delete) {
    new LoanCoborrowerTriggerHandler().run();

}