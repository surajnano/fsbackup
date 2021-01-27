/**
 * Created by muhammadbinmuzaffar on 6/12/20.
 */

public with sharing class InterestRateScheduleTriggerHandler extends TriggerHandler{

    public static void BeforeInsert(List<clcommon__Rate_Schedule__c> newInterestRateSchedule) {

        clcommon__Rate_Schedule__c[] allIR = [SELECT Id,clcommon__Effective_Date__c, EffectiveTo__c,Name,Property_Purpose__c, Repayment_Type__c FROM clcommon__Rate_Schedule__c];
        for (clcommon__Rate_Schedule__c iR :newInterestRateSchedule){
            for(clcommon__Rate_Schedule__c interest:allIR ){
                if(iR.Repayment_Type__c == interest.Repayment_Type__c && iR.Property_Purpose__c == interest.Property_Purpose__c){
                    if(iR.EffectiveTo__c == interest.clcommon__Effective_Date__c || iR.clcommon__Effective_Date__c == interest.EffectiveTo__c){
                        iR.addError('There exists a Interest Rate Schedule ' +interest.Name + ' with effectivity dates overlapping with this rate. ');
                    }
                }
            }
        }
}
}