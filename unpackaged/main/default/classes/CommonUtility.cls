public class CommonUtility {

    //Supported by the fieldSetInput aura component - mapped against a lighting input type
    private static final Map<String, String> SUPPORTED_FIELDS = new Map<String, String>{
            'BOOLEAN' => 'checkbox',
            'CURRENCY' => 'currency',
            'DATE' => 'date',
            'DATETIME' => 'datetime',
            'DOUBLE' => 'number',
            'EMAIL' => 'email',
            'INTEGER' => 'number',
            'LONG' => 'number',
            'PERCENT' => 'percent',
            'PHONE' => 'tel',
            'PICKLIST' => 'picklist',
            'STRING' => 'text',
            'TEXTAREA' => 'textarea',
            'TIME' => 'time',
            'URL' => 'url'
    };
//            'DATACATEGORYGROUPREFERENCE',
//            'ENCRYPTEDSTRING',
//            'ID',
//            'JSON',
//            'LOCATION',
//            'MULTIPICKLIST',
//            'REFERENCE',
//            'SOBJECT',
//            'ADDRESS',
//            'ANYTYPE',
//            'BASE64',
//            'COMBOBOX',
//            'COMPLEXVALUE',

    public static void assignExtraFieldValues(String extraFieldsJSON, SObject sObj) {
        if (extraFieldsJSON != null) {
            List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFieldsJSON);
            for (Object thisFieldObject : extraFieldsList) {
                Map<String, Object> thisField = (Map<String, Object>) thisFieldObject;
                String t = String.valueOf(thisField.get('type'));
                String path = (String) thisField.get('fieldPath');
                switch on t {
                    when 'date' {
                        sObj.put(path, Date.valueOf((String) thisField.get('value')));
                    }
                    when 'datetime' {
                        sObj.put(path, Datetime.valueOf((String) thisField.get('value')));
                    }
                    when 'checkbox' {
                        sObj.put(path, Boolean.valueOf(thisField.get('value')));
                    }
                    when 'currency', 'number', 'percent' {
                        sObj.put(path, Decimal.valueOf((String) thisField.get('value')));
                    }
                    when else {
                        sObj.put(path, thisField.get('value'));
                    }
                }

            }
        }
    }

