/**
 * Created by Muhammad on 24/11/20.
 */

public without sharing class InteractionsHistoryController {
    @AuraEnabled
    public static String getAllCases(String accountId) {
        Case[] c = [
                SELECT Id,
                        CreatedDate,
                        LastModifiedDate,
                        Description, (
                        SELECT Id,
                                Description,
                                Subject,
                                DurationInMinutes,
                                CreatedDate,
                                ActivitySubtype
                        FROM ActivityHistories
                        WHERE ActivitySubtype = 'call'
                        OR ActivityType = 'call'
                        ORDER BY CreatedDate DESC
                ), (
                        SELECT Id,
                                Incoming,
                                CreatedDate,
                                LastModifiedDate
                        FROM EmailMessages
                        ORDER BY CreatedDate DESC
                ), (
                        SELECT Id,
                                CreatedDate
                        FROM LiveChatTranscripts
                        ORDER BY CreatedDate DESC
                ), (
                        SELECT Id,
                                CreatedDate
                        FROM
                                Voice_Calls__r
                        ORDER BY
                                CreatedDate DESC
                ),
                        AccountId
                FROM Case
                WHERE AccountId = :accountId
                ORDER BY CreatedDate DESC
                LIMIT 500
        ];

        LiveChatTranscript[] chatsWithoutCase = [SELECT Id,CreatedDate FROM LiveChatTranscript WHERE AccountId = :accountId AND (CaseId=NULL OR CaseId='')];
        VoiceCall[] voiceCallsWithoutCase = [SELECT Id,CreatedDate FROM VoiceCall WHERE Account__c=:accountId AND (Case__c=NULL OR Case__c='')];
        EmailMessage[] emailMessages = [SELECT Id,
                Incoming,
                CreatedDate,
                LastModifiedDate FROM EmailMessage WHERE RelatedToId=:accountId];



        List<caseWithAllRelatedSobjectsWrapper> wrapCasesWithRelatedRecords = new List<caseWithAllRelatedSobjectsWrapper>();
        for (Case ca : c) {
            List<SObjectWrapper> wrapRecords = new List<SObjectWrapper>();
            for (EmailMessage ax : ca.EmailMessages) {
                wrapRecords.add(new SObjectWrapper(ax,true,false,false,false));
            }
            for (ActivityHistory activity : ca.ActivityHistories) {
                wrapRecords.add(new SObjectWrapper(activity,false, true,false,false));
            }
            for (LiveChatTranscript chat : ca.LiveChatTranscripts) {
                wrapRecords.add(new SObjectWrapper(chat,false, false,true,false));
            }
            for(VoiceCall callRecord: ca.Voice_Calls__r){
                wrapRecords.add(new SObjectWrapper(callRecord,false, false,false,true));
            }
            wrapRecords.sort();
            wrapCasesWithRelatedRecords.add(new caseWithAllRelatedSobjectsWrapper(ca,wrapRecords,false, false,false,false,true));
        }


        for(LiveChatTranscript lc:chatsWithoutCase){
            wrapCasesWithRelatedRecords.add(new caseWithAllRelatedSobjectsWrapper(lc,false, false,true,false,false));
        }
        for(EmailMessage em: emailMessages){
            wrapCasesWithRelatedRecords.add(new caseWithAllRelatedSobjectsWrapper(em,true, false,false,false,false));
        }
        for(VoiceCall vc: voiceCallsWithoutCase){
            wrapCasesWithRelatedRecords.add(new caseWithAllRelatedSobjectsWrapper(vc,false, false,false,true,false));
        }
        wrapCasesWithRelatedRecords.sort();
        return JSON.serialize(wrapCasesWithRelatedRecords);
    }

    public class SObjectWrapper implements Comparable {
        public SObject record { get; set; }
        public Boolean isEmail{get; set;}
        public Boolean isActivity{get; set;}
        public Boolean isLiveChat{get; set;}
        public Boolean isVoiceCall{get; set;}
        public SObjectWrapper(SObject record, Boolean email,Boolean activity, Boolean livechat, Boolean voiceCall) {
            this.record = record;
            this.isEmail = email;
            this.isActivity = activity;
            this.isLiveChat = livechat;
            this.isVoiceCall = voiceCall;
        }
        public Integer compareTo(Object recordParam) {
            SObjectWrapper compareToObj = (SObjectWrapper) recordParam;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            Datetime currentRecDate = (Datetime) this.record.get('CreatedDate');
            Datetime compareDate = (Datetime) compareToObj.record.get('CreatedDate');
            if (currentRecDate > compareDate) {
                returnValue = -1;
            } else if (currentRecDate < compareDate) {
                returnValue = 1;
            }
            return returnValue;
        }
    }
    public class caseWithAllRelatedSobjectsWrapper implements Comparable{
        public SObject sobjectAny { get; set; }
        public Datetime CreatedDate { get; set; }
        public List<SObjectWrapper> relatedListRecords { get; set; }
        public Boolean isEmail{get; set;}
        public Boolean isCase{get; set;}
        public Boolean isActivity{get; set;}
        public Boolean isLiveChat{get; set;}
        public Boolean isVoiceCall{get; set;}
        public caseWithAllRelatedSobjectsWrapper(SObject c, List<SObjectWrapper> relatedSObjects,Boolean isItEmail,Boolean activity, Boolean livechat, Boolean voiceCall,Boolean isItCase) {
            sobjectAny = c;
            this.sobjectAny = c;
            this.isEmail = isItEmail;
            this.isActivity = activity;
            this.isLiveChat = livechat;
            this.isVoiceCall = voiceCall;
            this.isCase = isItCase;
            relatedListRecords = relatedSObjects;
            CreatedDate = (Datetime) c.get('CreatedDate');
        }
        public caseWithAllRelatedSobjectsWrapper(SObject c,Boolean isItEmail,Boolean activity, Boolean livechat, Boolean voiceCall,Boolean isItCase) {
            sobjectAny = c;
            this.sobjectAny = c;
            this.isEmail = isItEmail;
            this.isActivity = activity;
            this.isLiveChat = livechat;
            this.isVoiceCall = voiceCall;
            this.isCase = isItCase;
            relatedListRecords = new List<SObjectWrapper>();
            CreatedDate = (Datetime) c.get('CreatedDate');
        }
        public Integer compareTo(Object recordParam) {
            caseWithAllRelatedSobjectsWrapper compareToObj = (caseWithAllRelatedSobjectsWrapper) recordParam;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            Datetime currentRecDate = (Datetime) this.sobjectAny.get('CreatedDate');
            Datetime compareDate = (Datetime) compareToObj.sobjectAny.get('CreatedDate');
            if (currentRecDate > compareDate) {
                returnValue = -1;
            } else if (currentRecDate < compareDate) {
                returnValue = 1;
            }
            return returnValue;
        }
    }
}