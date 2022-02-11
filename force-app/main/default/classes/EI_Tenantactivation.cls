public without sharing class EI_Tenantactivation {

@AuraEnabled
public static String checktenantdetails(string code,string tenantphone,string useremail){
    string st ;
 list<contact> lst = [select id,Email,firstname,lastname,Activation_Code_Used__c,Salutation,Activation_Code__c, Phone from contact where phone =:tenantphone and Activation_Code__c=:code limit 1];
   list<user> userlist = [select id, email from user where email=:useremail and IsActive =true ]; 
    system.debug('line-->8' + lst );
     contact acc = new contact();
    if(lst.size()==0){
    st='nocombination';
    }
    else if(lst.size()>0 && lst[0].Activation_Code_Used__c==true){
    st='codeused';        
        }
    else if (lst.size()>0 && userlist.size()>0){
     st ='Duplicateemail';   
    }
    else{
     acc.id = lst[0].Id;
     acc.email =useremail;
     acc.Activation_Code_Used__c=true;
      update acc;
   }
   
    
    list<user> newuserlist = new list<user>();
    if(acc.email!=null) {
      User u = new User();
                    // Alias Check
                    String fullName = lst[0].FirstName + lst[0].lastname;
                    if (fullName.length() >= 5){
                        u.alias = fullName.substring(0, 4);
                    } else{
                        u.alias = fullName;
                    }
                    
                    // NickName Check
                    String nickname = ((lst[0].FirstName != null && lst[0].FirstName.length() > 0) ? lst[0].FirstName.substring(0, 1) : '')+lst[0].FirstName.substring(0, 1);
                    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                    u.CommunityNickname = nickname;
                    
                    // Username Check
                    
                    u.Title = lst[0].Salutation;
                    u.FirstName = lst[0].FirstName;
                    u.LastName = lst[0].lastname;
                    
                    // Uncomment
                    u.Username = acc.email+string.valueof(Math.floor(Math.random() * 100));
                    u.Phone = lst[0].Phone;
                    
                    //u.Username = con.Email + 'abc';
                    u.Email = acc.email;
                    u.ProfileId = [Select Id,name from profile where name = 'Tenant' limit 1].Id;
                    // u.profileId = ut.ProfileId;
                    
                    
                    u.TimeZoneSidKey = 'Europe/London';
                    u.LocaleSidKey = 'en_GB';
                    u.LanguageLocaleKey = 'en_US';
                    u.ContactId = lst[0].Id;
                    u.User_Type__c='Tenant';
                    u.EmailEncodingKey = 'ISO-8859-1';
                    // u.Addition_Permission__c = userpermission;
                    //  u.User_Role__c = jobrole;
                    // insert u;
                    newuserlist.add(u); 
            }
        system.debug('line 58 -->' +newuserlist );
        insert  newuserlist;
    if(newuserlist.size()>0){
      st = 'SUCCESS';
    }
    
     return st;        
        
    }
    
}