//    @AuraEnabled
//    public static List<Map<String, Object>> getFieldSetMembers(String fieldSetName, String ObjectName) {
//        return getExtraFields(fieldSetName, ObjectName, null, false, null);
//    }

    /**
     * Used to generate form fields based on field sets set by user
     *
     * @param fieldSetName
     * @param ObjectName
     * @param duplicates
     * @param supportedFieldsOnly
     * @param objectId - pass an id to fetch the values, set to null for net record
     *
     * @return
     */
    @AuraEnabled
    public static String getExtraFields(String fieldSetName, String ObjectName, String[] duplicates, Boolean supportedFieldsOnly, Id objectId) {
        try {
            DataTableDetails dataTableDtls = new DataTableDetails();
            List<FieldSetProperties> lstOfWrapper = new List<FieldSetProperties>();
            Schema.DescribeSObjectResult result = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
            Schema.FieldSet fieldSet = result.fieldSets.getMap().get(fieldSetName);
            Set<String> fieldsApiNames = new Set<String>();

            List<SObject> obj = new List<SObject>();
            if (fieldSet != null) {
                for (Schema.FieldSetMember f : fieldSet.getFields()) {
                    DescribeFieldResult fr = f.getSObjectField().getDescribe();
                    String fieldType = f.getType().name();
                    if ((supportedFieldsOnly && (!fr.isUpdateable() || fr.isEncrypted() || fr.isIdLookup()))
                            || (supportedFieldsOnly && !SUPPORTED_FIELDS.containsKey(fieldType))
                            || (duplicates <> null && !duplicates.isEmpty() && duplicates.contains(f.getFieldPath()))) {
                        continue;
                    }
                    fieldsApiNames.add(f.getFieldPath());
                    FieldSetProperties wrapperIns = new FieldSetProperties();

                    wrapperIns.label = String.valueOf(f.getLabel());
                    wrapperIns.fieldName = String.valueOf(f.getFieldPath());
                    wrapperIns.type = String.valueOf(f.getType()).toLowerCase();

                    lstOfWrapper.add(wrapperIns);
                }
                //If passed an Id get the values in case of an update form
                if (objectId <> null && !fieldsApiNames.isEmpty()) {
                    String queryStr = ' SELECT Id,' + String.join(new List<String>(fieldsApiNames), ',') + ' FROM ' + ObjectName + ' WHERE Application__c =:objectId';
                    System.debug(queryStr);
                    dataTableDtls.lstOfSObjs = Database.query(queryStr);
                }
            }
            for(FieldSetProperties inst : lstOfWrapper){
                dataTableDtls.lstOfFieldLabels.add(inst);
            }
            system.debug(dataTableDtls);
            return JSON.serialize(dataTableDtls);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    }

    public class FieldSetProperties{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
    }

    public class DataTableDetails{
        @AuraEnabled
        public List<sObject> lstOfSObjs = new List<sObject>();
        @AuraEnabled
        public List<FieldSetProperties> lstOfFieldLabels = new List<FieldSetProperties>();
    }

    public static Map<String, RecordTypeInfo> getRecordTypes(SObjectType sObjType) {
        DescribeSObjectResult objectDescribe = sObjType.getDescribe();
        return objectDescribe.getRecordTypeInfosByDeveloperName();
    }
    public static List<Map<String, String>> getPickListMap(String objectName, String fieldName, Boolean addBlankEntry) {
        List<Map<String, String>> items = new List<Map<String, String>>();
        if (addBlankEntry) {
            items.add(new Map<String, String>{
                    'value' => '', 'label' => '--None--'
            });
        }
        Schema.DescribeSObjectResult[] results = Schema.describeSObjects(new List<String>{
                objectName
        });
        for (Schema.DescribeSObjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    items.add(new Map<String, String>{
                            'value' => entry.getValue(), 'label' => entry.getLabel()
                    });
                }
            }
        }
        return items;
    }
    /*
     * This method returns date value in String format.
     * Supported format: DD-MM-YYYY, YYYYMMDD, DDMMYY
     */
    public static String getDateValue(Date dt, String dateFormat){
        try{
            if(dt == null){
                dt = getSystemDate();
            }
            String year = String.valueOf(dt.year());
            String month = dt.month() < 10 ? ('0' + dt.month()) : String.valueOf(dt.month());
            String date1 = dt.day() < 10 ? ('0' + dt.day()) : String.valueOf(dt.day());
 
            String finalDateValue = '';
            switch on dateFormat{
                when 'DD_MM_YYYY'{
                    finalDateValue = (date1 + '/' + month + '/' + year);
                }
                when 'YYYYMMDD'{
                    finalDateValue = (year + month + date1);
                }
                when 'CCYYMMDD'{
                    String ccValue = String.valueOf(Integer.valueOf(year.left(2)) + 1);
                    finalDateValue = (ccValue + year.right(2) + month + date1);
                }
                when 'DDMMYY'{
                    finalDateValue = (date1 + month + year.right(2));
                }
                when else{
                    finalDateValue = String.valueOf(dt);
                }
            }
            System.debug('finalDateValue: ' + finalDateValue);
            return finalDateValue;
        }
        catch(Exception e){
            throw new CustomException('[CommonUtility.getDateValue_DD_MM_YYYY] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }
    }

    public static Date getSystemDate(){
        try{
            loan.GlobalLoanUtilFacade loanUtil = new loan.GlobalLoanUtilFacade();
            return loanUtil.getCurrentSystemDate();
        }
        catch(Exception e){
            throw new CustomException('[CommonUtility.getSystemDate] Exception:' + e.getMessage() + ', at line: ' + e.getLineNumber());
        }
    }

    public class CustomException extends Exception{}
}