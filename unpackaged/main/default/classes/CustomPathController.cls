public with sharing class CustomPathController {
    
    @AuraEnabled(cacheable=true)
    public static String getPicklistValues(String objectApiName, String fieldApiName){
        List<PathWrapper> values = new List<PathWrapper>();

        Integer counter = 0;
        for( Schema.PicklistEntry f : VertevaUtils.getPicklistValues(objectApiName, fieldApiName)){
            values.add( new PathWrapper( f.getLabel(), counter == 3 || counter ==  4 ? true : false, counter <= 4 ? true : false, counter == 5 ? true : false ) );
            counter++;
        }
        
        return JSON.serialize( values );

    }

    public class PathWrapper {
        public String status;
        public boolean hasException;
        public boolean isCompleted;
        public boolean isCurrentStep;

        public PathWrapper(String status, boolean hasException, boolean isCompleted, boolean isCurrentStep){
            this.status = status;
            this.hasException = hasException;
            this.isCompleted = isCompleted;
            this.isCurrentStep = isCurrentStep;
        }
    }

}