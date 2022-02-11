({
    doInit : function(component, event, helper) {
        
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        
        
        if(urlParams.has("uname")){
            // const uname = urlParams.get('uname');
            // const pword = urlParams.get('pword');
            const uname = decodeURIComponent(window.location.search.substring(1).split('&')[0].split('=')[1]);
            const pword  = decodeURIComponent(window.location.search.substring(1).split('&')[1].split('=')[1]);
                        
            if((uname != '' && pword !='' ) || (uname != null && pword != null) ){
                
                var action = component.get("c.checkPortal");
                
                action.setParams({
                    username: uname,
                    password: pword,
                    isEncoded:true            });
                // Add callback behavior for when response is received
                action.setCallback(this,
                                   function (response) {
                                       var rtnValue = response.getReturnValue();
                                       window.open(rtnValue,"_self");        
                                   });
                $A.enqueueAction(action);
            }
        }
    },
    RegisterPage: function (component, event, helper) {
        // var currentURL = window.location.href;        
        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"login/SelfRegister";
        window.location.replace(urlRedirect);
        return false;
    },
    
    /*This function is used to reset the password */
    resetPwd : function (component,event, helpler) {
        //component.set("v.UserNameResetError",true);
        component.set("v.UserNameResetError",true);        
        window.setTimeout(
            $A.getCallback(function() {
                document.getElementsByClassName('modal-backdrop')[0].style.position='unset';
            }), 100
        );        
    },
    
    /*This function is used to reset the password */
    resetPassword : function (component,event, helpler) {
        var isValid = true;
        var Username = component.find('resetUsername').getElement().value;
        if(typeof Username == 'undefined' || Username == '' || Username == null){
            component.set("v.UserNameResetError",true);    
            isValid = false;
        }
        if(isValid){
            component.set("v.UserNameResetError",false);
            var usernameToReset = Username;
            var action = component.get("c.resetPasswordMethod");
            action.setParams({
                "userName": usernameToReset
            });
            // Add callback behavior for when response is received
            action.setCallback(this,function (response) {
                var state = response.getState();
                var rtnValue = response.getReturnValue();
               // console.log('==='+rtnValue);
                if (rtnValue !== null) {
                    if(rtnValue ==='NotFound'){
                        component.set("v.resetError",' Check Your username');
                        component.set("v.errorMessage1",true);    
                        isValid = false;
                    }else if(rtnValue === 'EnterUserName'){
                        component.set("v.resetError",' Please enter username');
                        component.set("v.errorMessage1",true);    
                        isValid = false;
                    }else if(rtnValue === 'Reset'){
                        $A.get('e.force:refreshView').fire();
                        component.set("v.resetError",'');
                        component.set("v.isShowResetModal", false);   
                        
                    }
                    
                }
            });
            
            // Send action off to be executed
            $A.enqueueAction(action);
        }
    }, 
    
    getInput: function (component, event, helper) {
        component.set("v.mylabel1","");
        var isValid = true;
        // Get the Username from Component
        var user = component.find('uname').getElement().value;
        var Pass = component.find('pass').getElement().value;
        if(typeof user == 'undefined' || user == '' || user == null){
            component.set("v.UserNameError",true);    
            isValid = false;
        }
        if(typeof Pass == 'undefined' || Pass == '' || Pass == null){
            component.set("v.PasswordError",true);    
            isValid = false;
        }
        /*if((typeof Pass == 'undefined' || Pass == '') && (typeof user == 'undefined' || user == '')){
            component.set("v.flagUserType",true); 
            component.set("v.flagPassType",true);
        }
        else if(typeof user == 'undefined' || user == ''){
            component.set("v.flagUserType",true);
            component.set("v.flagPassType",false);
        }
            else if(typeof Pass == 'undefined' || Pass == ''){
                component.set("v.flagUserType",false); 
                component.set("v.flagPassType",true);
            }else{
                component.set("v.flagUserType",false); 
                component.set("v.flagPassType",false);
            }*/
        
        //Calling controller
        // Create the action
        if(isValid){
            component.set("v.UserNameError",false);
            component.set("v.PasswordError",false);    
            var action = component.get("c.checkPortal");
            //   alert(user +' ## '+Pass);
            action.setParams({
                username: user,
                password: Pass,
                isEncoded:false
            });
            // Add callback behavior for when response is received
            action.setCallback(this,
                               function (response) {
                                   var state = response.getState();
                                   var rtnValue = response.getReturnValue();
                                   if (rtnValue !== null) {
                                       if(rtnValue ==='Your login attempt has failed. Make sure the username and password are correct.'){
                                           //component.set("v.mylabel",rtnValue);
                                           component.set("v.message",' Your login attempt has failed. Make sure the username and password are correct.');
                                           component.set("v.errorMessage",true);    
                                           isValid = false;
                                       }else if(rtnValue ==="UserNameError"){
                                           component.set("v.message",' Please fill the username');
                                           component.set("v.errorMessage",true);    
                                           isValid = false;
                                           //component.set("v.mylabel","Please fill the username");
                                       }else if(rtnValue ==="PasswordError"){
                                           component.set("v.message",' Please fill the Password');
                                           component.set("v.errorMessage",true);    
                                           isValid = false;
                                           //component.set("v.mylabel","Please fill the Password");
                                       }
                                       //component.set("v.showError",true);
                                   }
                               });
            
            // Send action off to be executed
            $A.enqueueAction(action);
            
        }
        
    },
    
    doneWaiting: function(component, event, helper) {
        setTimeout(function(){  component.set("v.PageSpinner",false); 
                              
                             }, 300);
        
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "userName":
                component.set("v.UserNameError", false);
                break;
            case "password":
                component.set("v.PasswordError", false);
                break;
                case "userAttempt": 
                component.set("v.errorMessage", false);
                break;
                
                
        }
    },
    
    hideBootstrapErrors1: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "userName1":
                component.set("v.UserNameResetError", false);
                break;
            case "error":
                component.set("v.errorMessage1", false);
                break;
        }
    },
})