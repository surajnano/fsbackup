/**
 * Created by Muhammad on 23/11/20.
 */

trigger LiveChatTranscriptTrigger on LiveChatTranscript (after update) {

    List<Contact> con = new List<Contact>();

    for (LiveChatTranscript ts : Trigger.new) {
       if(ts.LeadId != null){
           system.debug(ts.LeadId);
       }
    }


//    if (Trigger.isAfter) {
//        Set<String> chatKeys = new Set<String>();
//
//        for (LiveChatTranscript transcript : Trigger.new) {
//            if (String.isBlank(transcript.LeadId) && String.isNotBlank(transcript.ChatKey)) {
//                chatKeys.add(transcript.ChatKey);
//            }
//        }
//        System.debug('chatKeys=' + chatKeys);
//
//
//        if (chatKeys.size() > 0) {
//
//            // chat_key__c should be a unique, external id field
//            // populated in the console once the chat has started and case created
//            List<Lead> leads = new List<Lead>([
//                    SELECT
//                            Id, (SELECT Id,ChatKey FROM LiveChatTranscripts WHERE ChatKey = :chatKeys)
//                    FROM
//                            Lead
//                    WHERE Id NOT IN (SELECT LeadId FROM LiveChatTranscript)
//            ]);
//
//
//            List<String> emails = new List<String>();
//            List<String> phones = new List<String>();
//            for (LiveChatTranscript lct : Trigger.new) {
//                if (lct.LeadId != null) {
//                    if (String.isNotBlank(lct.Lead.Email)) {
//                        emails.add(lct.Lead.Email);
//                    }
//                    if (String.isNotBlank(lct.Lead.Phone)) {
//                        phones.add(lct.Lead.Phone);
//                    }
//                }
//            }
//            System.debug(emails);
//            System.debug(phones);
//            Account[] acc = [SELECT Id,PersonEmail,Phone FROM Account WHERE PersonEmail = :emails OR Phone = :phones];
//            System.debug(acc);
//            if (!acc.isEmpty()) {
//                for (LiveChatTranscript transcript : Trigger.new) {
//                    if (transcript.LeadId != null) {
//                        for (Account a : acc) {
//                            if (transcript.Lead.Email.equalsIgnoreCase(a.PersonEmail) || transcript.Lead.Phone.equalsIgnoreCase(a.Phone)) {
//                                transcript.Account = a;
//                                if (transcript.Lead.CreatedDate == Date.today()) {
//                                    transcript.LeadId = null;
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
}