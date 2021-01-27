global class BatchUpdateApplicationRates extends clcommon.DynamicJob  {

    global BatchUpdateApplicationRates() {

    }
    global override void doInitialize() {}

    global override void doStart(Database.BatchableContext bc) {
        
    }

    global override void doExecute(System.SchedulableContext sc) {
        
    }
    global override void doExecute(Database.BatchableContext bc, List<SObject> scope) {
        system.debug( '@@@ BatchUpdateApplicationRates @@@' );
        system.debug( scope );

        List<clcommon__Rate_Schedule__c> rates = new List<clcommon__Rate_Schedule__c>();

        for( loan__Floating_Rate_Index__c index : (List<loan__Floating_Rate_Index__c>) scope){
            if( index.loan__Floating_Rates__r != null && !index.loan__Floating_Rates__r.isEmpty()){
                loan__Floating_Rate__c newRate = index.loan__Floating_Rates__r[0];
                system.debug( 'found new rate: ' + newRate );
                for( clcommon__Rate_Schedule__c rateSchedule : index.loan__Interest_Rate_Schedules__r ){
                    if( rateSchedule.clcommon__Interest_Rate__c != newRate.loan__Rate_Percentage__c ){
                        
                        if(rateSchedule.clcommon__Margin_Rate__c == null)
                            rateSchedule.clcommon__Margin_Rate__c  = 0;

                        rateSchedule.clcommon__Interest_Rate__c = newRate.loan__Rate_Percentage__c + rateSchedule.clcommon__Margin_Rate__c;
                        rateSchedule.BaseRate__c = newRate.loan__Rate_Percentage__c;
                        rates.add(rateSchedule);
                    }
                }
            }        
        }
        
        system.debug( rates );
        update rates;

    }
    global override void doFinish(Database.BatchableContext bc) {
        System.enqueueJob( new OnboardingServiceQueueable( 'UpdateApplicationInterestRates' ) );
    }
    

    global override String getRuntimeQuery() {
        loan.GlobalLoanUtilFacade glu = new loan.GlobalLoanUtilFacade();
        String currentSysDate;
        if(Test.isRunningTest())
            currentSysDate = System.now().format( 'yyyy-MM-dd' );
        else
            currentSysDate = DateTime.newInstance( glu.getCurrentSystemDate().year(), glu.getCurrentSystemDate().month(), glu.getCurrentSystemDate().day() ).format( 'yyyy-MM-dd' );

        system.debug( currentSysDate );

        return 'SELECT Id, Name, ' +
                    '  (SELECT id, loan__Rate_Effective_From__c, loan__Rate_Effective_To__c, loan__Rate_Percentage__c ' + 
                    '  FROM   loan__Floating_Rates__r ' +
                    '  WHERE  loan__Active__c = true AND ' +
                             ' loan__Rate_Effective_From__c >= ' + currentSysDate + ' AND ' +
                             ' (loan__Rate_Effective_To__c = null OR loan__Rate_Effective_To__c >= ' + currentSysDate + ' ) ' +
                    '  LIMIT 1 ), ' + 
                    '  (SELECT Id, clcommon__Interest_Rate__c, clcommon__Margin_Rate__c ' + 
                    '  FROM  loan__Interest_Rate_Schedules__r WHERE EffectiveTo__c = null OR EffectiveTo__c >=' + currentSysDate + ')'  +
                'FROM  loan__Floating_Rate_Index__c ' + 
                'WHERE loan__Active__c = true AND ' + 
                      'loan__Archived__c = false';
    }
    global override String getRuntimeQueryForPipelinedExecution(Set<Id> records) {
        return null;
    }


}