({
    fetchdata: function(component, event, helper) {
          const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        var action = component.get("c.showusers");
        action.setParams({
            
            branchId:branchid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var datalist = response.getReturnValue();
                console.log("line-->09 " + JSON.stringify(datalist));
                if (datalist.length > 0) {
                    component.set("v.listOfAllrecords", datalist);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = datalist;
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);
                    
                    var PaginationLst = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.listOfAllrecords").length > i) {
                            PaginationLst.push(datalist[i]);
                        }
                    }
                    component.set("v.PaginationList", PaginationLst);
                    component.set("v.selectedCount", 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
                }
            } else if (state === "INCOMPLETE") {
                //  alert('incomplete');
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("line--14" + JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message43: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
        helper.getSalutationofpopup(component, event);
        // Get Country codes Picklist Values
        helper.fetchPhoneCodePicklist(component); 
        helper.getError(component, event, helper);
    },
    
  /*  opennewuser: function(component, event, helper) {
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.mobileError",false);
        component.set("v.levelOfAccesserror",false);
        component.set("v.duplicateemailerror",false);
        component.set("v.succeessmessage",false);
        component.set("v.updatesucceessmessage",false);
        
    },*/
        handleChange:function (component, event, helper) {
          //Get the Selected values   
        var selectedValues = event.getParam("value");
		console.log(selectedValues+' selectedValues ');
         
        //Update the Selected Values  
        component.set("v.selectedPermList", selectedValues);
    },
    editInformation: function(component, event, helper) {
        component.set("v.userDetailsEdit", false);
        component.set("v.toggleUserDetails", true);
        component.set("v.suspendUserDetails", false);
        component.set("v.reactivateUserDetails", false);
    },
    
    addNewUser: function(component, event, helper) {
        console.log(`Clicked`);
        var modalBody;
        $A.createComponent("c:userCreatenew", {}, function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                component.find("overlayLib").showCustomModal({
                    header: "Add an additional user",
                    body: modalBody,
                    showCloseButton: true,
                    cssClass: "mymodal slds-modal_medium",
                    closeCallback: function() {
                        console.log("You closed the alert!");
                    }
                });
            }
        });
    },
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllrecords");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = Number(component.get("v.pageSize"));
        //var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (event.target.id == "nextId") {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (event.target.id == "previousId") {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    Viewuser: function(component, event, helper) {
        var clickedBtn = event.getSource().get("v.value");
        //alert(clickedBtn);
        $A.createComponent("c:viewuser", { strRecordId: clickedBtn }, function(
            content,
            status
        ) {
            if (status === "SUCCESS") {
                var modalBody = content;
                component.find("overlayLib1").showCustomModal({
                    //header: "View user details",
                    body: modalBody,
                    showCloseButton: true,
                    cssClass: "mymodal slds-modal_small"
                });
            }
        });
    },
    
    reactivate: function(component, event, helper) {
        var contid = component.get("v.conobj.Id");
        var action = component.get("c.reactivateUser");
        action.setParams({ contactid : contid });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS") {
                if(res=='User active'){
                    component.set("v.suspendUserDetails", true);
            		component.set("v.reactivateUserDetails", false);
                     component.set("v.success", true);
                     component.set("v.succeessmessage1", "User is reactivated");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleConfirmDialog: function(component, event, helper) {
         component.set('v.showConfirmDialog', true);
    },
    
    suspendUser: function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        var contid = component.get("v.conobj.Id");
        var action = component.get("c.makeUserInactive");
        action.setParams({ contactid : contid });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS") {
                if(res=='User Inactive'){
                     component.set("v.suspendUserDetails", false);
            		 component.set("v.reactivateUserDetails", true);
                     component.set("v.success", true);
                     component.set("v.succeessmessage1", "User is suspended");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    Deluser: function(component, event, helper) {
        var clickedid = event.getSource().get("v.value");
        var action = component.get("c.removeuser");
        action.setParams({ Uid: clickedid });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("line-->8" + JSON.stringify(response.getReturnValue()));
                window.location.reload();
            } else if (state === "INCOMPLETE") {
                //alert('incomplete');
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("line--14" + JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message199: " + errors[0].message);
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        type: "error",
                        message:
                        "This account has live deposit protections and cannot be archived."
                    });
                    toastEvent.fire();
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
      
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
    },
    
    getuserdetailstoedit: function(component, event, helper) {
        //alert('conid');
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.mobileError",false);
        component.set("v.levelOfAccesserror",false);
        component.set("v.duplicateEmailError",false);
        component.set("v.succeessmessage",false);
        component.set("v.updatesucceessmessage",false);        
        var contid = event.target.id;
        //   alert(contid);
        
        var action = component.get("c.contactdetails");
        action.setParams({ conid: contid });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //  alert("From server: " + response.getReturnValue());
                var result = response.getReturnValue();
                component.set("v.conobj", result.con);
                component.set("v.userDetailsEdit", true);
                console.log(result.con.Additional_Permission__c+' @@ 248 '+result.con.Job_role__c);
                 component.set("v.selectedPermList", result.selectedPermission);
            $('#edituser').modal('show');
                
              
              
                if(component.get("v.conobj.User_Status__c")==$A.get("$Label.c.Active")){
                    component.set("v.suspendUserDetails", true);
                    component.set("v.reactivateUserDetails", false);
                    component.set("v.toggleUserDetails", false);
                }
                else if(component.get("v.conobj.User_Status__c")==$A.get("$Label.c.Suspend")){
                    component.set("v.suspendUserDetails", false);
                    component.set("v.reactivateUserDetails", true);
                    component.set("v.toggleUserDetails", false);
                }
                
              
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message303: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
          var actionjobRole = component.get("c.getJobRoles");
        actionjobRole.setCallback(this, function (response) {
            var state = response.getState();
            // Handle Success
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // console.log(result);
                // console.log(JSON.stringify(result));
                var jobRoleMap = [];
                for (var key in result[0]) {
                    jobRoleMap.push({ key: key, value: result[0][key] });
                }
                component.set("v.jobRoleMap", jobRoleMap);
            }
        });
         $A.enqueueAction(actionjobRole); 
        $A.enqueueAction(action);
    },
    
    updateuser: function(component, event, helper) {
          
        component.set("v.titleError", false);
        component.set("v.firstNameError", false);
        component.set("v.surNameError", false);
        component.set("v.emailError", false);
        component.set("v.duplicateEmailError", false);
        component.set("v.PhonelengthError",false);
        component.set("v.mobileError", false);
        component.set("v.levelOfAccesserror", false);
        component.set("v.succeessmessage", false);
        component.set("v.success", false);
        component.set("v.updatesucceessmessage", false);
        component.set("v.succeessmessage1", false);
        
        var clickedBtn = event.target.id;
        var isValid = true;
        var jobrolecheck = document.getElementById("jobRoleuser").value;
        var addpermissioncheck = component.get("v.selectedPermList");
        var salutation = document.getElementById("selectedId2").value;
        var firstnamecheck = component.find("firstname1").get("v.value");
        var surnamecheck = component.find("surname1").get("v.value");
        var emailcheck = component.find("email1").get("v.value");
        var phoneCode = document.getElementById("selectEditPhoneCode").value;
        var telephonecheck = component.find("telephone1").get("v.value");
        
        //  alert('line-->182' + addpermissioncheck);
        var conobj = component.get("v.conobj");
        if (salutation == undefined || salutation == "" || salutation == null || salutation == "-- Select Title --") {  
            component.set("v.titleError",true);    
            isValid = false;
        }
        else{
            component.set("v.titleError",false); 
        }
        if (firstnamecheck == undefined || firstnamecheck == "" || firstnamecheck == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.firstNameError",false); 
        }
        if (surnamecheck == undefined || surnamecheck == "" || surnamecheck == null) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.surNameError",false); 
        }
        if (telephonecheck == undefined || telephonecheck == "" || telephonecheck == null) {
            component.set("v.mobileError",true);    
            isValid = false;
        }
        else if (phoneCode == "+44" && (telephonecheck.length != 11 || !telephonecheck.startsWith("07"))) {
            component.set("v.PhonelengthError",true);    
            isValid = false;
        }else{
            component.set("v.mobileError", false);
            component.set("v.PhonelengthError",false);   
        }
        if (jobrolecheck == undefined || jobrolecheck == "" || jobrolecheck == null || jobrolecheck == "-- Select Role --") {
            component.set("v.levelOfAccesserror",true);    
            isValid = false;
        }
        else{
            component.set("v.levelOfAccesserror",false); 
        }
        if(isValid){
            
            var action = component.get("c.updatedetails");
            action.setParams({
                con: conobj,
                jobrole: jobrolecheck,
                salutation:salutation,
                phoneCode:phoneCode,
                userpermission:addpermissioncheck
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    //  alert("From server: " + response.getReturnValue());
                    var result = response.getReturnValue();
                    //alert(result);
                    if (result == "Duplicate Email" || result == "Duplicate Name") {
                       // alert("if duplicate email true" + result);
                        component.set("v.duplicateEmailError",true);                     
                    }
                    else {
                        component.set("v.updatesucceessmessage", true);
                    }
                    // $A.get('e.force:refreshView').fire();
                        $('#maincon', window.parent.document).get(0).scrollIntoView();
                    setTimeout(function(){ 
                     $('#edituser').modal('hide');
                         helper.fetchDataOnUpdate(component, event, helper);
                        }, 500);
                }
                else if (state === "INCOMPLETE") {
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message414: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                             $('#maincon', window.parent.document).get(0).scrollIntoView();
                    }
            });
            
            $A.enqueueAction(action);
        }else{
              $('#maincon', window.parent.document).get(0).scrollIntoView();
        }
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "title":
                component.set("v.titleError", false);
                break;
            case "firstName":
                component.set("v.firstNameError", false);
                break;
            case "surName":
                component.set("v.surNameError", false);
                break;
            case "emailOfUser":
                component.set("v.emailError", false);
                break;
            case "Phonelength":
                component.set("v.PhonelengthError",false);
                break;
            case "mobileNumber":
                component.set("v.mobileError", false);
                break;
            case "levelOfAccess":
                component.set("v.levelOfAccesserror", false);
                break;
            case "duplicateEmail":
                component.set("v.duplicateEmailError",false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;
            case "successbutton":
                component.set("v.success", false);
                break;
            case "updatesuccessmsg":
                component.set("v.updatesucceessmessage", false);
                break;
           case "success":
                component.set("v.succeessmessage1", false);
                break;
        }
    },
    
    createuser: function(component, event, helper) {
        
        component.set("v.titleError", false);
        component.set("v.firstNameError", false);
        component.set("v.surNameError", false);
        component.set("v.emailError", false);
        component.set("v.isDuplicateEmail", false);
        component.set("v.duplicateEmailError", false);
        component.set("v.PhonelengthError",false);
        component.set("v.mobileError", false);
        component.set("v.levelOfAccesserror", false);
        component.set("v.succeessmessage", false);
        component.set("v.success", false);
        component.set("v.updatesucceessmessage", false);
        component.set("v.succeessmessage1", false);
        
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        var isValid = true;
        var additionalpermission = component.get("v.selectedPermList");
        console.log('additionalpermission '+additionalpermission);
        var jobrolecheck = component.find("jobrole").get("v.value");
        var salutation = document.getElementById("mySelect").value;
        var firstnamecheck = component.find("firstname").get("v.value");
        var surnamecheck = component.find("surname").get("v.value");
        var emailcheck = component.find("email").get("v.value");
        var phoneCode = document.getElementById("selectPhoneCode").value;
        var telephonecheck = component.find("telephone").get("v.value");
        var act = component.get("v.act");
        
        helper.checkDuplicacyForADD(component, act);
        var isDuplicateEmail;
        
        if (salutation == undefined || salutation == "" || salutation == null || salutation == "-- Select Title --") {  
            component.set("v.titleError",true);    
            isValid = false;
        } 
        else{
            component.set("v.titleError",false); 
        }
        if (firstnamecheck == undefined || firstnamecheck == "" || firstnamecheck == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.firstNameError",false); 
        }
        if (surnamecheck == undefined || surnamecheck == "" || surnamecheck == null) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.surNameError",false); 
        }
        if (emailcheck == undefined || emailcheck == "" || emailcheck == null) {
            component.set("v.emailError",true);    
            isValid = false;
        }
        else{
            component.set("v.emailError",false); 
            isDuplicateEmail = component.get("v.isDuplicateEmail");
           // alert("Add isDuplicate : " + isDuplicateEmail);
             if(isDuplicateEmail){
                isValid = false;
            }
        }
        if (telephonecheck == undefined || telephonecheck == "" || telephonecheck == null) {
            component.set("v.mobileError",true);    
            isValid = false;
        }
        else if (phoneCode == "+44" && (telephonecheck.length != 11 || !telephonecheck.startsWith("07"))) {
            component.set("v.PhonelengthError",true);    
            isValid = false;
        }else{
            component.set("v.mobileError", false);
            component.set("v.PhonelengthError",false);   
        }
        if (jobrolecheck == undefined || jobrolecheck == "" || jobrolecheck == null || jobrolecheck == "-- Select Role --") {
            component.set("v.levelOfAccesserror",true);    
            isValid = false;
        }
        else{
            component.set("v.levelOfAccesserror",false); 
        }
        if(isValid){
            var action = component.get("c.usercreate");
            action.setParams({
                branchId:branchid,
                salute: salutation,
                phoneCode: phoneCode,
                userpermission:additionalpermission,
                act: act,
                jobrole: jobrolecheck
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    $('#userHeader', window.parent.document).get(0).scrollIntoView();
                    
                     setTimeout(function(){ 
                     $('#addUser').modal('hide');
                         helper.fetchDataOnUpdate(component, event, helper);
                        }, 500);

                    
                    var result = response.getReturnValue();
                    console.log("line--192  " + result);
                    //if (result) {
                        component.set("v.succeessmessage", true);
                    //}
                        /*   $("#personalAlert")
            .removeClass("hide")
            .addClass("show");
          $("#personalErrorAlert")
            .removeClass("show")
            .addClass("hide");

          $A.get("e.force:refreshView").fire();
         /* var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "User has been created successfully.",
            type: "success"
          });
          toastEvent.fire();

          component.find("overlayLib").notifyClose();*/
        
      } else if (state === "ERROR") {
              $('#userHeader', window.parent.document).get(0).scrollIntoView();
          var errors = response.getError();
          console.log("line-->41" + JSON.stringify(errors));
          // If error then check error type
          if (errors) {
              if (errors[0] && errors[0].message) {
                  // If duplicate username fire toast message
                  if (errors[0].message.includes("DUPLICATE_USERNAME")) {
                      /* var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                title: "Error!",
                message:
                  "User is already registered with this email Id in the system",
                type: "error"
              });
              toastEvent.fire();*/
                component.set("v.duplicateEmailError", true);
            } else {
                // for other errors fire toast Message
                /* var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                title: "Error!",
                message: errors[0].message,
                type: "error"
              });
              toastEvent.fire();*/
            }
          }
        } else {
            console.log("Unknown error");
        }
      }
    });
          $A.enqueueAction(action);
        }else{
                $('#userHeader', window.parent.document).get(0).scrollIntoView();
        }
  },
    
    cancelRefresh:function(component, event, helper) {
        
   helper.fetchDataOnUpdate(component, event, helper);
      
    },
    
    resetform:function(component, event, helper){
        component.set("v.titleError", false);
        component.set("v.firstNameError", false);
        component.set("v.surNameError", false);
        component.set("v.emailError", false);
        component.set("v.PhonelengthError",false);
        component.set("v.mobileError", false);
        component.set("v.levelOfAccesserror", false);
        component.set("v.duplicateEmailError", false);
        component.set("v.success", false);
        component.set("v.updatesucceessmessage", false);
        component.set("v.succeessmessage", false);
        component.set("v.succeessmessage1", false);
        document.getElementById("myform").reset();
        
    }
});