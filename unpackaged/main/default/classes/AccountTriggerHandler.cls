public with sharing class AccountTriggerHandler extends TriggerHandler {
    
    private List<Account> newAccounts;
    private List<Account> oldAccounts;

    public AccountTriggerHandler(){
        this.newAccounts = Trigger.new;
        this.oldAccounts = Trigger.old;
    }

    public override void beforeInsert(){
        checkPhoneNumber();
        VertevaUtils.setUUID(newAccounts, 'ExternalId__c');
    }

    public override void afterInsert(){
        createMissingEntitlements(); 
    }

    public override void beforeUpdate(){
        checkPhoneNumber();
    }

    public override void afterUpdate(){
        createMissingEntitlements();
    }
    
    public override void beforeDelete(){
        deleteEntitlements();
        // DeleteActionPlans();
    }
    
    public override void afterUndelete(){
        // UnDeleteActionPlans();
    }

    public void checkPhoneNumber(){

        try {
            if(!VertevaUtils.isCurrentAPIUser()){
                for(Account acc : newAccounts){

                    if(acc.PersonMobilePhone != null){
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped( 
                            VertevaUtils.formatPhoneNumber(acc.PersonMobilePhone, noltic_libphone.PhoneNumberUtil.PhoneNumberFormat.E164)
                        );
                        
                        if(responseMap.containsKey(VertevaUtils.FORMATTED_PHONE_NUMBER))
                            acc.PersonMobilePhone = (String.valueOf(responseMap.get(VertevaUtils.FORMATTED_PHONE_NUMBER)));
                        else if(responseMap.containsKey(VertevaUtils.PHONE_NUMBER_ERROR))
                            acc.PersonMobilePhone.addError(String.valueOf(responseMap.get(VertevaUtils.PHONE_NUMBER_ERROR)));
                    }

                    if(acc.Phone != null){
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped( 
                            VertevaUtils.formatPhoneNumber(acc.Phone, noltic_libphone.PhoneNumberUtil.PhoneNumberFormat.E164)
                        );
                        
                        if(responseMap.containsKey(VertevaUtils.FORMATTED_PHONE_NUMBER))
                            acc.Phone = (String.valueOf(responseMap.get(VertevaUtils.FORMATTED_PHONE_NUMBER)));
                        else if(responseMap.containsKey(VertevaUtils.PHONE_NUMBER_ERROR))
                            acc.Phone.addError(String.valueOf(responseMap.get(VertevaUtils.PHONE_NUMBER_ERROR)));
                    }
                }
            }
        }  catch (Exception e){
            system.debug(e);
        }
    }
    
    public void deleteEntitlements(){
        set<ID>  aIds = new set<ID>();
        list<entitlement> entIds = new list<entitlement>();
        list<case> caseIds = new list<case>();
        list<case> c2Ids = new list<case>();
        
        for( Account a : oldAccounts ){
            aIds.add( a.Id );
        }
                  
        //Get all Entitlements associated with Accounts
        for( Account a : [Select (Select Id From Entitlements) From Account a where Id in : aIds]){
            if (a.Entitlements.size() >0 ){
                for(Entitlement e :a.Entitlements ){
                    entIds.add(e);
                }
            }
        }
        if ( entIds.size() >0 ){
            //Get all Cases associated with Entitlements
            
            for( Entitlement ent : [Select (Select Id From Cases) From Entitlement ent where Id in : entIds]){
                if (ent.Cases.size() >0 ){
                    for(Case c :ent.Cases ){
                        caseIds.add(c);
                    }
                }
            }
            if ( caseIds.size() >0 ){
                delete caseIds;
            }
            
            delete entIds;
        }
        //get all cases associated with account directly
        for( Account a : [Select (Select Id From Cases) From Account a where Id in : aIds]){
            if (a.Cases.size() >0 ){
                for(Case c2 :a.Cases ){
                    c2Ids.add(c2);
                }
            }
        }
        if ( caseIds.size() >0 ){
            delete c2Ids;
        }
    }

    // private void DeleteActionPlans() {
    //     set<ID>  aIds = new set<ID>();
    //     List<String> apIds = new List<String>();
    //     List<ActionPlan__c> deletePermantently_apIds = new List<ActionPlan__c>(); 

    //     for( Account a : oldAccounts ){
    //         aIds.add( a.Id );
    //     }
        
    //     /* GET Action Plans to delete from recycle bin */
    //     deletePermantently_apIds = [ select Id, Name , LastModifiedDate from ActionPlan__c where Account__c in : aIds and isDeleted = true ALL ROWS ];
        
    //     if ( deletePermantently_apIds.size() >0 ){          
    //         Database.emptyRecycleBin(deletePermantently_apIds);
    //     }           
        
    //     //Get all action plans associated with Campaigns
    //     for( Account a : [Select (Select Id From Action_Plans__r) From Account a where Id in : aIds]){
    //         if (a.Action_Plans__r.size() >0 ){
    //             for(ActionPlan__c ap :a.Action_Plans__r ){
    //                 apIds.add(ap.Id);
    //             }
    //         }
    //     }
    //     if ( apIds.size() >0 ){
    //         ActionPlansBatchDelete aPBatch = new ActionPlansBatchDelete(apIds, Userinfo.getUserId());
    //         Database.ExecuteBatch( aPBatch );       
    //     }
    // }

    // private void UnDeleteActionPlans() {
    //     set<ID> aIds = new set<ID>();

    //     for( Account a : newAccounts ){
    //         aIds.add( a.Id );
    //     }
    //     list <ActionPlan__c> aPs = [ select Id from ActionPlan__c where Account__c in : aIds ALL ROWS ];
        
    //     try{
    //         if(ActionPlanObjectTriggerTest.isTest){
    //             //throw dmlException
    //             insert new Contact(); 
    //         }
    //         //undelete aPs;
    //         Database.undelete( aPs,false);
    //     } catch ( Dmlexception e ){
    //         for (Account a: newAccounts){
    //             a.addError('You can not undelete an action plan whose related object is deleted.');
    //         }
    //     }  
    // }

    private void createMissingEntitlements() {
        List<Slaprocess> defEntProcess = [SELECT Id, NAME FROM Slaprocess WHERE IsActive = true LIMIT 1];
        Id defEntProcessId = defEntProcess.size() > 0 ? defEntProcess[0].Id : null;

        List<BusinessHours> defbusHour = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
        Id defbusHourId = defbusHour.size() > 0 ? defbusHour[0].Id : null;

        List<Entitlement> entitlementsToCreate = new List<Entitlement>();
        for (Account a : [SELECT Id, Name, (SELECT Id FROM Entitlements) FROM Account WHERE Id IN :newAccounts]) {
            if (a.Entitlements.size() == 0) {
                entitlementsToCreate.add(
                    new Entitlement(
                        Name = a.Name + ' Support Entitlement',
                        AccountId = a.Id,
                        BusinessHoursId = defbusHourId,
                        SlaProcessId = defEntProcessId,
                        StartDate = System.today(),
                        Type = 'Support'
                    )
                );
            }
        }

        Database.insert(entitlementsToCreate, false);
    }
}