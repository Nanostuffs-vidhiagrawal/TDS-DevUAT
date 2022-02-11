({
    doInit: function (component, event, helper) {
        // Get Country codes Picklist Values
        helper.fetchPhoneCodePicklist(component); 
        
        // Get Attributes from component markup
        // let userId = component.get("v.userId");
        let currentURL = window.location.href;
        let userId = currentURL.split("id=")[1];
        let paramString = currentURL.split("branchId=")[1];
        //var branchId = currentURL.searchParams.get("branchId");
        var branchid = paramString.split("&id=")[0];
        component.set("v.branchid",branchid);
        
        // Server Side call to get userInfo
        var action = component.get("c.getSelectedBranchUser");
        action.setParams({
            userId: userId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // Handle Success
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // console.log(result);
                console.log(result.con.Job_role__c +' line--> 19 '+result.con.Additional_Permission__c);
                if (result.con) {
                    component.set("v.con", result.con);
                }
                if (result.selectedPermission) {
                     console.log(result.selectedPermission +' line--> 31');
                  /*     var plValues = [];
                    // console.log(result.selectedPermission+" permissions ");
                   for (var i = 0; i < result.selectedPermission.length; i++) {
                        plValues.push({
                            label: result.selectedPermission[i],
                            value: result.selectedPermission[i]
                        });
                    }*/
                    
                       console.log("selectedPermList "+result.selectedPermission);
                    component.set("v.selectedPermList", result.selectedPermission);
                }
                if (result.con.Job_role__c) {
                    component.set("v.jobRole", result.con.Job_role__c);
                }
                if(result.allbranchList){
                         var plValues = [];
                     console.log(result.allbranchList+" Branchlist "+result.allbranchList[0]);
                   for (var i = 0; i < result.branchList.length; i++) {
                        plValues.push({
                            label: result.allbranchList[i],
                            value: result.allbranchList[i]
                        });
                    }
                  /*       for (var key in result.branchList) {
                          console.log(result.branchList[key].Branch_Name__c+' Key '+key);
       					plValues.push({ label: result.branchList[key].Branch_Name__c, value: result.branchList[key].Branch_Name__c });
       				 }*/
                     console.log("plValues "+plValues);
                    component.set("v.branchList", plValues);  
              		
                }
                 if (result.selectedbranchList) {
                       console.log("selectedBranchList!!@ "+result.selectedbranchList);
                   
                    component.set("v.selectedBranchList", result.selectedbranchList);
                }
                if (result.us.IsActive) {
                    component.set("v.isUserActive", true);
                } else {
                    component.set("v.isUserActive", false);
                }
            }
            // Handle Error
            else if (state === "ERROR") {
                var errors = response.getError();
                // If error then check error type
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // If duplicate username fire toast message
                        
                        // for other errors fire toast Message
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error!",
                            message: errors[0].message,
                            type: "error"
                        });
                    }
                } else {
                    //  console.log("Unknown error");
                }
            }
        });
        
        // Get Picklist Value from Schema
        var action2 = component.get("c.getJobRoles");
        action2.setCallback(this, function (response) {
            var state = response.getState();
            // Handle Success
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // console.log(result);
                // console.log(JSON.stringify(result));
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
                
                component.set("v.permissionmap", permissionmap);
                 component.set("v.permissionList", plValues);
                var salutationMap = [];
                for (var key in result[1]) {
                    salutationMap.push({ key: key, value: result[1][key] });
                }
                component.set("v.salutationMap", salutationMap);
            }
            // Handle Error
            else if (state === "ERROR") {
                var errors = response.getError();
                // If error then check error type
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // If duplicate username fire toast message
                        
                        // for other errors fire toast Message
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error!",
                            message: errors[0].message,
                            type: "error"
                        });
                    }
                } else {
                    //   console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action2);
    },
     backtobranch:function (component, event, helper) {
       // let currentURL = window.location.href;
      //  let branchId = currentURL.split("id=")[1];
         let branchId = component.get("v.branchid");
        // var branchid = currentURL.split("id=")[1]; 
        //  var branchid =component.get("v.branchId");
        var address = "/branches/managebranch";
        var domain = window.location.origin;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
            url: address + "?id=" + branchId
        });
        urlEvent.fire();        
        
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
    deactivateUser: function (component, event, helper) {
        // Get Attributes from component markup
        // let userId = component.get("v.userId");
        
        let currentURL = window.location.href;
        let userId = currentURL.split("id=")[1];
        alert(userId);
        var action = component.get("c.inactiveUser");
        action.setParams({
            userId: userId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //   console.log(state);
            // Handle Success
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                // console.log(JSON.stringify(result));
                if (!result) {
                    component.set("v.reactiveUserSucceessMessage", false);
                    component.set("v.deactiveUserSucceessMessage", true);
                    component.set("v.isUserActive",false);
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "User can been successfully deactivated.",
                        type: "success"
                    });
                    toastEvent.fire();
                    component.find("overlayLib").notifyClose();*/
                }
            }
            // Handle Error
            else if (state === "ERROR") {
                var errors = response.getError();
                // If error then check error type
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.liveDepositError",true);
                        console.log(errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    updateUser: function (component, event, helper) {
        
        // Setting the bootstrap messages to false
        component.set("v.succeessmessage",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.lastNameError",false);
        component.set("v.emailError",false);
        component.set("v.mobileNumError",false);
        component.set("v.invalidFormatTelNumError",false);
        component.set("v.invalidFormatEmailError",false);
        component.set("v.duplicateUsernameError",false);
        
        // Get Attributes from component markup
        let userId = component.get("v.userId");
        // alert(userId);
        // Get Branch Id
        let currentURL = window.location.href;
        let branchId = component.get("v.branchid");
        //alert(branchId);
        // console.log("branchId :" + branchId);
        
        //Get Attributes from Component Markup
        let con = component.get("v.con");
        // console.log("con :" + con);
        //  let salutation = component.find("salutation").get("v.value");
        // console.log("salutation :" + salutation);
        //  let jobRole = component.find("jobRole").get("v.value");
        // console.log("jobRole :" + jobRole);
        //    let permissions = component.find("additionPermission").get("v.value");
        // alert(`155`);
        let jobRole = document.getElementById("jobRoleuser").value;
         let permissions = component.get("v.selectedPermList");
          let branchlist = component.get("v.selectedBranchList");
        let salutation = document.getElementById("usertitle").value;
        let firstName = con.FirstName;
        let lastName = con.LastName;
        let phoneCode = document.getElementById("selectContactPhoneCode").value;
        let conMobile = con.Phone;
        let conEmail = con.Email;
        var allValid = true;
        
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
                component.set("v.invalidFormatTelNumError",true);
                allValid = false;
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
        /* var allValid = component
          .find("field")
          .reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
          }, true);*/
        // alert(`162`);
        
        //  if (allValid && jobRole.length > 0 && salutation.length > 0) {
        if (allValid) {
            //invoke apex controller for DML
            var action = component.get("c.updateBranchUser");
            action.setParams({
                con: con,
                branchList: branchlist,
                salutation: salutation,
                contactPhoneCode: phoneCode,
                jobRole: jobRole,
                permissions: permissions
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // Handle Success
                if (state === "SUCCESS") {
                    //alert('206');
                    var result = response.getReturnValue();
                    component.set("v.data", result);
                    //   console.log("result:", result);
                    // If result has values fire toast Message
                    if (result) {
                        component.set("v.succeessmessage",true);
                        /*var toastEvent = $A.get("e.force:showToast");
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
                        //   Salesforce known issue
                        window.location.reload(); */
                    }
                }
                // Handle Error
                else if (state === "ERROR") {
                    //alert('229');
                    var errors = response.getError();
                    // If error then check error type
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //   console.log("errors[0].message:", errors[0].message);
                            // If duplicate username fire toast message
                            if (errors[0].message.includes("DUPLICATE_USERNAME")) {
                                component.set("v.duplicateUsernameError",true);
                                /*var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: "Error!",
                                    message:
                                    "User is already registered with this email Id in the system",
                                    type: "error"
                                });
                                toastEvent.fire();*/
                            } else {
                                // for other errors fire toast Message
                                /*var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: "Error!",
                                    message: errors[0].message,
                                    type: "error"
                                });
                                toastEvent.fire();*/
                                console.log(errors[0].message);
                            }
                        }
                    } else {
                        // console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } /* else {
      let errorTitle = "ERROR !!";
      let errorMsg = "Please update the invalid form entries and try again";
      helper.errorMessage(component, errorTitle, errorMsg);
      //   alert(`Error`);
    }*/
  },
    
    reactivateUser: function (component, event, helper) {
        // Get Attributes from component markup
        // let userId = component.get("v.userId");
        
        let currentURL = window.location.href;
        let userId = currentURL.split("id=")[1];
        var action = component.get("c.reactiveUser");
        action.setParams({
            userId: userId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //   console.log(state);
            // Handle Success
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // console.log(result);
                // console.log(JSON.stringify(result));
                if (result) {
                    component.set("v.deactiveUserSucceessMessage", false);
                    component.set("v.reactiveUserSucceessMessage", true);
                    component.set("v.isUserActive",true);
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "User can been successfully Activated.",
                        type: "success"
                    });
                    toastEvent.fire();
                    component.find("overlayLib").notifyClose();*/
                }
            }
            // Handle Error
            else if (state === "ERROR") {
                var errors = response.getError();
                // If error then check error type
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // console.log(errors[0].message);
                    }
                } else {
                    //   console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "successmsg":
                component.set("v.succeessmessage", false);
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