public class DPCController{
    
    public List<Deposit__c> deptList{get;set;}
    public Deposit__c deptObj {get;set;}
    
   //  public Deposit_Allocations__c  deptalloObj {get;set;}
    public string currentParam {get;set;}
    
    public DPCController(){
       
        
        currentParam = ApexPages.currentPage().getParameters().get('depoId'); 
        system.debug('Id='+currentParam );
        
        deptObj= [select id,Protected_Amount__c ,Amount_of_Deposit_Protected_by_TDS__c,Customer__c ,Date_Deposit_Received__c,Property__r.House_No__c,Property__r.City__c, 
                  Property__r.Street__c,Property__r.Country__c,Property__r.State__c,Case_Status__c,Tenants_Name__c,Customer__r.Name,Name,Customer__r.BillingStreet,Customer__r.BillingCity,
                 Customer__r.BillingState,Customer__r.BillingPostalCode,Customer__r.BillingCountry,Amount_of_Deposit_in_Tenancy_Agreement__c from Deposit__c where Id =:currentParam LIMIT 1];
        
        
        
        
        system.debug('deptObject='+deptObj);
        
    }
    
}