global without sharing class LoginControllerClone {
     @AuraEnabled
    global static String checkPortal(String username, String password, Boolean isEncoded) {
        
        try {
            if(String.isEmpty(username)){
                return 'UserNameError';
            }else if(String.isEmpty(password)){
                return 'PasswordError';
            }
             if(isEncoded){
                 
                username = decodeData(userName,'ca4249ed2b234337b52263cabe5587d1');
                password = decodeData(password,'ca4249ed2b234337b52263cabe5587d1');
                system.debug('@@ '+username+ ' -- '+ password);
            }
            ApexPages.PageReference lgn = Site.login(username,password,null);
            aura.redirect(lgn);
            if (lgn!=null) {
                System.debug('@@ '+lgn.getURL());
                return  lgn.getURL();
            } else {
                throw new AuraHandledException('Login Error!');
            }
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    @AuraEnabled
    global static String checkPortalRedirect(String username, String password, Boolean isEncoded, String pageURL) {
        
        try {
            if(String.isEmpty(username)){
                return 'UserNameError';
            }else if(String.isEmpty(password)){
                return 'PasswordError';
            }
             if(isEncoded){
                username = decodeData(userName,'ca4249ed2b234337b52263cabe5587d1');
                password = decodeData(password,'ca4249ed2b234337b52263cabe5587d1');
                
            }
            ApexPages.PageReference lgn = Site.login(username,password,pageURL);
            aura.redirect(lgn);
            if (lgn!=null) {
                return  lgn.getURL();
            } else {
                throw new AuraHandledException('Login Error!');
            }
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    global static String resetPasswordMethod(String userName) {
        if(String.isBlank(userName)){
            return 'EnterUserName';
        }
        List<User> lstUserToresetPassword = [SELECT id,username,email from User where UserName = :userName];
        if (lstUserToresetPassword.size()>0) {
            System.resetPasswordWithEmailTemplate(lstUserToresetPassword[0].id,true,'CommunityForgotPasswordEmailTemplate');
            return 'Reset';
        }else{
            return 'NotFound';
        }
    }
      public static String decodeData(String encrypted, String key){
        
        
        Blob bkey = Blob.valueOf(key);
          String s=EncodingUtil.urldecode(encrypted, 'ASCII');
        s=s.replaceAll(' ', '+');
        
        Blob source = EncodingUtil.base64Decode(s);
        
        Blob decrypted = Crypto.decryptWithManagedIV('AES256',bkey, source);  
          String a=decrypted.toString().replaceAll(' ', '+');
        system.debug(decrypted.toString());
        return a;
        
    }
   @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }     
        
        
}