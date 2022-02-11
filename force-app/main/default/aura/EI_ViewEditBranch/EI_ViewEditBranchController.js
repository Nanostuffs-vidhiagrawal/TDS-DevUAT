({
    doInit: function (component, event, helper) {
        // Get Country codes Picklist Values
        helper.fetchPhoneCodePicklist(component); 
        
        let currentURL = window.location.href;
        let branchId = currentURL.split("id=")[1];
        component.set("v.branchId",branchId);
        
        console.log(branchId);
        var action = component.get("c.fetchBranch");
        action.setParams({
            branchId: branchId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if (!result.Is_Active__c) {
                    let btnVisibility = component.find("btnVisibility");
                    
                    btnVisibility.set("v.disabled", true);
                    
                    btnVisibility.set(
                        "v.title",
                        "User cannot be added in Inactive Branch"
                    );
                }
                component.set("v.branch", result);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(`${errors}`);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    enableEdit: function (component, event, helper) {
        component.set("v.fieldnotEdit", false);
        component.set("v.toogle", false);
        var action = component.get("c.getCountries");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(state);
                var result = response.getReturnValue();
                console.log(result);
                console.log(JSON.stringify(result));
                var countryMap = [];
                for (var key in result) {
                    countryMap.push({ key: key, value: result[key] });
                }
                component.set("v.countryMap", countryMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveRecord: function (component, event, helper) {
        let IsValueChanged = component.get("v.valueChanged");
        if (IsValueChanged) {
            // Setting the bootstrap messages to false
            component.set("v.branchUpdatedSuccess",false);
            component.set("v.noChangesDoneError",false);
            component.set("v.branchNameError",false);
            component.set("v.PhonelengthError", false);
            component.set("v.altPhonelengthError", false);
            component.set("v.telphoneNumberError",false);
            component.set("v.addressError",false);
            component.set("v.invalidFormatTelNumError",false);
            component.set("v.invalidFormatEmailError",false); 
            
            let branch = component.get("v.branch");
            var phoneCode = document.getElementById("selectPhoneCode").value;
            var altPhoneCode = document.getElementById("selectAltPhoneCode").value;
            var allValid = true;
            //alert("phoneCode => " + phoneCode);
            //alert("altPhoneCode => " + altPhoneCode);
            /*var allValid = component
            .find("mandate")
            .reduce(function (validSoFar, inputCmp) {
              inputCmp.showHelpMessageIfInvalid();
              return validSoFar && inputCmp.get("v.validity").valid;
            }, true);*/
            
            if(!branch.Branch_Name__c)
            {
                //console.log(`branch -> ${branch.Branch_Name__c}`);
                component.set("v.branchNameError",true);
                allValid = false;
            }
            if(!branch.Telephone_no__c)
            {
                //console.log(`Telephone_no__c -> ${branch.Telephone_no__c}`);
                component.set("v.telphoneNumberError",true);
                allValid = false;
            }
            else
            {
                //console.log(`Telephone_no__c -> ${branch.Telephone_no__c}`);
                let telephoneCheck = helper.phoneFormatChecker(component, phoneCode, component.get("v.branch.Telephone_no__c"));
                //console.log(`telephoneCheck -> ${telephoneCheck}`);
                if(!telephoneCheck)
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
            
            if(branch.Alt_telephone_no__c)
            {
                //console.log(`Alt_telephone_no__c -> ${branch.Alt_telephone_no__c}`);
                let alttelephoneCheck = helper.phoneFormatChecker(component, altPhoneCode, component.get("v.branch.Alt_telephone_no__c"));
                //console.log(`alttelephoneCheck -> ${alttelephoneCheck}`);
                if(!alttelephoneCheck)
                {
                    if(altPhoneCode == "+44"){
                        component.set("v.altPhonelengthError",true);
                        allValid = false;
                    }else{
                        component.set("v.invalidFormatTelNumError",true);
                        allValid = false;
                    }
                }
            }
            
            if(!branch.Postcode__c || !branch.Address__c || !branch.Town_City__c || !branch.County__c || !branch.Country__c)
            {
                /*console.log(`Postcode__c -> ${branch.Postcode__c}`);
                console.log(`Address__c -> ${branch.Address__c}`);
                console.log(`Town_City__c -> ${branch.Town_City__c}`);
                console.log(`County__c -> ${branch.County__c}`);
                console.log(`Country__c -> ${branch.Country__c}`);*/
                component.set("v.addressError",true);
                allValid = false;
            }
            if(branch.General_correspondence_e_mail__c)
            {
                //console.log(`General_correspondence_e_mail__c -> ${branch.General_correspondence_e_mail__c}`);
                var emailCheck = branch.General_correspondence_e_mail__c;
                var checkFormat = helper.emailFormatChecker(component, emailCheck);
                if(!checkFormat)
                {
                    component.set("v.invalidFormatEmailError",true);
                    allValid = false;
                }
            }
            if(branch.Finance_e_mail__c)
            {
                //console.log(`Finance_e_mail__c -> ${branch.Finance_e_mail__c}`);
                var emailCheck = branch.Finance_e_mail__c;
                var checkFormat = helper.emailFormatChecker(component, emailCheck);
                if(!checkFormat)
                {
                    component.set("v.invalidFormatEmailError",true);
                    allValid = false;
                }
            }
            if(branch.Dispute_resolution_e_mail__c)
            {
                //console.log(`Dispute_resolution_e_mail__c -> ${branch.Dispute_resolution_e_mail__c}`);
                var emailCheck = branch.Dispute_resolution_e_mail__c;
                var checkFormat = helper.emailFormatChecker(component, emailCheck);
                if(!checkFormat)
                {
                    component.set("v.invalidFormatEmailError",true);
                    allValid = false;
                }
            }
            
            //console.log('153');
        	if (allValid) {
                var action = component.get("c.updateBranch");
                action.setParams({
                    branch: branch,
                    telephoneCode: phoneCode,
                    altphoneCode: altPhoneCode
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        component.set("v.branch", result);
                        component.set("v.toogle", true);
                        component.set("v.valueChanged", false);
                        component.set("v.fieldnotEdit", true);
                        /*let successTitle = "SUCCESS !!";
                        let successMsg = "Branch has been successfully Updated";
                        $A.get("e.force:refreshView").fire();
                        helper.successMessage(component, successTitle, successMsg);*/
                        $A.enqueueAction(component.get("c.doInit"));
                        component.set("v.branchUpdatedSuccess",true);
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                if (errors[0].message.includes("INVALID_EMAIL_ADDRESS")) {
                                    let errorTitle = "ERROR !!";
                                    let errorMsg = "Email Id format is invalid";
                                    helper.errorMessage(component, errorTitle, errorMsg);
                                } else {
                                    let errorTitle = "ERROR !!";
                                    let errorMsg = errors[0].message;
                                    helper.errorMessage(component, errorTitle, errorMsg);
                                }
                            }
                        } else {
                            helper.genericErrorMessage(component);
                        }
                    } else {
                        helper.genericErrorMessage(component);
                    }
                });
                $A.enqueueAction(action);
            }
            /*else {
                let errorTitle = "ERROR !!";
                let errorMsg = "Please update mandatory fields";
                helper.errorMessage(component, errorTitle, errorMsg);
            }*/
		}
    	else {
            component.set("v.noChangesDoneError",true);
            /*let errorTitle = "ERROR !!";
            let errorMsg =
            "You haven't updated any field. Please Update some fields or Cancel";
            helper.errorMessage(component, errorTitle, errorMsg);*/
        }
 	},

	closeBranch: function (component, event, helper) {
        /*alert(`Branch closed`);
        alert(
          `Development pending for checking any deposit & case.
          To be implemented once Branch Agent story will be completed`
        );*/
        let currentURL = window.location.href;
        let branchId = currentURL.split("id=")[1];
        var action = component.get("c.inactiveBranch");
        action.setParams({
            branchId: branchId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                /*let successTitle = "SUCCESS !!";
            let successMsg = "Branch has been successfully Closed";
            helper.successMessage(component, successTitle, successMsg);*/
                // Salesforec bug https://trailblazer.salesforce.com/issues_view?id=a1p3A000000KRSHQA4
                component.set("v.openBranchSuccess",false);
                component.set("v.closeBranchSuccess",true);
                $A.enqueueAction(component.get("c.doInit"));
                //window.location.reload();
                //$A.get("e.force:refreshView").fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        let errorTitle = "ERROR !!";
                        let errorMsg = errors[0].message;
                        helper.errorMessage(component, errorTitle, errorMsg);
                    }
                } else {
                    helper.genericErrorMessage(component);
                }
            } else {
                helper.genericErrorMessage(component);
            }
        });
        $A.enqueueAction(action);
    },

  	openBranch: function (component, event, helper) {
        let currentURL = window.location.href;
        let branchId = currentURL.split("id=")[1];
        var action = component.get("c.activeBranch");
        action.setParams({
          branchId: branchId
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            /*let successTitle = "Success !!";
            let successMsg = "Branch has been successfully Re-opened";
            helper.successMessage(component, successTitle, successMsg);*/
            // Salesforec bug https://trailblazer.salesforce.com/issues_view?id=a1p3A000000KRSHQA4
            component.set("v.closeBranchSuccess",false);
            component.set("v.openBranchSuccess",true);
            $A.enqueueAction(component.get("c.doInit"));
            //$A.get("e.force:refreshView").fire();
            //window.location.reload();
          } else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
              if (errors[0] && errors[0].message) {
                let errorTitle = "Error !!";
                let errorMsg = errors[0].message;
                helper.errorMessage(component, errorTitle, errorMsg);
              }
            } else {
              helper.genericErrorMessage(component);
            }
          } else {
            helper.genericErrorMessage(component);
          }
        });
        $A.enqueueAction(action);
	},

  	onChange: function (component, event, helper) {
    	component.set("v.valueChanged", true);
	},

  	cancelEdit: function (component, event, helper) {
        component.set("v.fieldnotEdit", true);
        component.set("v.toogle", true);
        $A.get("e.force:refreshView").fire();
        // Salesforec bug https://trailblazer.salesforce.com/issues_view?id=a1p3A000000KRSHQA4
        window.location.reload();
	},

  	loadUser: function (component, event, helper) {
        let currentURL = window.location.href;
        let branchId = currentURL.split("id=")[1];
        console.log(`loadUser`);
        var actions = [
          { label: "Edit User", name: "edit_user" }
          // { label: 'Suspend User', name: 'suspend_user' }
        ];
    
        component.set("v.columns", [
          { label: "Full Name", fieldName: "fullName", type: "text" },
          { type: "action", typeAttributes: { rowActions: actions } }
        ]);
    
        var action = component.get("c.getUsers");
        action.setParams({
          branchId: branchId
        });
        console.log(`branh ${branchId}`);
        action.setCallback(this, function (response) {
          var state = response.getState();
          console.log(`state=> ${state}`);
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
              console.log('line-->236  ' + JSON.stringify(result));
            component.set("v.userlist", result);
            result.forEach(
              (row) =>
                (row.fullName =
                  row.Salutation + " " + row.FirstName + " " + row.LastName)
            );
            console.log("result :" + JSON.stringify(result));
            if (result == "" || result == [] || result.length == 0) {
              component.set("v.dataTableHasRecord", false);
            } else {
              component.set("v.dataTableHasRecord", true);
              component.set("v.data", result);
            }
          } else if (state === "ERROR") {
            var errors = response.getError();
            console.log(`${errors}`);
            if (errors) {
              if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
              }
            } else {
              console.log("Unknown error");
            }
          }
        });
        $A.enqueueAction(action);
    },

  	addNewUsers: function (component, event, helper) {
        var modalBody;
        $A.createComponent("c:EI_createBranchUser", {}, function (content, status) {
          if (status === "SUCCESS") {
            modalBody = content;
            component.find("overlayLib").showCustomModal({
              header: "User Details",
              body: modalBody,
              showCloseButton: true,
              cssClass: "mymodal",
              closeCallback: function () {}
            });
          }
        });
	},

     /* addNewUser: function (component, event, helper) {
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "createbranchuser"
                },
                state: {}
            });    
            
        }, */

  	addNewUser:function (component, event, helper) {
        //  var branchid = currentURL.split("id=")[1]; 
        var branchid =component.get("v.branchId");
      //  alert(branchid);
        var address = "/createbranchuser";
        var domain = window.location.origin;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
            url: address + "?id=" + branchid
        });
        urlEvent.fire();
    },
    
  	handleRowAction: function (component, event, helper) {
        var action = event.getParam("action");
        var row = event.getParam("row");
        alert(row.Id);
        switch (action.name) {
          case "edit_user":
            var modalBody;
            $A.createComponent(
              "c:EI_editBranchUser",
              {
                userId: row.Id
              },
              function (content, status) {
                if (status === "SUCCESS") {
                  modalBody = content;
                  component.find("overlayLib").showCustomModal({
                    header: "Edit User's Detail",
                    body: modalBody,
                    showCloseButton: true,
                    cssClass: "mymodal",
                    closeCallback: function () {}
                  });
                }
              }
            );
            break;
          case "suspend_user":
            alert("User should be suspended");
        }	
	},
  
    updatebranchuser: function (component, event, helper) {
        
        var userid = event.getSource().get("v.value");
        let currentURL = window.location.href;
        let branchId = currentURL.split("id=")[1];
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "editbranchuser"
            },
            state: {
                branchId:branchId,
                id: userid
            }
        });
        /* var address = "/editbranchuser";
        var domain = window.location.origin;

        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
          url: address + "?id=" + userid
        });
        urlEvent.fire();   */
    },

	parentPress: function (component, event, helper) {
        var objChild = component.find("compB");
        component.set("v.branch.Country__c", "");
        component.set("v.branch.Postcode__c", "");
        component.set("v.branch.Town_City__c", "");
        component.set("v.branch.County__c", "");
        component.set("v.branch.Address__c", "");
        component.set("v.valueChanged", true);
        component.set("v.branch.Country__c", objChild.get("v.Country"));
        component.set("v.branch.Postcode__c", objChild.get("v.PostCode"));
        component.set("v.branch.Town_City__c", objChild.get("v.Town"));
        component.set("v.branch.County__c", objChild.get("v.County"));
        component.set("v.branch.Address__c", objChild.get("v.AddressLine1"));
	},
  
	backtobranches: function (component, event, helper) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "home"
            },
            state: {}
        });  
    },
        
	hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "successOnUpdateBranch":
                component.set("v.branchUpdatedSuccess", false);
                break;
            case "successOnCloseBranch":
                component.set("v.closeBranchSuccess", false);
                break;
            case "successOnOpenBranch":
                component.set("v.openBranchSuccess", false);
                break;
            case "noChangesDone":
                component.set("v.noChangesDoneError", false);
                break;
            case "branchNameMandat":
                component.set("v.branchNameError", false);
                break;
            case "Phonelength":
                component.set("v.PhonelengthError", false);
                break;
            case "altPhonelength":
                component.set("v.altPhonelengthError", false);
                break;
            case "telphoneNumberMandat":
                component.set("v.telphoneNumberError", false);
                break;
            case "addressMandatory":
                component.set("v.addressError", false);
                break;
            case "invalidFormatTelNumb":
                component.set("v.invalidFormatTelNumError", false);
                break;
            case "invalidEmailFormat":
                component.set("v.invalidFormatEmailError", false);
                break; 
        }
    },
    
});