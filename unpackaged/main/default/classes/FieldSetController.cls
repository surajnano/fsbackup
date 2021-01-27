public class FieldSetController {
    @AuraEnabled(cacheable = true)
    public static List<FieldSetMember> getFieldSetFieldsByFieldSetName(String objectApiName, String fieldSetName)
    {
        List<Schema.FieldSetMember> fieldSetMembers = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
        List<FieldSetMember> fields = new List<FieldSetMember>();

        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers)
        {
            FieldSetMember fieldSetField = new FieldSetMember(fieldSetMember);
            fields.add(fieldSetField);
        }

        return fields;
    }
}