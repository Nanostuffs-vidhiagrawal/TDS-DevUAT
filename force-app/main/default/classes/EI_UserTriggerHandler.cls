public class EI_UserTriggerHandler {
    
    public static void beforeinsert(list<user> userlist){
        MemberId__c myMemberid =MemberId__c.getInstance('MemberID');
        Boolean flag =false;
        for(user u :userlist)
        {
            String memberid;
            if(u.contactid != null)
            {
                if(u.User_Type__c=='Agent')
                {
                    string mbrid =string.valueof(myMemberid.AgentID__c);
                    mbrid = mbrid.substringBeforeLast('.');
                    integer needaddzero = 5-mbrid.length();
                    string prefix ='0';
                    for(integer i =1; i<needaddzero;i++)
                    {
                        prefix = prefix+'0';
                    }
                    
                    memberid = 'A'+prefix+mbrid+'SC';
                    myMemberid.AgentID__c = myMemberid.AgentID__c+1;
                    flag =true;
                }
                else if(u.User_Type__c=='Joint Landlord')
                {
                    string mbrid =string.valueof(myMemberid.LandlordId__c);
                    mbrid = mbrid.substringBeforeLast('.');
                    integer needaddzero = 5-mbrid.length();
                    string prefix ='0';
                    for(integer i =1; i<needaddzero;i++)
                    {
                        prefix = prefix+'0';
                    }
                    memberid = 'L'+prefix+mbrid +'SC';
                   myMemberid.LandlordId__c = myMemberid.LandlordId__c+1;
                    flag =true;
                }
                else if(u.User_Type__c=='Landlord')
                {
                    string mbrid =string.valueof(myMemberid.LandlordId__c);
                    mbrid = mbrid.substringBeforeLast('.');
                    integer needaddzero = 5-mbrid.length();
                    string prefix ='0';
                    for(integer i =1; i<needaddzero;i++)
                    {
                        prefix = prefix+'0';
                    }
                    memberid = 'L'+prefix+mbrid +'SC';
                    myMemberid.LandlordId__c = myMemberid.LandlordId__c+1;
                    flag =true;
                }
                else if(u.User_Type__c=='Tenant'  )
                {
                    
                    string mbrid =string.valueof(myMemberid.TenantID__c);
                    mbrid = mbrid.substringBeforeLast('.');
                    integer needaddzero = 5-mbrid.length();
                    string prefix ='0';
                    for(integer i =1; i<needaddzero;i++)
                    {
                        prefix = prefix+'0';
                    }
                    memberid = 'T'+prefix+mbrid +'SC'; 
                    myMemberid.TenantID__c = myMemberid.TenantID__c+1;
                    flag =true;
                }
                 u.MemberId__c = memberid;
           }
            
            
        }
        if(flag && !Test.isRunningTest())
        {
            update myMemberid;
        }        
    }
    
    public static void afterinsert(List<User> userlist){
        
        Map<String,String> mapUserEmailUserAccountId =  new Map<String,String>();
        List<Deposit__c> listDepositToUpdate = new List<Deposit__c>();
        
        for(User usr : userlist){
            mapUserEmailUserAccountId.put(usr.Email,usr.AccountId);
        }
        
        if(!mapUserEmailUserAccountId.isEmpty()){
            for(Deposit__c depositList : [SELECT Id,Deposit_Transferred_to_Account__c,New_Customer_Email__c 
                           from Deposit__c where New_Customer_Email__c IN :mapUserEmailUserAccountId.keySet()
                          and Deposit_Transferred__c=true limit 1000]){                           
                depositList.Deposit_Transferred_to_Account__c = mapUserEmailUserAccountId.get(depositList.New_Customer_Email__c);
                depositList.New_Customer_Email__c = null;               
                listDepositToUpdate.add(depositList);             
            }
            
            if(!listDepositToUpdate.isEmpty()){
                update listDepositToUpdate;
            }
        }
        
    }
    
}