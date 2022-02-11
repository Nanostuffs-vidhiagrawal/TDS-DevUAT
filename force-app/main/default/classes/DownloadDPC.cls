public class DownloadDPC {

    public List<Deposit__c> depositList {get;set;}
    public List<Deposit_Allocation__c> depositAllocationList {get;set;}
    public List<Property_Allocation__c> propertyAllocationList{get;set;}

    public DownloadDPC(){
        Id depositId = ApexPages.currentPage().getParameters().get('id');
        depositList = new List<Deposit__c>();
        depositAllocationList = new List<Deposit_Allocation__c>();
        propertyAllocationList = new List<Property_Allocation__c>();
        
        depositList =  [Select id,name,customer__c,Date_Agent_Landlord_Received_Deposit__c,Protection_Start_Date__c,Date_Deposit_Received__c,
                    Amount_of_Deposit_Protected_by_TDS__c,Certificate_Revised_on__c,Property__c,End_Date__c,
                    Property_Address__c,Start_Date__c,Rent_Amount__c,Deposit_Amount__c,Status__c,
                    (Select id,Deposit__c,Role__c,Is_Lead__c, Deposit_Holder__c,Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, 
                    Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Deposit_Holder__r.Phone 
                    from Deposit_Allocations__r where Role__c='Tenant') from Deposit__c where Id=:depositId ];
                    
        if(!depositlist.isEmpty()){
            if(depositlist[0].Deposit_Allocations__r!=null){
                depositAllocationList.addall(depositlist[0].Deposit_Allocations__r);
            }
        }
            
        if(depositlist[0].Property__c!=null){
            propertyAllocationList = [Select Id,Contact__r.Name,Contact__r.Email,Contact__r.Phone from Property_Allocation__c where Property__c=:depositlist[0].Property__c];
        }
    }
}