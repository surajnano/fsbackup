public with sharing class ChildController {
   
    @AuraEnabled
    public static sObject getLatestRecord(String objectName, String fields, String filter){
        
        //String responseBody = OnboardingServices.orderValuation( '' );
        //system.debug(responseBody);

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