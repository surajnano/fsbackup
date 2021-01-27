global class ConvertAppToContractHandler{

    Id appID;
    Map<String, Schema.SObjectType> gd;
    List<sObject> recordsToInsert;
    List<sObject> tempList;
    List<loan__Multi_Step_Loan_Setup__c> rateList;
    loan__Loan_Account__c lai;
    global ConvertAppToContractHandler(Application__c Application,
                                       List<Conversion_Mapping__c> MappingDetails){
        gd = Schema.getGlobalDescribe();
        appID = Application.id;
        recordsToInsert = new List<sObject>();
        tempList        = new List<sObject>();
        lai = new loan__Loan_Account__c();
        List<Conversion_Mapping__c> childMappingDetails = new List<Conversion_Mapping__c>();
        List<Conversion_Mapping__c> defaultMapping      = new List<Conversion_Mapping__c>();
        List<Conversion_Mapping__c> rateScheduleMapping = new List<Conversion_Mapping__c>();
        
        for(Conversion_Mapping__c cm :MappingDetails){
            if(cm.Parent_Object__c == null && cm.Default_Value__c == null){
                //populate Loan Account fields
                
                lai.put(cm.Target_Field__c, Application.get(cm.Source_Field__c));
            }else if(cm.Default_Value__c == null && cm.Target_Object__c != 'loan__Multi_Step_Loan_Setup__c'){
                childMappingDetails.add(cm);
            }else if(cm.Target_Object__c == 'loan__Multi_Step_Loan_Setup__c'){
                rateScheduleMapping.add(cm);
            }
            else{
                defaultMapping.add(cm);
            }
        }
        
        Map<String, List<Conversion_Mapping__c>> sourceObjectToMapping = new Map<String, List<Conversion_Mapping__c>>();
        Map<String, List<Conversion_Mapping__c>> sourceRateObjectMap   = new Map<String, List<Conversion_Mapping__c>>();
        for(Conversion_Mapping__c cm :childMappingDetails){
            if(sourceObjectToMapping.containsKey(cm.Source_Object__c)){
                sourceObjectToMapping.get(cm.Source_Object__c).add(cm);
            }else{
                sourceObjectToMapping.put(cm.Source_Object__c, new List<Conversion_Mapping__c>{cm});
            }
        }
        for(Conversion_Mapping__c cm :rateScheduleMapping){
            if(sourceRateObjectMap.containsKey(cm.Source_Object__c)){
                sourceRateObjectMap.get(cm.Source_Object__c).add(cm);
            }else{
                sourceRateObjectMap.put(cm.Source_Object__c, new List<Conversion_Mapping__c>{cm});
            }
        }
        
        for(String key :sourceRateObjectMap.keySet()){
            List<Conversion_Mapping__c> cmForChildObjects = sourceRateObjectMap.get(key);
            createChildInstances(cmForChildObjects);
        }
        
        loan.BorrowerAPI1 bAPI = loan.APIFactory.getBorrowerAPI1();
        
        lai = bAPI.createContract(lai, null, rateList);
        loan__Loan_Account__c requeryLAI = [Select id, loan__Loan_Status__c from loan__Loan_Account__c where id =:lai.id];
        requeryLAI.loan__Loan_Status__c = 'Approved';
        update requeryLAI;
        Application.CL_Contract__c = lai.id;
        
        update Application;
        //Create a disbursal transaction.   
         loan__Payment_Mode__c pMode = [Select Id,Name from loan__Payment_Mode__c Where Name = 'ACH'];
         loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
         loan.GlobalLoanUtilFacade glu = new loan.GlobalLoanUtilFacade();
        
         disbTxn.loan__Disbursal_Date__c     = glu.getCurrentSystemDate();
         disbTxn.loan__Disbursed_Amt__c      = lai.loan__Loan_Amount__c;
         disbTxn.loan__Loan_Account__c       = lai.id;
         disbTxn.loan__Mode_of_Payment__c    =  pMode.id;
         loan.LoanDisbursalActionAPI api     = new loan.LoanDisbursalActionAPI(disbTxn);
         api.disburseLoanAccount();
        
        for(String key :sourceObjectToMapping.keySet()){
            List<Conversion_Mapping__c> cmForChildObjects = sourceObjectToMapping.get(key);
            createChildInstances(cmForChildObjects);
        }
        
        System.debug('recordsToInsert.size' + recordsToInsert.size());
        insert recordsToInsert;
        
        handleDefaults(lai, defaultMapping);
    }
    
    global void createChildInstances(List<Conversion_Mapping__c> cmForChildObjects){
        SObjectType currentObject     = gd.get(cmForChildObjects[0].Source_Object__c);
        List<sObject> childRecords    = getRecords(cmForChildObjects[0].Source_Object__c, cmForChildObjects[0].Filter_Criteria__c, appID);
        Schema.SObjectType targetType = gd.get(cmForChildObjects[0].Target_Object__c);
        if(childRecords.size() > 0){
            for(sObject childRecord :childRecords){
                sObject obj               = targetType.newSObject();
                for(Conversion_Mapping__c cm :cmForChildObjects){
                    if(cm.Mandatory__c && childRecord.get(cm.Source_Field__c) == null){
                        system.debug('Value of the mandatory field ' + cm.Source_Field__c + ' is null');
                        throw new IllegalArgumentException('Value of the mandatory field ' + cm.Source_Field__c + ' is null');
                    }
                    obj.put(cm.Target_Field__c, childRecord.get(cm.Source_Field__c));
                }
                obj.put(cmForChildObjects[0].Parent_Object__c, lai.id);
                tempList.add(obj);           
            }if(cmForChildObjects[0].Target_Object__c == 'loan__Multi_Step_Loan_Setup__c'){
                rateList = new List<loan__Multi_Step_Loan_Setup__c>();
                rateList.addAll((List<loan__Multi_Step_Loan_Setup__c>)tempList);
                tempList.clear();
            }else{
                recordsToInsert.addAll(tempList);
                tempList.clear();
            }
        }else{
            system.debug(cmForChildObjects[0].Source_Object__c + ' not defined on application');
            throw new IllegalArgumentException(cmForChildObjects[0].Source_Object__c + ' not defined on application');
        }
        
    }
    
    global void handleDefaults(loan__Loan_Account__c newLoanAccount, List<Conversion_Mapping__c> defaultMapping){
        List<loan__Loan_Account__c> loanAccount = (List<loan__Loan_Account__c>)getRecords('loan__Loan_Account__c', 'id', newLoanAccount.id);
        gd = Schema.getGlobalDescribe();
        SObjectType currentObject = gd.get('loan__Loan_Account__c');
        Map<String, Schema.SObjectField> allFields = currentObject.getDescribe().fields.getMap();
        
        //create deposit
        clcommon__Deposit__c deposit                  = new clcommon__Deposit__c();
        deposit.loan__Loan_Account__c                 = loanAccount[0].id;
        deposit.clcommon__Account__c                  = loanAccount[0].loan__Account__c;
        deposit.clcommon__Current_Deposit_Amount__c   = 0;
        deposit.clcommon__Transaction_Date__c         = loanAccount[0].loan__Disbursal_Date__c;
        deposit.clcommon__Deposit_Amount__c           = 0;
        deposit.clcommon__Deposit_Rate__c             = loanAccount[0].loan__Contractual_Interest_Rate__c;
        deposit.clcommon__Current_Deposit_Rate__c     = loanAccount[0].loan__Interest_Rate__c;
        deposit.clcommon__Sequence__c                 = 1;
        deposit.clcommon__Priority__c                 = 1;
        insert deposit;

        //Create loan parameter
        loan__Loan_Parameters__c loan = new loan__Loan_Parameters__c();
        loan.loan__Auto_Change_Deposit_Rate__c = true;
        insert loan;
        //add loan parameter id to account
        loanAccount[0].loan__Loan_Parameters__c = loan.Id;
        
        for(Conversion_Mapping__c cm :defaultMapping){
            String fieldName = cm.Target_Field__c;
            Schema.DisplayType fielddataType = allFields.get(fieldName).getDescribe().getType();
            if(fielddataType.name() == 'STRING'){
                loanAccount[0].put(fieldName, (string)cm.Default_Value__c);
            }else if(fielddataType.name() == 'DOUBLE'){
                loanAccount[0].put(fieldName, Double.valueOf(cm.Default_Value__c));
            }
        }
        update loanAccount;
    }
    
    global List<sObject> getRecords(String objectName, String FilterField, Id recordId){
        mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
        mfiflexUtil.ObjectCache rehashMetricsData = ec.getObject(objectName);
        mfiflexUtil.ObjectCache entries = ec.createObject(objectName, objectName, true);
        SObjectType currentObject = Schema.getGlobalDescribe().get(objectName);
        if (rehashMetricsData != null) {
            ec.deleteObject(objectName);
        }
        Map<String, Schema.SObjectField> allFields = currentObject.getDescribe().fields.getMap();
        for(String field: allFields.keyset()) {
            entries.addFields(field);
        }
        entries.addNamedParameter('appId', recordId);
        entries.setWhereClause(FilterField +' = :appId');
        entries.buildQuery();
    
        System.debug('Dynamic Query :'+ entries.getQuery());
        return entries.executeQuery().getRecords();
    }

    @InvocableMethod ( label='Create Disbursement Transaction' description='Creates disbursements for given loan accounts' category='Loan Account' )
    public static void createDisbursementTransaction(List<loan__Loan_Account__c> loanAccounts){

        try {
            
            loan__Payment_Mode__c pMode = [Select Id,Name from loan__Payment_Mode__c Where Name = 'ACH'];  

            for(loan__Loan_Account__c la : loanAccounts){                         
                loan__Loan_Disbursal_Transaction__c disbTxn = new loan__Loan_Disbursal_Transaction__c();
                loan.GlobalLoanUtilFacade glu = new loan.GlobalLoanUtilFacade();
                
                disbTxn.loan__Disbursal_Date__c     = glu.getCurrentSystemDate();
                disbTxn.loan__Disbursed_Amt__c      = la.loan__Loan_Amount__c;
                disbTxn.loan__Loan_Account__c       = la.id;
                disbTxn.loan__Mode_of_Payment__c    =  pMode.id;
                loan.LoanDisbursalActionAPI api     = new loan.LoanDisbursalActionAPI(disbTxn);
                api.disburseLoanAccount();

            }
            
        } catch (Exception e){
            System.debug(e);
        }

    }

}