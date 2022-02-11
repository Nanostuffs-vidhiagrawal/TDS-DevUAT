({
    
    checkEmailDuplicacy: function (component, email) {
        console.log('emailDuplicate '+email);
        
        var IsOrg = component.get("v.IsOrg");
        let firstname = "" ;
        let surname = "" ;
        if(!IsOrg){
            firstname = component.find("firstNameId").get("v.value");
            surname = component.find("surNameId").get("v.value");
        }
        
        var action = component.get("c.checkDuplicateEmail");
        action.setParams({
            email: email,
            phone: "",
            firstname: firstname,
            surname: surname,
            type: "onlyemail"
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                // var inputCmp = component.find("emailfield");
                if (result === "Duplicate email" || result === "Duplicate Name") {
                    component.set("v.IsDuplicateEmail",true);
                    component.set("v.duplicateEmailError",true);
                    document.getElementById("sf-tabContent").scrollIntoView();
                    //inputCmp.setCustomValidity("This email Id is already registered");
                }else {
                    component.set("v.IsDuplicateEmail",false);
                    component.set("v.duplicateEmailError",false);
                    //inputCmp.setCustomValidity("");
                }
                inputCmp.reportValidity();
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },
    
    checkPhoneDuplicacy: function (component, phone) {
        // alert(phone);
        
        let firstname = component.find("firstNameId").get("v.value");
        let surname = component.find("surNameId").get("v.value");
        
        var action = component.get("c.checkDuplicateEmail");
        action.setParams({
            email: "",
            type: "onlyphone",
            firstname: firstname,
            surname: surname,
            phone: phone
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                var inputCmp = component.find("phonefield");
                if (result === "Duplicate Phone") {
                    inputCmp.setCustomValidity("");
                    document.getElementById("sf-tabContent").scrollIntoView();
                    //inputCmp.setCustomValidity("This Phone is already registered");
                } else {
                    inputCmp.setCustomValidity("");
                }
                inputCmp.reportValidity();
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },
    
    checkEmailInSystem: function (component, email) {
        console.log('emailviaten2 '+email);
        var action = component.get("c.checkDuplicateEmail");
        action.setParams({
            email: email,
            phone: "",
            type: "onlyemail"
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                var inputCmp = component.find("emailfield");
                if (result === "Duplicate email") {
                    // component.set("v.IsDuplicateEmail",true);
                    //  component.set("v.duplicateEmailError",true);
                    return true;
                    // inputCmp.setCustomValidity("This email Id is already registered");
                } else {
                    //  component.set("v.IsDuplicateEmail",false);
                    //  component.set("v.duplicateEmailError",false);
                    return false;
                    //  inputCmp.setCustomValidity("");
                }
                inputCmp.reportValidity();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    console.log(errors[0].message);
                    console.error(errors[0].message);
                    
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    emailFormatChecker: function (component, email) {
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!$A.util.isEmpty(email)) {
           return (email.match(regExpEmailformat)) ? true: false;
        }  
    },
    
    phoneFormatChecker: function (component, phoneCode,  mobileCheck) {
        //alert("phoneCode helper => " + phoneCode);
        var regExpPhoneformat = /^07[0-9]\d{8}$/;
        var letters = /^[0-9]+$/;
        
        if (!$A.util.isEmpty(mobileCheck)) {
            if(!$A.util.isEmpty(phoneCode) && phoneCode == "+44"){
                return (mobileCheck.match(regExpPhoneformat)) ? true: false;
            }else{
                return (mobileCheck.match(letters)) ? true: false;
            }  
        }  
    },
    
    fetchPhoneCodePicklist : function(component, event, helper){
        var action = component.get("c.getPhoneCodePiclistValues");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.phoneCodePicklist", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    apex : function( component, apexAction, params ) {
    var p = new Promise( $A.getCallback( function( resolve , reject ) { 
        var action = component.get("c."+apexAction+"");
       // action.setParams( params );
        action.setCallback( this , function(callbackResult) {
            if(callbackResult.getState()=='SUCCESS') {
                resolve( callbackResult.getReturnValue() );
            }
            if(callbackResult.getState()=='ERROR') {
                console.log('ERROR', callbackResult.getError() ); 
                reject( callbackResult.getError() );
            }
        });
        $A.enqueueAction( action );
    }));            
    return p;
},
    
 getError:function (component, event, helper){
       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
        console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
            component.set("v.errorList",response.getReturnValue());
                  var  errorList= component.get("v.errorList");  
                	var userErr;                
              for(var i=0; i<errorList.length; i++){
                  console.log("line-->9  " +errorList[i].MasterLabel );
                   console.log("line-->9  " +errorList[i].Error_Message__c );
                  if(errorList[i].MasterLabel === 'Tenant Title'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.TitleErrorNew",userErr);
                  }
                     else if(errorList[i].MasterLabel === 'Tenant First Name'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.FirstNameErrorNew",userErr);
                  } 
                  
                   else if(errorList[i].MasterLabel === 'Tenant Surname'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.SurnameErrorNew",userErr);
                  }
                     else if(errorList[i].MasterLabel === 'Tenant Mobile No'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.PhoneErrorNew",userErr);
                  }  
                  else if(errorList[i].MasterLabel === 'Tenant Exist'){
                      //console.log("line-->198  " +errorList[i].Error_Message__c );
                      userErr = errorList[i].Error_Message__c;                       
                  component.set("v.TenantExistErrorNew",userErr);
                  } 
                  
                  else if(errorList[i].MasterLabel === 'Phone Number'){
                      //console.log("line-->198  " +errorList[i].Error_Message__c );
                      userErr = errorList[i].Error_Message__c;                       
                  component.set("v.TenantPhoneErrorNew",userErr);
                  }  
                  
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }   
    
});