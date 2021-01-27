trigger Lpttrigger on loan__Loan_Payment_Transaction__c (before insert) { 
    new Lpttriggerhandler().run();
}