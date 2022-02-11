trigger UpdateTenantsName on Deposit_Allocation__c (after insert,after Update, after delete,after undelete,before update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        DepositAllocationHandler.handleAfterInsert(trigger.newMap);
        DepositAllocationHandler.updateleadTenantNameEmailAfterInsert(trigger.newMap);
    }
    if(Trigger.isafter && Trigger.isUpdate){
        DepositAllocationHandler.handleAfterUpdate(trigger.newMap, trigger.oldMap);
        DepositAllocationHandler.updateleadTenantNameEmailAfterUpdate(trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        DepositAllocationHandler.handleAfterDelete(trigger.oldMap);
    }
    if(Trigger.isafter && Trigger.isUndelete){
        DepositAllocationHandler.handleAfterUndelete(trigger.newMap);
    }
    
  /*  if(Trigger.isAfter && Trigger.isInsert){
        DepositAllocationHandler.updateleadTenantNameEmailAfterInsert(trigger.newMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        DepositAllocationHandler.updateleadTenantNameEmailAfterUpdate(trigger.newMap);
    }*/

}