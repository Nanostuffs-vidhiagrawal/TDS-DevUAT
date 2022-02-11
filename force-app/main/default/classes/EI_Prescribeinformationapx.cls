public class EI_Prescribeinformationapx {
    public list<deposit__c> deplist {get;set;}
    public list<Deposit_Allocation__c>depallist{get;set;}
    public list<Deposit_Allocation__c>depallistlead{get;set;}
    public list<user> agentinfolist{get;set;}
    public string protectiondate{get;set;}
    public string receiveddepositdate{get;set;}
    
    public EI_Prescribeinformationapx(){
    Id recid = ApexPages.currentPage().getParameters().get('id');
    
    agentinfolist = [select id,profile.name ,accountid,User_Type__c,Account.Name,Account.PersonMailingStreet,Account.PersonMailingCity, Account.PersonMailingState, Account.PersonMailingCountry, Account.PersonMailingPostalCode,account.PersonEmail, account.PersonMobilePhone  from user where id=:UserInfo.getUserId() and User_Type__c='Agent'];
    system.debug('line-->13' +agentinfolist );
    deplist =  [select id,name,customer__c,Date_Agent_Landlord_Received_Deposit__c,Protection_Start_Date__c,Amount_of_Deposit_Protected_by_TDS__c,customer__r.Salutation, customer__r.Name ,customer__r.Phone,Customer__r.PersonMailingStreet,Customer__r.PersonMailingcity,Customer__r.PersonMailingstate,Customer__r.PersonMailingcountry,customer__r.PersonOtherPhone, customer__r.PersonEmail,Property_Address__c,Start_Date__c,Rent_Amount__c,Deposit_Amount__c,Status__c from Deposit__c where id=:recid ];
    system.debug('line-->15' +deplist );
        
    if(deplist.size()>0 && deplist[0].Protection_Start_Date__c!=null){
    protectiondate = deplist[0].Protection_Start_Date__c.format();
    }
        
    if(deplist.size()>0 && deplist[0].Date_Agent_Landlord_Received_Deposit__c!=null  ){ 
    receiveddepositdate =deplist[0].Date_Agent_Landlord_Received_Deposit__c.format();
    }    
        
    depallist = [select id,Deposit__c,Role__c,Is_Lead__c, Deposit_Holder__c,Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Deposit_Holder__r.Phone from Deposit_Allocation__c  where Deposit__c=:recid and Role__c='tenant' and Is_Lead__c=false ];
    system.debug('line-->25' +depallist );
    depallistlead=[select id,Deposit__c,Role__c,Is_Lead__c, Deposit_Holder__c,Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName,Deposit_Holder__r.PersonMailingStreet,Deposit_Holder__r.PersonMailingcity,Deposit_Holder__r.PersonMailingstate,Deposit_Holder__r.PersonMailingcountry,Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Deposit_Holder__r.Phone from Deposit_Allocation__c  where Deposit__c=:recid and Role__c='tenant' and Is_Lead__c=true ];
    system.debug('line-->27' +depallistlead );
    }

}