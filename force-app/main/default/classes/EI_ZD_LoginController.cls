global without sharing class EI_ZD_LoginController {
    
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
                
            }
            ApexPages.PageReference lgn = Site.login(username,password,null);
            aura.redirect(lgn);
            if (lgn!=null) {
                System.debug('@@ '+lgn.getURL());
                return  lgn.getURL();
            } else {
                return 'login error';
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
            if(!Test.isRunningTest()){
            System.resetPasswordWithEmailTemplate(lstUserToresetPassword[0].id,true,'ZeroDepositChanged_Password_Email');
            }
            return 'Reset';
        }else{
            return 'NotFound';
        }
    }
    public static String decodeData(String encrypted, String key){
        
        
        Blob bkey = Blob.valueOf(key);
        Blob source = EncodingUtil.base64Decode(encrypted );
        Blob decrypted = Crypto.decryptWithManagedIV('AES256',bkey, source);
        system.debug(decrypted.toString());
        return decrypted.toString();
        
    }

}