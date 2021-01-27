trigger VoiceCallTrigger on VoiceCall (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert)
            VoiceCallTriggerHandler.BeforeInsertEvents(Trigger.new);
        else if (Trigger.isUpdate)
            VoiceCallTriggerHandler.BeforeUpdateEvents(Trigger.new, Trigger.oldMap);
    }
}