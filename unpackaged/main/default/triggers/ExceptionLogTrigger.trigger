trigger ExceptionLogTrigger on ExceptionLog__c (after insert) {

    new ExceptionLogTriggerHandler().run();

}