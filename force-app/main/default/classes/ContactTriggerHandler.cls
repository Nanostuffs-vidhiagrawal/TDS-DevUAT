public class ContactTriggerHandler {
    
    public static void handleBeforeInsert(List<Contact> contactlist){
    String memberid;
        Boolean flag =false;
        MemberId__c myMemberid = MemberId__c.getInstance('MemberID');
        for(Contact con : contactlist){
            if(string.IsBlank(con.Email)){
                if(con.Account_Type__c=='Agent'){
                    string mbrid =string.valueof(myMemberid.AgentID__c);
                    mbrid = mbrid.substringBeforeLast('.');
                    integer needaddzero = 5-mbrid.length();
                    string prefix ='0';
                    for(integer i =1; i<needaddzero;i++){
                        prefix = prefix+'0';
                    }
                    
                    memberid = 'A'+prefix+mbrid+'SC';
                    myMemberid.AgentID__c = myMemberid.AgentID__c+1;
                    flag =true;
                }
                else if(con.Account_Type__c=='Joint Landlord') {
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
                else if(con.Account_Type__c=='Landlord'){
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
                else if(con.Account_Type__c=='Tenant'  ){
                    
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
                con.MemberId__c = memberid;
            }
        }
        if(flag){
            update myMemberid;
        }
    }

}