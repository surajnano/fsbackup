public without sharing class CaseTriggerHandler {

    public static void BeforeInsert(List<Case> newCs) {
    // need to add in a step to fire off default assignment rules for offline chat form
//        runCaseAssignmentRules(newCs);
        PopulateEntitlementsFromAccount(newCs);
    }
    
    public static void BeforeUpdate(List<Case> newCs) {
        PopulateEntitlementsFromAccount(newCs);
    }

    public static void BeforeDelete(List<Case> oldCs) {
        // DeleteActionPlans(oldCs);
    }

    public static void AfterUnDelete(List<Case> newCs) {
        // UnDeleteActionPlans(newCs);
    }

    private static void PopulateEntitlementsFromAccount(List<Case> newCs) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();

        for (Case c : newCs) {
            contactIds.add(c.ContactId);
            acctIds.add(c.AccountId);
        }

        List<Entitlement> entitlementsToClose = new List<Entitlement>();

        List <EntitlementContact> entlContacts = 
            [SELECT EntitlementId, Entitlement.SlaProcess.IsActive, ContactId, Entitlement.AssetId, 
                    Entitlement.StartDate, Entitlement.EndDate
             FROM EntitlementContact
             WHERE ContactId IN :contactIds
                AND (Entitlement.EndDate >= Today OR Entitlement.EndDate = null)
                AND Entitlement.StartDate <= Today];
        if (!entlContacts.isEmpty()) {
            for (Case c : newCs) {
                if (c.EntitlementId == null && c.ContactId != null) {
                    for (EntitlementContact ec : entlContacts) {
                        if (ec.ContactId == c.ContactId) {
                            if (ec.Entitlement.SlaProcess.IsActive) {
                                c.EntitlementId = ec.EntitlementId;
                                if (c.AssetId == null && ec.Entitlement.AssetId != null) {
                                    c.AssetId=ec.Entitlement.AssetId;
                                } 
                            } else {
                                entitlementsToClose.add(ec.Entitlement);
                            }                               
                            break;
                        }
                    } 
                }
            } 
        } else{
            List <Entitlement> entls = 
                [SELECT StartDate, Id, EndDate, AccountId, AssetId, SlaProcess.IsActive
                 FROM Entitlement
                 WHERE AccountId IN :acctIds And (EndDate >= Today OR EndDate = null) 
                    AND StartDate <= Today];
            if (!entls.isEmpty()) {
                for (Case c : newCs) {
                    if (c.EntitlementId == null && c.AccountId != null) {
                        for (Entitlement e : entls) {
                            if (e.AccountId==c.AccountId) {
                                if (e.SlaProcess.IsActive) {
                                    c.EntitlementId = e.Id;
                                    if (c.AssetId == null && e.AssetId != null) {
                                        c.AssetId=e.AssetId;
                                    }                                        
                                } else {
                                    entitlementsToClose.add(e);
                                }
                                break;
                            }
                        } 
                    }
                } 
            }
        }

        List<Case> casesWithoutEntitlements = new List<Case>();
        for (Case c : newCs) {
            if (String.isBlank(c.EntitlementId) && String.isNotBlank(c.AccountId)) {
                casesWithoutEntitlements.add(c);
            }
        }

        if (!entitlementsToClose.isEmpty()) {
            closeEntitlements(entitlementsToClose);
        }

        //creating missing entitlements
        if (!casesWithoutEntitlements.isEmpty()) {
            createMissingEntitlements(casesWithoutEntitlements);
        }

        //deleting inactive entitlements
        // Database.delete([SELECT Id 
        //                  FROM Entitlement 
        //                  WHERE AccountId IN :acctIds AND 
        //                        EndDate != null AND 
        //                        EndDate < TODAY
        //                 ], false);
    }

    private static void closeEntitlements(List<Entitlement> entitlementsToClose) {
        Date today = System.today();
        for (Entitlement e: entitlementsToClose) {
            e.EndDate = e.StartDate == today ? today : today.addDays(-1);
        }
        Database.update(entitlementsToClose, false);
    }

    private static void createMissingEntitlements(List<Case> cases) {
        List<Slaprocess> defEntProcess = [SELECT Id, NAME FROM Slaprocess WHERE IsActive = true LIMIT 1];
        Id defEntProcessId = defEntProcess.size() > 0 ? defEntProcess[0].Id : null;

        List<BusinessHours> defbusHour = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1];
        Id defbusHourId = defbusHour.size() > 0 ? defbusHour[0].Id : null;

        Set<Id> accountIds = new Set<Id>();
        for (Case c : cases) {
            accountIds.add(c.AccountId);
        }

        List<Entitlement> entitlementsToCreate = new List<Entitlement>();
        for (Account a : [SELECT Id, Name, (SELECT Id FROM Entitlements WHERE SlaProcess.IsActive = true) FROM Account WHERE Id IN :accountIds]) {
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

        for (Case c : cases) {
            for (Entitlement e : entitlementsToCreate) {
                if (c.AccountId == e.AccountId) {
                    c.EntitlementId = e.Id;
                    break;
                }
            }
        } 
    }
    
//    private static void runCaseAssignmentRules(List<Case> cases){
//        //Fetching the assignment rules on case
//        AssignmentRule AR = new AssignmentRule();
//        AR = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE LIMIT 1];
//
////Creating the DMLOptions for "Assign using active assignment rules" checkbox
//        Database.DMLOptions dmlOpts = new Database.DMLOptions();
//        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.Id;
//
////Setting the DMLOption on Case instance
//        for(Case c:cases){
//            c.setOptions(dmlOpts);
//        }
//    }

    // private static void DeleteActionPlans(List<Case> oldCs) {
    //     set<ID>  cIds = new set<ID>();
    //     List<String> apIds = new List<String>();
    //     List<ActionPlan__c> deletePermantently_apIds = new List<ActionPlan__c>(); 

    //     for( Case c : oldCs ){
    //         cIds.add( c.Id );
    //     }
        
    //     /* GET Action Plans to delete from recycle bin */
    //     deletePermantently_apIds = [ select Id, Name , LastModifiedDate from ActionPlan__c where Case__c in : cIds and isDeleted = true ALL ROWS ];
        
    //     if ( deletePermantently_apIds.size() >0 ){          
    //         Database.emptyRecycleBin(deletePermantently_apIds);
    //     }           
        
    //     //Get all action plans associated with Campaigns
    //     for( Case a : [Select (Select Id From Action_Plans__r) From Case a where Id in : cIds]){
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

    // private static void UnDeleteActionPlans(List<Case> newCs) {
    //     set<ID> cIds = new set<ID>();

    //     for( Case c : newCs ){
    //         cIds.add( c.Id );
    //     }
    //     list <ActionPlan__c> aPs = [ select Id from ActionPlan__c where Case__c in : cIds ALL ROWS ];
        
    //     try{
    //         if(ActionPlanObjectTriggerTest.isTest){
    //             //throw dmlException
    //             insert new Contact();   
    //         }
    //         //undelete aPs;
    //         Database.undelete( aPs,false);
    //     } catch ( Dmlexception e ){
    //         for (Case c: newCs){
    //             c.addError('You can not undelete an action plan whose related object is deleted.');
    //         }
    //     }  
    // }
}