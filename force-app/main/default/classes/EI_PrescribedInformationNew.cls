public without sharing class EI_PrescribedInformationNew {

  
    public list<property__c> propList{get;set;}
    public list<Deposit__c> depositList{get;set;}
    public  User currentUserHC {get;set;}
    public  User currentUser {get;set;}
    public  String currentUserPIClause {get;set;}
    public string currentUserPIReferClause{get;set;}
    public  String currentUserPIRef {get;set;}
     public  String landlordList {get;set;}
    public EI_PrescribedInformationNew (){
    Id recid = ApexPages.currentPage().getParameters().get('id');
       System.debug('id='+recid);
    
        currentUser = [select id, Name, Contact.Prescribed_clause_reference__c, Contact.Prescribed_Information_Clauses__c, profile.name,contact.Account.IsPersonAccount from user where id=:UserInfo.getUserId() ];
       System.debug('::UserInfo='+currentUser);
        currentUserPIClause = currentUser.Contact.Prescribed_Information_Clauses__c;        
        currentUserPIReferClause = currentUser.Contact.Prescribed_clause_reference__c;
        // currentUserHC = [select id, Name, Contact.Prescribed_clause_reference__c, Contact.Prescribed_Information_Clauses__c, profile.name from user where id='0058E0000091YiE' ];
        String propertyId = [SELECT Property__c FROM Deposit__c where Id =: recid limit 1].Property__c;
        System.debug('::propertyId => '+propertyId);
        
        // propList=[Select Id,Name,Postal_Code__c,Property_Owner__c,Property_Owner__r.Address__pc,Property_Owner__r.Name,City__c,House_No__c,Landlord_Registration_Number__c,Property_Owner__r.recordtype.name,
        //         (select id,Amount_of_Deposit_Protected_by_TDS__c,Tenants_Name__c,Date_Received_by_Scheme__c,Property_Address__c,Property__c,Date_Deposit_Received__c,Customer__r.Prescribed_clause_reference__pc,
        //         Property__r.House_No__c,Property__r.City__c,Payment_Received_By_Scheme__c,
        //         Property__r.Street__c,Protected_Amount__c,Property__r.Country__c,Property__r.State__c,Customer__r.Prescribed_Information_Clauses__pc from Deposits__r where id=: recid limit 1 ),
        //         (select id,Property__c,Landlord_Registration_Number__c,Contact__c,Contact__r.Name from Property_Allocations__r limit 200)
        //         from Property__c WHERE Id =: propertyId limit 1];

        //     currentUserPIClause = currentUser.Contact.Prescribed_Information_Clauses__c;
        //     currentUserPIReferClause = currentUser.Contact.Prescribed_clause_reference__c;
      
        // Integer propAllList = propList[0].Property_Allocations__r.size();
        // landlordList = '';
        // for(integer i=0;i<propAllList;i++){
        //      landlordList = landlordList + propList[0].Property_Allocations__r[i].Contact__r.Name;
            
        //     if(propAllList > 1 && propList[0].Property_Allocations__r[propAllList-1].Id != propList[0].Property_Allocations__r[i].Id){
        //        landlordList = landlordList+', '; 
        //     }else{
        //         landlordList = landlordList+''; 
        //     }
        // }
        depositList = [select id,Amount_of_Deposit_Protected_by_TDS__c, Tenants_Name__c, Date_Received_by_Scheme__c, Property_Address__c,
                Protected_Amount__c, Date_Deposit_Received__c, Customer__r.Prescribed_clause_reference__pc, Property__r.House_No__c, 
                Payment_Received_By_Scheme__c,Property__r.Street__c,Property__r.Country__c,Property__r.State__c,
                Customer__r.Prescribed_Information_Clauses__pc,
                Property__c, Property__r.Name, Property__r.Postal_Code__c, Property__r.Property_Owner__c, Property__r.Property_Owner__r.Address__pc,
                Property__r.Property_Owner__r.Name, Property__r.City__c, Property__r.Landlord_Registration_Number__c, Property__r.Property_Owner__r.recordtype.name
                from deposit__c where id=: recid];
            
        List<Property_Allocation__c> propAllocList = [select id,Property__c,Landlord_Registration_Number__c,Contact__c,Contact__r.Name from Property_Allocation__c where property__c=: propertyId];
        landlordList = '';
        for(integer i=0;i<propAllocList.size();i++){
             landlordList = landlordList + propAllocList[i].Contact__r.Name;
            
            if(propAllocList[propAllocList.size()-1].Id != propAllocList[i].Id){
               landlordList = landlordList+', '; 
            }else{
                landlordList = landlordList+''; 
            }
        }
        //System.debug('List='+propList.size());
        //System.debug('Data='+propList[0]);
        String str = 'attachment; filename='+depositList[0].Property__r.Name+'.pdf';

        Apexpages.currentPage().getHeaders().put('content-disposition',str);
 
    }

}