public with sharing class ExceptionLogTriggerHandler extends TriggerHandler {
    
    private Map<Id, ExceptionLog__c> newExceptionsMap;

    public ExceptionLogTriggerHandler(){
        this.newExceptionsMap = (Map<Id, ExceptionLog__c>) Trigger.newMap;
    }

    public override void afterInsert() {
        
        ExceptionLogTriggerHandler.createApplicationTasks( this.newExceptionsMap.keyset() );

    }


    @future
    private static void createApplicationTasks( Set<Id> exceptionIds ){
        List<Task> newTasks = new List<Task>();
        Set<String> exceptionCodes = new Set<String>();

        List<ExceptionLog__c> newExceptions = [ SELECT   Id, ExceptionCode__c, Application__c, Application__r.OwnerId 
                                                FROM     ExceptionLog__c 
                                                WHERE    ID = :exceptionIds 
                                                ORDER BY ExceptionCode__c];

        
        for( ExceptionLog__c e : newExceptions )
            exceptionCodes.add( e.ExceptionCode__c );
        
        if(!exceptionCodes.isEmpty()){
            
            List<TaskTemplate__c> taskTemplates = [ SELECT  ID, ApplicationChecklistConfiguration__r.ExceptionCode__c, Subject__c, Priority__c, Description__c, DueIn__c
                                                    FROM    TaskTemplate__c
                                                    WHERE   ApplicationChecklistConfiguration__r.ExceptionCode__c in :exceptionCodes
                                                    ORDER BY ApplicationChecklistConfiguration__r.ExceptionCode__c ];

            for( ExceptionLog__c exc : newExceptions )
                for( TaskTemplate__c taskTemplate : taskTemplates )
                    if( exc.ExceptionCode__c == taskTemplate.ApplicationChecklistConfiguration__r.ExceptionCode__c ) {
                        newTasks.add( 
                            new Task( 
                                WhatId = exc.Application__c,
                                OwnerId = exc.Application__r.OwnerId,
                                Subject = taskTemplate.Subject__c,
                                Description = taskTemplate.Description__c,
                                Priority = taskTemplate.Priority__c,
                                ActivityDate = System.today().addDays( Integer.valueOf( taskTemplate.DueIn__c ) ),
                                Status = 'Not Started'
                            )    
                        );
                    }
                
            
            system.debug( newTasks );
            insert newTasks;


        }
        

    }
    

}