@RestResource(urlMapping='/v1/Application/Enums')
global without sharing class WSApplicationEnums {

    @HTTPGet
    global static void getApplicationEnums(){

        ApplicationSettings__c settings = ApplicationSettings__c.getOrgDefaults();
        RestResponse res = RestContext.response;
        
        if(settings != null && settings.Objects__c != null){
            res.statusCode = 200;
            res.responseBody = Blob.valueOf( JSON.serialize( OnboardingServices.getPicklistValuesByObjects(settings.Objects__c.split(',')) ) );
        } else {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf( 'There\'s an application configuration error in Salesforce.');
        }

        
    }

    
}