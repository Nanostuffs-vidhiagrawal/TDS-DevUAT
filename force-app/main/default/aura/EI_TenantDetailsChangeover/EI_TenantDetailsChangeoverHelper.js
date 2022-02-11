({
    checkEmailDuplicacy: function (component, email) {
        // alert(email);
        let firstname = component.find("firstNameId").get("v.value");
        let surname = component.find("surNameId").get("v.value");
        
        var action = component.get("c.checkDuplicateEmail");
        action.setParams({
            email: email,
            type: "onlyemail",
            phone: "",
            firstname: firstname,
            surname: surname
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('line 14 result - ',result);
                //var inputCmp = component.find("emailfield");
                if (result === "Duplicate email" || result == "Duplicate Name") {
                    //inputCmp.setCustomValidity("This email Id is already registered");
                    component.set("v.IsDuplicateEmail", true);
                    component.set("v.duplicateEmailError",true);
                } else {
                    component.set("v.IsDuplicateEmail", false);
                    component.set("v.duplicateEmailError", false);
                    //inputCmp.setCustomValidity("");
                }
                //inputCmp.reportValidity();
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },
    
    checkPhoneDuplicacy: function (component, phone) {
        // alert(phone);
        var action = component.get("c.checkDuplicateEmail");
        action.setParams({
            email: "",
            type: "onlyphone",
            phone: phone,
            firstname: "",
            surname: ""
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                var inputCmp = component.find("phonefield");
                if (result === "Duplicate Phone") {
                    inputCmp.setCustomValidity("This Phone is already registered");
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
    // alert(email);
    var action = component.get("c.checkDuplicateEmail");
    action.setParams({
        email: email,
        phone: "",
        type: "onlyemail",
        firstname: "",
        surname: ""
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
    
    phoneFormatChecker: function (component, phoneCode, mobileCheck) {
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
    }
    
});