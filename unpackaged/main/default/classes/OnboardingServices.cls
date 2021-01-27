public class OnboardingServices {
    
    /**
     * Wrapper for onboarding services callout. 
     * Replaces the {guid} in url and prepends the host to the endpoint
     */
    public static HttpResponse makeCallout( String serviceName, String guid){

        ApplicationSettings__c appSettings = ApplicationSettings__c.getInstance();
        
        HTTPCalloutService service = new HTTPCalloutService( serviceName );

        //REPLACE GUID 
        if(guid != null && String.isNotEmpty(guid) && service.getEndpointURL() != null && service.getEndpointURL().contains('{guid}'))
            service.setEndpointURL( service.getEndpointURL().replace('{guid}', guid) );

        //PREPEND DOMAIN NAME
        service.setEndpointURL( appSettings.LarryEndpoint__c + service.getEndpointURL() );
        service.setHeaderParameter('Authorization', 'Token ' + appSettings.LarryAPIToken__c);

        system.debug(service.getRequest());

        return service.sendRequest();
        
        

    }

    /**
     * Retrieves all picklists and multipicklists for the given objects
     */
    public static List<ObjectWrapper> getPicklistValuesByObjects( List<String> objectApiNames ) {
        List<ObjectWrapper> response = new List<ObjectWrapper>();

        Set<String> fieldTypes = new Set<String>{'picklist','multipicklist'};
        // Make the describe call
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(objectApiNames);

        for(Schema.DescribeSobjectResult res : results) {

            ObjectWrapper ow = new ObjectWrapper();
            ow.name = res.getName();

            for(sObjectField field : res.fields.getMap().values()){
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if(fieldtypes.contains(fieldDescribe.getType().name().toLowerCase()) ){

                    Field f = new Field(fieldDescribe.getName());

                    List<Schema.PicklistEntry> ple = fieldDescribe.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple)
                        if(pickListVal.isActive())
                            f.entries.add(new PicklistEntry(pickListVal.getLabel(),pickListVal.getValue()));
                    
                    ow.fields.add( f );
                }
                    
            }

            response.add( ow );

                

        }

        return response;

    }



    public class ObjectWrapper{
        public String name;
        public List<Field> fields = new List<Field>();
    }

    public class Field {
        public String name;
        public List<PicklistEntry> entries = new List<PicklistEntry>();
        public Field(String name){
            this.name = name;
        }
    }

    public class PicklistEntry {
        public String label;
        public String value;
        public PicklistEntry(String label, String value){
            this.label = label;
            this.value = value;
        }
    
    }




}