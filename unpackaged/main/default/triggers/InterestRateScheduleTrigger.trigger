/**
 * Created by muhammadbinmuzaffar on 6/12/20.
 */

trigger InterestRateScheduleTrigger on clcommon__Rate_Schedule__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            InterestRateScheduleTriggerHandler.BeforeInsert(Trigger.new);
        }
    }
}