({
    doInit: function (component, event, helper) {
        // Get Country codes Picklist Values
        helper.fetchPhoneCodePicklist(component); 
        
        helper.getBranchList(component, event, helper);
        var action = component.get("c.getJobRoles");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var jobRoleMap = [];
                var permissionmap = [];
                 var plValues = [];
                for (var key in result[2]) {
                    jobRoleMap.push({ key: key, value: result[2][key] });
                }
                component.set("v.jobRoleMap", jobRoleMap);
                for (var key in result[3]) {
                    
                    permissionmap.push({ key: key, value: result[3][key] });
                     plValues.push({
                        label: key,
                        value: key
                    });
                }
                console.log(plValues+' Perm '+JSON.stringify(permissionmap));
                component.set("v.permissionmap", permissionmap);
                component.set("v.permissionList", plValues);
                var salutationMap = [];
                for (var key in result[1]) {
                    salutationMap.push({ key: key, value: result[1][key] });
                }
                component.set("v.salutationMap", salutationMap);
            }
        });
        
        $A.enqueueAction(action);
    },
    handleChange:function (component, event, helper) {
          //Get the Selected values   
        var selectedValues = event.getParam("value");
console.log(selectedValues+' selectedValues ');
         
        //Update the Selected Values  
        component.set("v.selectedPermList", selectedValues);
    },
    
    handleBranchChange:function (component, event, helper) {
          //Get the Selected values   
        var selectedValues = event.getParam("value");
		console.log(selectedValues+' selectedValues ');
         
        //Update the Selected Values  
        component.set("v.selectedBranchList", selectedValues);
    },
    
    backtobranch:function (component, event, helper) {
       /* let currentURL = window.location.href;
        let branchId = currentURL.split("id=")[1];
        // var branchid = currentURL.split("id=")[1]; 
        //  var branchid =component.get("v.branchId");
        var address = "/branches/managebranch";
        var domain = window.location.origin;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
            url: address + "?id=" + branchId
        });
        urlEvent.fire();     */
        window.history.back();
        
    },  
    
    handleClick: function (component, event, helper) {
        // Get Branch Id
        let currentURL = window.location.href;
        let branchId = currentURL.split("id=")[1];
        //Get Attributes from Component Markup
        let con = component.get("v.con");
        let salutation = component.find("salutation").get("v.value");
        let jobRole = component.find("jobRole").get("v.value");
        let permissions = component.find("additionPermission").get("v.value");
        let conEmail = con.Email;
        
        console.log("permissions :" + permissions);
        // console.log("jobRole :" + jobRole);
        // console.log("salutation :" + salutation);
        // console.log("branchId :" + branchId);
        // console.log("con :" + con);
        
        var allValid = component
        .find("field")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if (allValid && jobRole.length > 0 && salutation.length > 0) {
            // alert(`valid`);
            //invoke apex controller for DML
            var action = component.get("c.createBranchUser");
            action.setParams({
                con: con,
                branchId: branchId,
                salutation: salutation,
                jobRole: jobRole,
                permissions: permissions
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // Handle Success
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.data", result);
                    // If result has values fire toast Message
                    if (result) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success!",
                            message: "User has been added to the branch successfully.",
                            type: "success"
                        });
                        toastEvent.fire();
                        // Refresh the View
                        $A.get("e.force:refreshView").fire();
                        // Close overlay library
                        component.find("overlayLib").notifyClose();
                        //Salesforce known Bug
                        window.location.reload();
                    }
                }
                // Handle Error
                else if (state === "ERROR") {
                    var errors = response.getError();
                    // If error then check error type
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            // If duplicate username fire toast message
                            if (errors[0].message.includes("DUPLICATE_USERNAME")) {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: "Error!",
                                    message:
                                    "User is already registered with this email Id in the system",
                                    type: "error"
                                });
                                toastEvent.fire();
                            } else {
                                // for other errors fire toast Message
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: "Error!",
                                    message: errors[0].message,
                                    type: "error"
                                });
                                toastEvent.fire();
                            }
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            let errorTitle = "ERROR !!";
            let errorMsg = "Please update the invalid form entries and try again";
            helper.errorMessage(component, errorTitle, errorMsg);
        }
    },
    
    handleClick1: function (component, event, helper) {
       
        // Setting the bootstrap messages to false
        component.set("v.succeessmessage",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.lastNameError",false);
        component.set("v.emailError",false);
        component.set("v.PhonelengthError", false);
        component.set("v.mobileNumError",false);
        component.set("v.invalidFormatTelNumError",false);
        component.set("v.invalidFormatEmailError",false);
        component.set("v.duplicateUsernameError",false);
        
        // Get Branch Id
        let currentURL = window.location.href;
        let branchId = currentURL.split("id=")[1];
        //alert(branchId);
        //Get Attributes from Component Markup
        let con = component.get("v.con");
        //let salutation = component.find("salutation").get("v.value");
        // let jobRole = component.find("jobRole").get("v.value");
        //  let permissions = component.find("additionPermission").get("v.value");
        let jobRole = document.getElementById("jobRoles").value;
        let permissions = component.get("v.selectedPermList");
          let branchlist = component.get("v.selectedBranchList");
        
        let salutation = document.getElementById("title").value;
        let firstName = con.FirstName;
        let lastName = con.LastName;
        let phoneCode = document.getElementById("selectContactPhoneCode").value;
        let conMobile = con.Phone;
        let conEmail = con.Email;
        var allValid = true;
        console.log("permissions "+permissions);
        if (salutation == undefined || salutation == "" || salutation == null || salutation == "-- Select Title --") {  
            component.set("v.titleError",true);    
            allValid = false;
        }
        if (firstName == undefined || firstName == "" || firstName == null) {  
            component.set("v.firstNameError",true);    
            allValid = false;
        }
        if (lastName == undefined || lastName == "" || lastName == null) {
            component.set("v.lastNameError",true);    
            allValid = false;
        }
        if (conMobile == undefined || conMobile == "" || conMobile == null) {
            component.set("v.mobileNumError",true);    
            allValid = false;
        } else {
            var isMobilePatternValid = helper.phoneFormatChecker(component, phoneCode, conMobile);
            if(!isMobilePatternValid)
            {
                if(phoneCode == "+44"){
                    component.set("v.PhonelengthError",true);
                    allValid = false;
                }else{
                    component.set("v.invalidFormatTelNumError",true);
                    allValid = false;
                }
            }
        }
        if (conEmail == undefined || conEmail == "" || conEmail == null) {
            component.set("v.emailError",true);    
            allValid = false;
        } else {
			var isEmailPatternValid = helper.emailFormatChecker(component, conEmail);
            if(!isEmailPatternValid)
            {
                component.set("v.invalidFormatEmailError",true);
                allValid = false;
            }
        }
        
        /*var allValid = component
        .find("field")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);*/
        //console.log('Working');
        //if (allValid && jobRole.length > 0 && salutation.length > 0) {
        if (allValid) {   
           
            //invoke apex controller for DML
            var action = component.get("c.createBranchUser");
            action.setParams({
                con: con,
                branchList: branchlist,
                salutation: salutation,
                contactPhoneCode:phoneCode,
                jobRole: jobRole,
                permissions: permissions
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                  alert(state+' state');
                // Handle Success
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                     document.body.scrollTop = 0;
				document.documentElement.scrollTop = 0;
                      component.set("v.succeessmessage",true);
                      setTimeout(function(){
                        component.find("navService").navigate({
                            type: "standard__namedPage",
                            attributes: {
                                pageName: "home"
                            },
                            state: {branchId: branchid}
                        });
                            }, 500);
                }
                // Handle Error
                else if (state === "ERROR") {
                      document.body.scrollTop = 0;
				document.documentElement.scrollTop = 0;
                    var errors = response.getError();
                    // If error then check error type
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                           
                            if (errors[0].message.includes("DUPLICATE_USERNAME")) {
                                component.set("v.duplicateUsernameError",true);
                           
                            } else {
                             
                                console.log(errors[0].message);
                            }
                        }
                    } else {
                          document.body.scrollTop = 0;
						document.documentElement.scrollTop = 0;
 						component.set("v.generalError",true);
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
             case "generalErrorName":
                component.set("v.generalError", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;
            case "title":
                component.set("v.titleError", false);
                break;
            case "firstName":
                component.set("v.firstNameError", false);
                break;
            case "lastName":
                component.set("v.lastNameError", false);
                break;
            case "emailOfUser":
                component.set("v.emailError", false);
                break;
            case "Phonelength":
                component.set("v.PhonelengthError", false);
                break;
            case "mobileNumber":
                component.set("v.mobileNumError", false);
                break;
            case "invalidFormatTelNum":
                component.set("v.invalidFormatTelNumError", false);
                break;
            case "invalidFormatEmail":
                component.set("v.invalidFormatEmailError", false);
                break;
            case "duplicateUsername":
                component.set("v.duplicateUsernameError", false);
                break;
        }
    },
});