public class DepositAllocationHandler {

    public static void handleAfterInsert(Map<Id, Deposit_Allocation__c> newItems) {
        Set<Id> setDepositIds = new Set<Id> ();
        for(Deposit_Allocation__c depositAllocation : newItems.values()){
            if(depositAllocation.Deposit_Holder__c!=null && depositAllocation.Role__c=='Tenant'){
                setDepositIds.add(depositAllocation.Deposit__c);
            }
        }
        
        if(!setDepositIds.isEmpty()){
            updateTanantValueOnDeposit(setDepositIds);
        }
    }
    
    public static void handleAfterUpdate(Map<Id, Deposit_Allocation__c> newItems, 
                                                Map<Id, Deposit_Allocation__c> oldItems) {                                                  
        
        Set<Id> setDepositIds = new Set<Id> ();
        for(Deposit_Allocation__c depositAllocation : newItems.values()){
            if(depositAllocation.Deposit_Holder__c!=null && depositAllocation.Role__c=='Tenant' && 
                depositAllocation.Deposit_Holder__c!=olditems.get(depositAllocation.id).Deposit_Holder__c ){
                setDepositIds.add(depositAllocation.Deposit__c);
            }
        }
        
        if(!setDepositIds.isEmpty()){
            updateTanantValueOnDeposit(setDepositIds);
        }
    }
    
    public static void handleAfterDelete(Map<Id, Deposit_Allocation__c> oldItems) {
        Set<Id> setDepositIds = new Set<Id> ();
        for(Deposit_Allocation__c depositAllocation : oldItems.values()){
            if(depositAllocation.Deposit_Holder__c!=null && depositAllocation.Role__c=='Tenant'){
                setDepositIds.add(depositAllocation.Deposit__c);
            }
        }
        
        if(!setDepositIds.isEmpty()){
            updateTanantValueOnDeposit(setDepositIds);
        }
    }
    
    public static void handleAfterUndelete(Map<Id, Deposit_Allocation__c> newItems) {
        Set<Id> setDepositIds = new Set<Id> ();
        for(Deposit_Allocation__c depositAllocation : newItems.values()){
            setDepositIds.add(depositAllocation.Deposit__c);
        }
        
        if(!setDepositIds.isEmpty()){
            updateTanantValueOnDeposit(setDepositIds);
        }
    }
    
    private static void updateTanantValueOnDeposit(Set<Id> setDepositIds) {
        Map<Id,String> mapDepositIdContactName = new Map<Id,String>();
        List<Deposit_Allocation__c> listDepositAllocations = new List<Deposit_Allocation__c>();
        Map<Id,List<Deposit_Allocation__c>> mapDepositIdDepositAllocationList = new Map<Id,List<Deposit_Allocation__c>>();
        List<Deposit__c> listDepositTenantsUpdate = new List<Deposit__c> ();
        for(Deposit__c deposit : [Select id,Tenants_Name__c,(Select id,Deposit__c,Deposit_Holder__r.Name from Deposit_Allocations__r limit 200) 
                                from Deposit__c where Id IN:setDepositIds]){                                    
            mapDepositIdDepositAllocationList.put(deposit.id,deposit.Deposit_Allocations__r);
        }
        
        if(!mapDepositIdDepositAllocationList.isEmpty()){           
            for(Deposit_Allocation__c depositAllocation : [Select id,Deposit__c,Deposit_Holder__r.Name from Deposit_Allocation__c
                                                     where Deposit__c IN:mapDepositIdDepositAllocationList.keyset() 
                                                     and Role__c='Tenant' and Deposit_Holder__c!=null]){
                if(mapDepositIdContactName.containsKey(depositAllocation.Deposit__c)){
                    String contactName = mapDepositIdContactName.get(depositAllocation.Deposit__c);
                    contactName = contactName + ', ' + depositAllocation.Deposit_Holder__r.Name;
                    mapDepositIdContactName.put(depositAllocation.Deposit__c,contactName);
                    system.debug('+++++++mapDepositIdContactName11111+++++++++++'+mapDepositIdContactName);
                    system.debug('+++++++contactName+++++++++++'+contactName);
                }
                else{
                    mapDepositIdContactName.put(depositAllocation.Deposit__c,depositAllocation.Deposit_Holder__r.Name);
                }system.debug('+++++++mapDepositIdContactName+++++++++++'+mapDepositIdContactName);
            }
        }
        
        
        
        if(!mapDepositIdContactName.isEmpty()){
            for(Deposit__c deposit : [Select id,Tenants_Name__c,Number_of_Tenants__c from Deposit__c where id IN:mapDepositIdDepositAllocationList.keyset()]){
                system.debug('+++++++mapDepositIdDepositAllocationList.get(deposit.id)+++++++++++'+mapDepositIdDepositAllocationList.get(deposit.id));
                deposit.Number_of_Tenants__c = mapDepositIdDepositAllocationList.get(deposit.id).size();
                if(mapDepositIdDepositAllocationList.get(deposit.id)==null){
                    deposit.Tenants_Name__c = null;
                }
                else{
                    deposit.Tenants_Name__c = mapDepositIdContactName.get(deposit.id);
                }
                listDepositTenantsUpdate.add(deposit);
            }
            if(!listDepositTenantsUpdate.isEmpty()){
                update listDepositTenantsUpdate;
            }
        }
    }
    
   public static void updateleadTenantNameEmailAfterInsert(Map<Id, Deposit_Allocation__c> newItems) { 
      // system.debug('line-->104');
   list<deposit__c>  updatedepositlist = New list<deposit__c > ();
       for(Deposit_Allocation__c  depall : newItems.values()){
        Deposit__c depo =  new Deposit__c ();
        if(depall.Role__c=='Tenant' && depall.Is_Lead__c == true){
        depo.Id =depall.Deposit__c;
        depo.Lead_Tenant_Name__c = depall.Tenant_Name__c;
        depo.Lead_Tenant_Email__c = depall.Tenant_Email__c;
        updatedepositlist.add(depo);
        } 
       }
       if(updatedepositlist.size()>0){
        Update updatedepositlist ;   
       }
    
   }
      public static void updateleadTenantNameEmailAfterUpdate(Map<Id, Deposit_Allocation__c> newItems) { 
         // system.debug('line-->120');
   list<deposit__c>  updatedepositlist = New list<deposit__c > ();
       for(Deposit_Allocation__c  depall : newItems.values()){
        Deposit__c depo =  new Deposit__c ();
        if(depall.Role__c=='Tenant' && depall.Is_Lead__c == true ){
        depo.Id =depall.Deposit__c;
        depo.Lead_Tenant_Name__c = depall.Tenant_Name__c;
        depo.Lead_Tenant_Email__c = depall.Tenant_Email__c;
        updatedepositlist.add(depo);
        } 
       }
      //  system.debug('line-->132' + updatedepositlist );  
       if(updatedepositlist.size()>0){
        Update updatedepositlist ;   
       }
    
   }
   
    
}