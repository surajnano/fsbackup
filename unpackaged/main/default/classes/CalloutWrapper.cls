public with sharing class CalloutWrapper {
    
    @AuraEnabled
    public static String makeCallout( String serviceName, String guid ){
        
        try {

            HTTPResponse response = OnboardingServices.makeCallout( serviceName, guid );
            return JSON.serialize(
                new Map<String, String>{ 
                    'status' => String.valueOf(response.getStatusCode()),
                    'message' => response.getBody()
                }
            );

        } catch (Exception e) {
            return JSON.serialize(
                new Map<String, String>{ 
                    'status' => '500',
                    'message' => e.getMessage()
                }
            );
        }
            
        
    }


    @AuraEnabled(cacheable=true)
    public static Integer getCalloutIntervalWait(){
        ApplicationSettings__c appSettings = ApplicationSettings__c.getOrgDefaults();
        return Integer.valueOf(appSettings.CalloutIntervalWait__c);
    }

    @AuraEnabled
    public static sObject getLatestRecord(String objectName, String fields, String filter){
        
        String query = 'SELECT ' + fields + ' FROM ' + objectName + getFilter(filter) + ' ORDER BY LastModifiedDate DESC LIMIT 1';
        system.debug(query);
        List<sObject> records = Database.query(query);
        system.debug(records);
        if(records.isEmpty())
            return null;
        else 
            return records[0];

    }

    private static String getFilter(String filter){
        return filter != null ? ' WHERE ' + filter : '';
    }



}