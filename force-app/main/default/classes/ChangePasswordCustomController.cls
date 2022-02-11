global with sharing class ChangePasswordCustomController{
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    
    public ChangePasswordCustomController()
    {
    }
    
    public PageReference changePassword() {    
        return Site.changePassword(newPassword, verifyNewPassword);
    }
}