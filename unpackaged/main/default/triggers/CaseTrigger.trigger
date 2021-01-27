trigger CaseTrigger on Case (before insert, before update, after undelete, before delete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert)
            CaseTriggerHandler.BeforeInsert(Trigger.new);
        else if (Trigger.isUpdate)
            CaseTriggerHandler.BeforeUpdate(Trigger.new);
        else if (Trigger.isDelete)
            CaseTriggerHandler.BeforeDelete(Trigger.old);
    }
    else if (Trigger.isUnDelete){
        CaseTriggerHandler.AfterUnDelete(Trigger.new);
    }
}