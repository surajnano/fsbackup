public without sharing class VoiceCallTriggerHandler {
    public static void BeforeInsertEvents(List<VoiceCall> newVCs) {
        PopulateRelatedRecordFromCaller(newVCs);
    }
    
    public static void BeforeUpdateEvents(List<VoiceCall> newVCs, Map<Id, VoiceCall> oldVCs) {
        PopulateRelatedRecordFromCaller(newVCs);
    }
    
    private static void PopulateRelatedRecordFromCaller(List<VoiceCall> newVCs) {
        Map<String, Contact> cMap = new Map<String, Contact>();
        Set<String> toFromNumber = new Set<String>();
        
        for (VoiceCall vc : newVCs) {
            if (vc.CallType == 'Inbound'){
                toFromNumber.add(vc.FromPhoneNumber);
                }
            if (vc.CallType == 'Outbound'){
                toFromNumber.add(vc.ToPhoneNumber);
                }
        }
        
        for (Contact c : [SELECT Id, MobilePhone, AccountId FROM Contact WHERE MobilePhone IN :toFromNumber]) {
            cMap.put(c.MobilePhone, c);
        }

        for (VoiceCall vc : newVCs) {
            if(String.isNotBlank(vc.FromPhoneNumber) && cMap.containsKey(String.valueof(vc.FromPhoneNumber)) && (vc.CallType == 'Inbound')){
                Contact c = cMap.get(vc.FromPhoneNumber);
                
                vc.Account__c = c.AccountId;
                vc.RelatedRecordId = c.Id;
                
            }
            if(String.isNotBlank(vc.ToPhoneNumber) && cMap.containsKey(String.valueof(vc.ToPhoneNumber)) && (vc.CallType == 'Outbound')){
                Contact c = cMap.get(vc.ToPhoneNumber);
                
                vc.Account__c = c.AccountId;
                vc.RelatedRecordId = c.Id;
            }
        }
    }
}