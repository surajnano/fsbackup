trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after undelete) {
    new AccountTriggerHandler().run();
}