global class ConvertAppToContractCtlr{

    @InvocableMethod(label='Convert Application' description='Convert a given application id to a Loan Account' category='Application')
    public static void convertApplication(List<ID> ids) {

        if(ids != null && !ids.isEmpty())
            new ConvertAppToContractCtlr(ids.get(0));
        

    }
    
    global ConvertAppToContractCtlr(Id ApplicationId){
        //initialize Application data and mapping data
        List<Conversion_Mapping__c> conversionMappings = [Select id,Name,
                                                                Mandatory__c,
                                                                Parent_Object__c,
                                                                Source_Field__c,
                                                                Source_Object__c,
                                                                Target_Field__c,
                                                                Target_Object__c,
                                                                Default_Value__c,
                                                                Filter_Criteria__c
                                                           From Conversion_Mapping__c];
        //validate conversion mapping
        if(conversionMappings.size() > 0){
            
            if(validateConversionMapping(conversionMappings)){
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                SObjectType currentObject = gd.get('Application__c');
                Map<String, Schema.SObjectField> allFields = currentObject.getDescribe().fields.getMap();
                mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
                mfiflexUtil.ObjectCache entries = ec.createObject('Application', 'Application__c', true);
                for(String field: allFields.keyset()) {
                entries.addFields(field);
                }
                entries.addNamedParameter('appID', ApplicationId);
                entries.setWhereClause('Id = :appID');
                entries.buildQuery();
    
                System.debug('Dynamic Query :'+ entries.getQuery());
                Application__c applicationinstance = ((List<Application__c>) entries.executeQuery().getRecords()).get(0);
                
                //calling the handler class
                ConvertAppToContractHandler handler = new ConvertAppToContractHandler(applicationinstance, conversionMappings);              
            }
        }else{
            system.debug('Conversion mapping doesn\'t exist');
            throw new IllegalArgumentException('Conversion mapping doesn\'t exist');
        }
    }    
        global Boolean validateConversionMapping(List<Conversion_Mapping__c> conversionMapping){
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Conversion_Mapping__c cm :conversionMapping){
                if(cm.Default_Value__c == null && (cm.Source_Object__c == null || cm.Target_Object__c == null || cm.Source_Field__c == null || cm.Target_Field__c == null)){
                    //this should not arise
                    
                    system.debug('Value not defined properly, please check the mapping named:' + cm.Name);
                        throw new IllegalArgumentException('Value not defined properly, please check the mapping named:' + cm.Name);
                }else{
                    if(cm.Default_Value__c == null && !gd.containsKey(cm.Source_Object__c)){
                        //this should not arise
                        system.debug('Value not defined properly, please check the source object name for mapping named:' + cm.Name);
                        throw new IllegalArgumentException('Value not defined properly, please check the source object name for mapping named:' + cm.Name);
                    }else if(cm.Default_Value__c == null){
                        SObjectType currentObject = gd.get(cm.Source_Object__c);
                        Map<String, Schema.SObjectField> allFields = currentObject.getDescribe().fields.getMap();
                        if(!allFields.keySet().contains(cm.Source_Field__c.toLowerCase())){
                            system.debug(currentObject);
                            system.debug(allFields.keySet());
                            system.debug('Value not defined properly, please check the source field name for mapping named:' + cm.Name);
                            throw new IllegalArgumentException('Value not defined properly, please check the source field name for mapping named:' + cm.Name);
                        }
                    }
                    if(!gd.containsKey(cm.Target_Object__c)){
                        //this should not arise
                        system.debug('Value not defined properly, please check the target object name mapping named:' + cm.Name);
                        throw new IllegalArgumentException('Value not defined properly, please check the mapping');
                    }else{
                        SObjectType currentObject = gd.get(cm.Target_Object__c);
                        Map<String, Schema.SObjectField> allFields = currentObject.getDescribe().fields.getMap();
                        if(!allFields.keySet().contains(cm.Target_Field__c.toLowerCase())){
                            system.debug('Value not defined properly, please check the source field name for mapping named:' + cm.Name);
                            throw new IllegalArgumentException('Value not defined properly, please check the source field name for mapping named:' + cm.Name);
                        }
                    }
                }    
        }
        return true;
    }    
}