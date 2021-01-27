public class GenerateUUID {
    
    public static  void createuuid(List<id> sobjectid){
        List <loan__Loan_Payment_Transaction__c> records = [Select id, externalId__c from loan__Loan_Payment_Transaction__c where id IN :sobjectid];
        For (loan__Loan_Payment_Transaction__c lpt : records){
            lpt.put(lpt.ExternalId__c, VertevaUtils.generateUUID());
        }
        
    }
    @invocablemethod
    public static List<string> createguid(List<string> esternalids){
        List <string> eid = new List<string>();
        For(string externalid : esternalids){
            If (string.isblank(externalid)){
                externalid = VertevaUtils.generateUUID();
                eid.add(externalid);
            }
            
        }
        return eid;
    }
}