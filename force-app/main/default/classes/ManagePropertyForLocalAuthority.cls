public without sharing class ManagePropertyForLocalAuthority {     
    
    @AuraEnabled
    public static List<Property__c> getBranchList(){
        system.debug('its working');    
        List<Property__c>ListProperty = new List<Property__c>();        
        User usercode =[Select id,Area_Code__c from User where id=:UserInfo.getUserId()]; //];        
       // system.debug('the user code'+usercode);
        String areacode = usercode.Area_Code__c;
        //system.debug('the areacode'+areacode);
        Set<Id>PropertyIdSet = new Set<Id>();
       QueryLimits__c querylimit = QueryLimits__c.getValues('All Limits');        
       //QueryLimits__c querylimit = QueryLimits__c.getall().values(); 
        Integer limitsize = Integer.valueOf(querylimit.LocalAuthorityLimit__c);
        //system.debug('the limit size'+limitsize);        
        for(Property_Allocation__c Objproperty:[select id,Property__c,Landlord_Registration_Number__c,Reg__c from Property_Allocation__c where Reg__c =:areacode AND Reg__c!= null] ){
             PropertyIdSet.add(Objproperty.Property__c);        
        }
            
            if(!PropertyIdSet.isEmpty()){
              ListProperty = [Select Id,Postal_Code__c,Property_Owner__c,Property_Owner__r.Address__pc,Property_Owner__r.Name,City__c,House_No__c,Street__c,Town__c,District__c,State__c,Country__c,County__c,Landlord_Registration_Number__c,Property_Owner__r.recordtype.name,(select id,Tenants_Name__c,Date_Deposit_Received__c,Property_Address__c,Property__c from Deposits__r Limit 1)from Property__c where id=:PropertyIdSet ];
                //system.debug('the list is'+ListProperty);
            }
        return ListProperty;   
        
    }       
    
         
    @AuraEnabled
    public static List<Property__c> myPropertyList(String searchKey){ 
        
        string name =  + searchKey + '%';
        
          List<Property__c>ListProperty = new List<Property__c>();        
        User usercode =[Select id,Area_Code__c from User where id=:UserInfo.getUserId()]; 
        
       // system.debug('the user code'+usercode);
        String areacode = usercode.Area_Code__c;
        system.debug('the areacode'+areacode);
        Set<Id>PropertyIdSet = new Set<Id>();
        for(Property_Allocation__c Objproperty:[select id,Property__c,Landlord_Registration_Number__c,Reg__c from Property_Allocation__c where Reg__c=:areacode]){
             PropertyIdSet.add(Objproperty.Property__c);       
        }            
            if(!PropertyIdSet.isEmpty()){
             // ListProperty = [Select Id,Postal_Code__c,Property_Owner__c,Property_Owner__r.Address__pc,Property_Owner__r.Name,City__c,House_No__c,Landlord_Registration_Number__c,Property_Owner__r.recordtype.name,(select id,Tenants_Name__c,Date_Deposit_Received__c,Property_Address__c,Property__c from Deposits__r) from Property__c where id=:PropertyIdSet AND Landlord_Registration_Number__c LIKE :name];
               // system.debug('the list is'+ListProperty);
                
                if(searchKey!= null && searchKey != 'undefined' && searchKey != ''){
                    ListProperty = [Select Id,Postal_Code__c,Property_Owner__c,Property_Owner__r.Address__pc,Property_Owner__r.Name,City__c,House_No__c,Street__c,Landlord_Registration_Number__c,Property_Owner__r.recordtype.name,(select id,Tenants_Name__c,Date_Deposit_Received__c,Property_Address__c,Property__c from Deposits__r Limit 1) from Property__c where id=:PropertyIdSet AND Landlord_Registration_Number__c LIKE :searchKey];
               // system.debug('the list is'+ListProperty);
                }
                else{
                    ListProperty = [Select Id,Postal_Code__c,Property_Owner__c,Property_Owner__r.Address__pc,Property_Owner__r.Name,City__c,House_No__c,Street__c,Landlord_Registration_Number__c,Property_Owner__r.recordtype.name,(select id,Tenants_Name__c,Date_Deposit_Received__c,Property_Address__c,Property__c from Deposits__r Limit 1) from Property__c where id=:PropertyIdSet];
                //system.debug('the list is'+ListProperty);
                }
            }
      
        return ListProperty;
    }
}