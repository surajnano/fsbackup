public with sharing class Lpttriggerhandler extends TriggerHandler{
	private List<loan__Loan_Payment_Transaction__c> newlpt;
    
    public Lpttriggerhandler(){
        this.newlpt = trigger.new;
    }
    
      public override void beforeInsert() {
        VertevaUtils.setUUID(newlpt, 'ExternalId__c');
    }
      
}