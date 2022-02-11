({
    doInit : function(component, event, helper) {
        //error messages
         helper.getError(component, event, helper);
    
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
         console.log('queryString '+queryString);
  
        if(urlParams.has("uname")){
            // const uname = urlParams.get('uname');
            // const pword = urlParams.get('pword');
            const uname = decodeURIComponent(window.location.search.substring(1).split('&')[0].split('=')[1]);
            const pword  = decodeURIComponent(window.location.search.substring(1).split('&')[1].split('=')[1]);
            console.log('uname '+uname+' $$ pwd '+pword);
           // debugger;
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
                                       console.log('@@rtnValue '+rtnValue);
                                      if(rtnValue ==='Your login attempt has failed. Make sure the username and password are correct.'){
                                           //component.set("v.mylabel",rtnValue);
                                           component.set("v.message",'Your login attempt has failed. Make sure the username and password are correct.');
                                           component.set("v.errorMessage",true);    
                                         
                                      }else{
                                            window.open(rtnValue,"_self");  
                                      }
                                           
                                   });
                $A.enqueueAction(action);
            }
        }
    },
     submitOnEnter: function(component, event, helper) {
    // var rac = component.get("v.searchText");
    //alert(rac);
    if (event.keyCode === 13) {
        console.log('clicked');
         helper.getInputHelper(component, event, helper);  
    }
  },
    RegisterPage: function (component, event, helper) {
        console.log('test');
        // var currentURL = window.location.href;   
        var startURL = helper.getUrlParams('startURL');
        
        var signUPStrtURL = "login/SelfRegister";
        if(startURL){
            signUPStrtURL =  signUPStrtURL + "?startURL=" + startURL;
        }
        
        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+signUPStrtURL;
        window.location.replace(urlRedirect);
        return false;
    },
    
    /*This function is used to reset the password */
    resetPwd : function (component,event, helpler) {
        component.set("v.UserNameResetError",false);
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
                console.log('==='+rtnValue);
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
                        console.log('=isShowResetModal='+component.get("v.isShowResetModal"));
                        
                    }
                    
                }
            });
            
            // Send action off to be executed
            $A.enqueueAction(action);
        }
    }, 
    
    getInput: function (component, event, helper) {
      //  debugger;
      helper.getInputHelper(component, event, helper);  
      
    },
    
    doneWaiting: function(component, event, helper) {
        setTimeout(function(){  component.set("v.PageSpinner",false); 
                 helper.getCookies(component, event, helper);              
                             }, 1300);
        
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
            case "userName1":
                component.set("v.UserNameResetError", false);
                break;
           case "error":
                component.set("v.errorMessage1", false);
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