({
	Submit : function(component, event, helper) {
    var isValid = true;
    var email = component.get("v.email");
    var phone = component.get("v.phone");
    var activationcode = component.get("v.activationcode");
        if (email == undefined || email == "" || email == null) {  
            component.set("v.emailError",true);    
            isValid = false;
        }
		else{
			component.set("v.emailError",false);
		}
        
        
        if (phone == undefined || phone == "" || phone == null) {  
            component.set("v.phoneError",true);    
            isValid = false;
        }
		else{
			component.set("v.phoneError",false);
		}
        
        
        if (activationcode == undefined || activationcode == "" || activationcode == null) {  
            component.set("v.activationcodeError",true);    
            isValid = false;
        }
		else{
			component.set("v.activationcodeError",false);
		}
 
         if (isValid) {
	var action = component.get("c.checktenantdetails");
        action.setParams({ 
            code:component.get("v.activationcode"),
            tenantphone:component.get("v.phone"),
            useremail:component.get("v.email")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            var message = response.getReturnValue();
                if(message=='nocombination'){
                   // alert('Phone/Activation Code is incorrect');
                   component.set("v.phoneoractivationcodeError", true);
                }
                else if (message=='codeused'){                    
                //alert('user already created');
                 component.set("v.usercreatederror", true);
                }
               
               else if(message=='Duplicateemail'){
                 // alert('already user created with same email address');
                   component.set("v.duplicateemailError", true);
                    }
                   else if (message=='SUCCESS'){
                     component.set("v.successmessage" ,true);
                   }
                       else {
                           
                       }
               
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);	
	}
    },
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
			case "email":
                component.set("v.emailError", false);
                break;
            case "phone":
                component.set("v.phoneError", false);
                break;
            case "activationcode":
                component.set("v.activationcodeError", false);
                break;
            case "phoneoractcode":
                component.set("v.phoneoractivationcodeError", false);
                break;
             case "duplicateemail":
                component.set("v.duplicateemailError", false);
                break;
             case "usercreate":
                component.set("v.usercreatederror", false);
                break;
        }
    },
})