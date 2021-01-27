public with sharing class VertevaUtils {

    public static final String FORMATTED_PHONE_NUMBER = 'formattedPhoneNumber';
    public static final String PHONE_NUMBER_ERROR = 'phoneNumberError';

    public static void setUUID(List<sObject> records, String externalIdAPIName){
        try {
            if(!isCurrentAPIUser())
                for(sObject record : records)
                    record.put(externalIdAPIName, generateUUID());
        } catch (Exception e){
            system.debug(e);
        }

    }

    public static boolean isCurrentAPIUser(){
        return [SELECT isAPIUser__c FROM User WHERE ID = :UserInfo.getUserId()].isAPIUser__c;
    }


    @AuraEnabled(cacheable=true)
    public static String getSerializedPicklistValues(String objectApiName, String fieldApiName){

        return JSON.serialize( getPicklistValues(objectApiName, fieldApiName) );

    }


    public static List<Schema.PicklistEntry> getPicklistValues(String objectApiName, String fieldApiName){
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectApiName);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String,Schema.SObjectField> fieldMap = r.fields.getMap();
        return fieldMap.get(fieldApiName).getDescribe().getPicklistValues();
    }


    public static boolean isEmpty(Object obj){
        return obj == null || ((String) obj).length() == 0;
    }


    
    public static String generateUUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }


    public static String formatPhoneNumber(String phone, noltic_libphone.PhoneNumberUtil.PhoneNumberFormat format){
        noltic_libphone.PhoneNumberUtil phoneUtil = noltic_libphone.PhoneNumberUtil.getInstance();
        try {
            noltic_libphone.PhoneNumber phoneNumber = phoneUtil.parse(phone, 'AU');
            if( phoneUtil.isValidNumber(phoneNumber) ){
                String formattedPhoneNumber = phoneUtil.format(phoneNumber, format);
                return '{"'+FORMATTED_PHONE_NUMBER+'" : "'+ formattedPhoneNumber +'"}';
            } else 
                return '{"'+PHONE_NUMBER_ERROR+'" : "Not a valid phone number" }';
            
        } catch (Exception e){
            return '{"'+PHONE_NUMBER_ERROR+'" : "' + e.getMessage() + '" }';
        }
    }


    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){

                //if (!sObj.contains('__')) to exclude managed package objects

                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }


}