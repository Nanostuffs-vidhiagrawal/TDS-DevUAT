trigger EI_AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    
    EI_TriggerDispatcher.Run(new EI_AccountTriggerHandler());
    
}