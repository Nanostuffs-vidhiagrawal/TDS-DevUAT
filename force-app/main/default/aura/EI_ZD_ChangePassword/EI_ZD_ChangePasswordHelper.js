({
	handleChangePassword: function (component, event, userId) {  
        var oldPassword = component.get("v.oldPassword");
        var newPassword = component.get("v.newPassword");
        var verifyNewPassword = component.get("v.verifyNewPassword");
        var action = component.get("c.changePassowrd");
        action.setParams({userId:userId, oldPassword:oldPassword,newPassword:newPassword,verifyNewPassword:verifyNewPassword});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }
       });
        $A.enqueueAction(action);
    }
})