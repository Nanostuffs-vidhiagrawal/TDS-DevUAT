public class EI_AccountTriggerHandler implements EI_TriggerHandler{   
    
    public static Boolean TriggerDisabled = false; 
    
    public Boolean IsDisabled(){
        
        // Uncomment below after creating custom setting for it
        /*if (TriggerSettings__c.AccountTriggerDisabled__c = true)
        return true;
        else*/
        return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems){
        //
        //
        //Call different helper methods from here 
        //
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    public void AfterInsert(Map<Id, SObject> newItems) {}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {} 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}