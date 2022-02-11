({
    getBranchList: function (component, event, helper) {
            var action2 = component.get("c.getBranches");
        action2.setCallback(this, function (response) {
            var state = response.getState();
              console.log('statebranch '+state);
            if (state === "SUCCESS") {
               var result = response.getReturnValue();
                console.log('resultbranch '+result);
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i].Branch_Name__c,
                        value: result[i].Branch_Name__c
                    });
                }
                component.set("v.branchList", plValues);            }
        
        });
        
          $A.enqueueAction(action2);
    },
    successMessage: function (component, successTitle, successMsg) {
        $A.createComponent(
            "c:EI_successToastMessage",
            {
                successMsg: successMsg,
                successTitle: successTitle
            },
            function callback(component, status) {
                if (status === "SUCCESS") {
                    $A.get("e.force:refreshView").fire();
                } else if (status === "ERROR") {
                    alert("status" + successMsg);
                    $A.get("e.force:refreshView").fire();
                }
            }
        );
    },
    
    errorMessage: function (component, errorTitle, errorMsg) {
        $A.createComponent(
            "c:EI_errorToastMessage",
            {
                errorMsg: errorMsg,
                errorTitle: errorTitle
            },
            function callback(component, status) {
                if (status === "ERROR") {
                    alert(`${errorTitle} : ${errorMsg}`);
                }
            }
        );
    },
    
    genericErrorMessage: function (component) {
        let errorTitle = "Error !!";
        let errorMsg =
            "Oops !! Something unexpected happened. Please contact Support Team";
        $A.createComponent(
            "c:EI_errorToastMessage",
            {
                errorMsg: errorMsg,
                errorTitle: errorTitle
            },
            function callback(component, status) {
                if (status === "ERROR") {
                    alert("status" + errorMsg);
                }
            }
        );
    },
    
    emailFormatChecker: function (component, emailCheck) {
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!$A.util.isEmpty(emailCheck)) {
            return (emailCheck.match(regExpEmailformat)) ? true: false;
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
            //return (mobileCheck.match(regExpPhoneformat)) ? true: false;
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