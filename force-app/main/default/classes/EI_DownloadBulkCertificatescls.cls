public without sharing class EI_DownloadBulkCertificatescls {

    // This method is using for fetch the deposits of logged in Agent/Landlord //
    @AuraEnabled
    public static List<depositListWrapper> getDepositInformation(String branchId) {
        List<depositListWrapper> lstdepositListWrapper = new List<depositListWrapper>(); 
        try{
            Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId; 
            if(branchId == null){
                for(Deposit__c deposit :[SELECT Id,Name,Property_Address__c,Protected_Amount__c,Customer__c,Customer__r.Name,Number_of_Tenants__c, 
                                         Deposit_Certificate_Name__c, Deposit_Certificate_Link__c
                                         from Deposit__c where Customer__c =:accountid and  Status__c = 'Deposits held by scheme'
                                         and Deposit_Certificate_Link__c != '' 
                                        ])
                { 
                    lstdepositListWrapper.add(new depositListWrapper(false,deposit)); 
                }
            }
            else{
                for(Deposit__c deposit :[SELECT Id,Name,Property_Address__c,Protected_Amount__c,Customer__c,Customer__r.Name,Number_of_Tenants__c, 
                                         Deposit_Certificate_Name__c, Deposit_Certificate_Link__c
                                         from Deposit__c where Customer__c =:accountid and  Status__c = 'Deposits held by scheme' 
                                         and Deposit_Certificate_Link__c != '' and branch__c =:branchId
                                        ])
                { 
                    lstdepositListWrapper.add(new depositListWrapper(false,deposit)); 
                }
            }
            return lstdepositListWrapper;
        }
        catch (Exception e) {
            return lstdepositListWrapper;
        }
    }
    
    /* Wrapper class for checkbox with deposit */  
    public class depositListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Deposit__c objDeposit{get;set;}
        public depositListWrapper(boolean isChecked, Deposit__c objDeposit){
            this.isChecked = isChecked;
            this.objDeposit = objDeposit;
        }
    }
   
    // This method is using for fetch the filtered deposits of logged in Agent/Landlord //
    @AuraEnabled
    public static List<depositListWrapper> getSearchDepositInformation(String searchText, String branchId) {
        System.debug('searchText >>> ' + searchText); 
        List<depositListWrapper> lstdepositListWrapper = new List<depositListWrapper>(); 
        List<Deposit__c> depositListProperty = new List<Deposit__c>();
        Set<Id> setDepositIds = new Set<Id>();
        String searchTextValue = '%' + String.escapeSingleQuotes(searchText.trim()) + '%';
        System.debug('searchText >>> ' + searchTextValue); 
        try{
            
            Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId; 
            System.debug('accountid >>> ' + accountid);     
            if(branchId == null){
                for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__c from Deposit_Allocation__c where Deposit__r.Customer__c = :accountid AND                                                
                                                               (Deposit_Holder__r.PersonEmail like:searchTextValue OR Deposit_Holder__r.Name like:searchTextValue OR 
                                                                Deposit_Holder__r.Phone like:searchTextValue OR Contact__r.Name like:searchTextValue OR 
                                                                Contact__r.Email  like:searchTextValue OR Contact__r.Phone  like:searchTextValue OR Contact__r.Name  like:searchTextValue)
                                                              ])
                {
                    setDepositIds.add(depositAllocation.Deposit__c);                 
                }
                System.debug('depositAllocation setDepositIds >>> ' + setDepositIds); 
                for(Property__c prop : [SELECT Id,(Select id from Deposits__r) FROM Property__c 
                                        where id in (Select Property__c from Property_Allocation__c 
                                                     where contact__r.name like :searchTextValue)])
                {
                    System.debug('prop >>> ' + prop); 
                    depositListProperty.addall(prop.Deposits__r);    
                }
                if(!depositListProperty.isEmpty()){
                    for(Deposit__c deposit : depositListProperty){
                        setDepositIds.add(deposit.Id);                
                    }
                }
                System.debug('propertyAllocation setDepositIds >>> ' + setDepositIds);
                
                for(Deposit__c deposit :[SELECT Id,Name,Protected_Amount__c,Customer__c,Customer__r.Name, Number_of_Tenants__c,Property_Address__c,
                                         Start_Date_Text__c, Deposit_Certificate_Name__c, Deposit_Certificate_Link__c
                                         from Deposit__c WHERE Customer__c =:accountid and Status__c = 'Deposits held by scheme' 
                                         and Deposit_Certificate_Link__c != '' 
                                         and (Start_Date_Text__c like :searchTextValue OR ID IN: setDepositIds OR Property_Address__c like:searchTextValue)
                                        ])
                { 
                    System.debug('deposit =>>> ' + deposit);
                    lstdepositListWrapper.add(new depositListWrapper(false,deposit)); 
                }
            }
            else{
                for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__c from Deposit_Allocation__c where Deposit__r.Customer__c = :accountid AND                                                
                                                               (Deposit_Holder__r.PersonEmail like:searchTextValue OR Deposit_Holder__r.Name like:searchTextValue OR 
                                                                Deposit_Holder__r.Phone like:searchTextValue OR Contact__r.Name like:searchTextValue OR 
                                                                Contact__r.Email  like:searchTextValue OR Contact__r.Phone  like:searchTextValue OR Contact__r.Name  like:searchTextValue)
                                                               and Deposit__r.branch__c =:branchId
                                                              ])
                {
                    setDepositIds.add(depositAllocation.Deposit__c);                 
                }
                System.debug('depositAllocation setDepositIds >>> ' + setDepositIds); 
                for(Property__c prop : [SELECT Id,(Select id from Deposits__r) FROM Property__c 
                                        where id in (Select Property__c from Property_Allocation__c 
                                                     where contact__r.name like :searchTextValue)
                                        and branch__c =:branchId])
                {
                    System.debug('prop >>> ' + prop); 
                    depositListProperty.addall(prop.Deposits__r);    
                }
                if(!depositListProperty.isEmpty()){
                    for(Deposit__c deposit : depositListProperty){
                        setDepositIds.add(deposit.Id);                
                    }
                }
                System.debug('propertyAllocation setDepositIds >>> ' + setDepositIds);
                
                for(Deposit__c deposit :[SELECT Id,Name,Protected_Amount__c,Customer__c,Customer__r.Name, Number_of_Tenants__c,Property_Address__c,
                                         Start_Date_Text__c, Deposit_Certificate_Name__c, Deposit_Certificate_Link__c
                                         from Deposit__c WHERE Customer__c =:accountid and Status__c = 'Deposits held by scheme' 
                                         and Deposit_Certificate_Link__c != '' 
                                         and (Start_Date_Text__c like :searchTextValue OR ID IN: setDepositIds OR Property_Address__c like:searchTextValue)
                                         and branch__c =:branchId
                                        ])
                { 
                    System.debug('deposit =>>> ' + deposit);
                    lstdepositListWrapper.add(new depositListWrapper(false,deposit)); 
                }
            }
            
            System.debug('lstdepositListWrapper >>> ' + lstdepositListWrapper);
            return lstdepositListWrapper;
        }
        catch (Exception e) {
            return lstdepositListWrapper;
        }
    }
    
    // This method is using for fetch the deposits of logged in Agent/Landlord for PI form
    @AuraEnabled
    public static List<depositListWrapper> getDepositInformationPIForm(String branchId) {
        List<depositListWrapper> lstdepositListWrapper = new List<depositListWrapper>(); 
        try{
            Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId; 
            if(branchId == null){
                for(Deposit__c deposit :[SELECT Id,Name,Property_Address__c,Protected_Amount__c,Customer__c,Customer__r.Name,Number_of_Tenants__c, 
                                         PI_Certificate_Name__c, PI_Certificate_Link__c
                                         from Deposit__c where Customer__c =:accountid and PI_Certificate_Link__c != '' and status__c not IN ('Deposit registration deleted', 'Deposit Closed', 'Close')
                                        ])
                { 
                    lstdepositListWrapper.add(new depositListWrapper(false,deposit)); 
                }
            }
            else{
                for(Deposit__c deposit :[SELECT Id,Name,Property_Address__c,Protected_Amount__c,Customer__c,Customer__r.Name,Number_of_Tenants__c, 
                                         PI_Certificate_Name__c, PI_Certificate_Link__c
                                         from Deposit__c where Customer__c =:accountid and PI_Certificate_Link__c != '' and branch__c =:branchId
                                         and status__c not IN ('Deposit registration deleted', 'Deposit Closed', 'Close')
                                        ])
                { 
                    lstdepositListWrapper.add(new depositListWrapper(false,deposit)); 
                }
            }
            return lstdepositListWrapper;
        }
        catch (Exception e) {
            return lstdepositListWrapper;
        }
    }
    
    // This method is using for fetch the filtered deposits of logged in Agent/Landlord for PI form
    @AuraEnabled
    public static List<depositListWrapper> getSearchDepositInformationPIForm(String searchText, String branchId) {
        System.debug('searchText >>> ' + searchText); 
        List<depositListWrapper> lstdepositListWrapper = new List<depositListWrapper>(); 
        List<Deposit__c> depositListProperty = new List<Deposit__c>();
        Set<Id> setDepositIds = new Set<Id>();
        String searchTextValue = '%' + String.escapeSingleQuotes(searchText.trim()) + '%';
        System.debug('searchText >>> ' + searchTextValue); 
        try{
            
            Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId; 
            System.debug('accountid >>> ' + accountid);  
            
            if(branchId == null){
                for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__c from Deposit_Allocation__c where Deposit__r.Customer__c = :accountid AND                                                
                                                               (Deposit_Holder__r.PersonEmail like:searchTextValue OR Deposit_Holder__r.Name like:searchTextValue OR 
                                                                Deposit_Holder__r.Phone like:searchTextValue OR Contact__r.Name like:searchTextValue OR 
                                                                Contact__r.Email  like:searchTextValue OR Contact__r.Phone  like:searchTextValue OR Contact__r.Name  like:searchTextValue 
                                                               )]){
                                                                   setDepositIds.add(depositAllocation.Deposit__c);                 
                                                               }
                System.debug('depositAllocation setDepositIds >>> ' + setDepositIds); 
                for(Property__c prop : [SELECT Id,(Select id from Deposits__r) FROM Property__c 
                                        where id in (Select Property__c from Property_Allocation__c 
                                                     where contact__r.name like :searchTextValue)])
                {
                    System.debug('prop >>> ' + prop); 
                    depositListProperty.addall(prop.Deposits__r);    
                }
                if(!depositListProperty.isEmpty()){
                    for(Deposit__c deposit : depositListProperty){
                        setDepositIds.add(deposit.Id);                
                    }
                }
                System.debug('propertyAllocation setDepositIds >>> ' + setDepositIds);
                
                for(Deposit__c deposit :[SELECT Id,Name,Protected_Amount__c,Customer__c,Customer__r.Name, Number_of_Tenants__c,Property_Address__c,
                                         Start_Date_Text__c, PI_Certificate_Name__c, PI_Certificate_Link__c
                                         from Deposit__c WHERE Customer__c =:accountid and PI_Certificate_Link__c != ''
                                         and status__c not IN ('Deposit registration deleted', 'Deposit Closed', 'Close')
                                         and (Start_Date_Text__c like :searchTextValue OR ID IN: setDepositIds OR Property_Address__c like:searchTextValue)
                                        ])
                { 
                    System.debug('deposit =>>> ' + deposit);
                    lstdepositListWrapper.add(new depositListWrapper(false,deposit)); 
                }
            }
            else{
                for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__c from Deposit_Allocation__c where Deposit__r.Customer__c = :accountid AND                                                
                                                               (Deposit_Holder__r.PersonEmail like:searchTextValue OR Deposit_Holder__r.Name like:searchTextValue OR 
                                                                Deposit_Holder__r.Phone like:searchTextValue OR Contact__r.Name like:searchTextValue OR 
                                                                Contact__r.Email  like:searchTextValue OR Contact__r.Phone  like:searchTextValue OR Contact__r.Name  like:searchTextValue) 
                                                               AND Deposit__r.branch__c =:branchId 
                                                              ])
                {
                    setDepositIds.add(depositAllocation.Deposit__c);                 
                }
                System.debug('depositAllocation setDepositIds >>> ' + setDepositIds); 
                for(Property__c prop : [SELECT Id,(Select id from Deposits__r) FROM Property__c 
                                        where id in (Select Property__c from Property_Allocation__c 
                                                     where contact__r.name like :searchTextValue)
                                        AND branch__c =:branchId ])
                {
                    System.debug('prop >>> ' + prop); 
                    depositListProperty.addall(prop.Deposits__r);    
                }
                if(!depositListProperty.isEmpty()){
                    for(Deposit__c deposit : depositListProperty){
                        setDepositIds.add(deposit.Id);                
                    }
                }
                System.debug('propertyAllocation setDepositIds >>> ' + setDepositIds);
                
                for(Deposit__c deposit :[SELECT Id,Name,Protected_Amount__c,Customer__c,Customer__r.Name, Number_of_Tenants__c,Property_Address__c,
                                         Start_Date_Text__c, PI_Certificate_Name__c, PI_Certificate_Link__c
                                         from Deposit__c WHERE Customer__c =:accountid and PI_Certificate_Link__c != ''
                                         and (Start_Date_Text__c like :searchTextValue OR ID IN: setDepositIds OR Property_Address__c like:searchTextValue)
                                         and status__c not IN ('Deposit registration deleted', 'Deposit Closed', 'Close')
                                         and branch__c =:branchId 
                                        ])
                { 
                    System.debug('deposit =>>> ' + deposit);
                    lstdepositListWrapper.add(new depositListWrapper(false,deposit)); 
                }
            }
            
            System.debug('lstdepositListWrapper >>> ' + lstdepositListWrapper);
            return lstdepositListWrapper;
        }
        catch (Exception e) {
            return lstdepositListWrapper;
        }
    }
    
}