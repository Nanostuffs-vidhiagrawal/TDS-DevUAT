({
    getdata : function(component, event, helper) {
        component.set("v.titleError", false);
        component.set("v.firstNameError", false);
        component.set("v.surNameError", false);
        component.set("v.emailError", false);
        component.set("v.phonelengthError", false);
        component.set("v.telephoneNumError", false);
        component.set("v.otherPhonelengthError", false);
        component.set("v.altertelephoneNumError", false);
        component.set("v.alteremailError", false);
        component.set("v.isAddressValidError", false);
        component.set("v.isDuplicateEmail", false);
        component.set("v.duplicateEmailError", false);
        component.set("v.duplicateNameError", false);
        component.set("v.succeessmessage", false);
        var landlordid = event.target.id;
        //var landlordid = component.get("v.strRecordId");
        var action = component.get("c.getlandlorddetails");
        action.setParams({
            landlordid: landlordid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log(result);
                component.set("v.Landlorddetails", result);
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
        
        // Get Country codes Picklist Values
        helper.fetchPhoneCodePicklist(component); 
        
        // helper.getlandlordstatus(component, event);
        helper.takesalutation(component, event);
    },
    
    enableEdit: function (component, event, helper) {
        component.set("v.fieldnotEdit", false);
        component.set("v.toggle", false);
    },  
    
    cancelEdit: function (component, event, helper) {
        component.set("v.fieldnotEdit", true);
        component.set("v.toggle", true);
        // $A.get('e.force:refreshView').fire();
    },
    parentPress3: function (component, event, helper) {
        var objChild = component.find("compC");
        component.set("v.Landlorddetails.MailingCountry", objChild.get("v.Country"));
        component.set("v.Landlorddetails.MailingPostalCode", objChild.get("v.PostCode"));
        component.set("v.Landlorddetails.MailingCity", objChild.get("v.Town"));
        component.set("v.Landlorddetails.MailingState", objChild.get("v.County"));
        var StreetAddress =
            objChild.get("v.AddressLine1") + " \n " + objChild.get("v.Street");
        component.set("v.Landlorddetails.MailingStreet", StreetAddress);
        //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
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
             case "phonelength":
                component.set("v.phonelengthError", false);
                break;
            case "telephoneNumber":
                component.set("v.telephoneNumError", false);
                break;
            case "otherPhonelength":
                component.set("v.otherPhonelengthError", false);
                break;
            case "altermobilenumber":
                component.set("v.altertelephoneNumError", false);
                break;
            case "alternateemail":
                component.set("v.alteremailError", false);
                break;
            case "validAddress":
                component.set("v.isAddressValidError", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;
            case "duplicateEmail":
                component.set("v.duplicateEmailError", false);
                break;
                /*case "updatesuccessmsg":
                component.set("v.updatesucceessmessage", false);
                break;
           case "success":
                component.set("v.succeessmessage1", false);
                break;*/
        }
    },
    
    handleEmailBlur: function (component, event, helper) {
        component.set("v.isDuplicateEmail", false);
        component.set("v.duplicateEmailError", false);
        component.set("v.duplicateNameError", false);
        
        var landlorddata = component.get("v.Landlorddetails");
        helper.checkDuplicacy(component, landlorddata);
    },
    
    updatelandlorddetailsreere: function (component, event, helper) {
        //alert('aaya?');
        component.set("v.fieldnotEdit", false);
        var landlordid = component.get("v.Landlorddetails");
        
        
        var action = component.get("c.updatelandlord");
        var allValid = component.find("mandate")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);   
        if (allValid){
            alert('aaya?' + JSON.stringify(component.get("v.Landlorddetails")));
            action.setParams({
                landlordaccount: component.get("v.Landlorddetails")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(`state=> ${state}`);
                if (state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    console.log("result :" + JSON.stringify(result));
                    component.set("v.fieldnotEdit", true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Info",
                        type: "success",
                        message: "Details has been updated.",
                        duration: " 5000",
                        key: "info_alt",
                        type: "info",
                        mode: "dismissible"
                    });
                    toastEvent.fire();
                    window.location.reload();
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log("result :" + JSON.stringify(errors));
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
        }  
    },
    
    updatelandlorddetails: function (component, event, helper) {
        // component.set("v.fieldnotEdit", false);
        component.set("v.succeessmessage",false); 
        var landlorddata = component.get("v.Landlorddetails");
        // helper.checkDuplicacy(component, landlorddata);
        var isDuplicateEmail = component.get("v.isDuplicateEmail");
        
        var isValid = true;
        var action = component.get("c.updatelandlord");
        var titlecheck = document.getElementById("selectedtitle1").value;
        var firstnamecheck = component.find("firstname").get("v.value");
        var surnamecheck = component.find("surname").get("v.value");
        var emailcheck = component.find("personemail").get("v.value");
        var phoneCode =  document.getElementById("selectLnadlordPhoneCode").value;
        var telephonecheck = component.find("telephone").get("v.value");
        var otherPhoneCode =  document.getElementById("selectLnadlordOtherPhoneCode").value;
        var altertelephonecheck = component.find("altertelephone").get("v.value");
        var alteremailcheck = component.find("alteremail").get("v.value");
        var streetCheck = component.find("street").get("v.value");
        var townCheck = component.find("town").get("v.value");
        var countyCheck = component.find("county").get("v.value");
        var countryCheck = component.find("country").get("v.value");
        var postcodeCheck = component.find("postcode").get("v.value");
        if (titlecheck == undefined || titlecheck == "" || titlecheck == null || titlecheck == "-- Select Title --") {  
            component.set("v.titleError",true);    
            isValid = false;
        } 
        else{
            component.set("v.titleError",false); 
        }
        if (firstnamecheck == undefined || titlecheck == "" || titlecheck == null ) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        } 
        else{
            component.set("v.firstNameError",false); 
        }
        if (surnamecheck == undefined || surnamecheck == "" || surnamecheck == null ) {  
            component.set("v.surNameError",true);    
            isValid = false;
        } 
        else{
            component.set("v.surNameError",false); 
        }
        if (emailcheck == undefined || emailcheck == "" || emailcheck == null ) {  
            component.set("v.emailError",true);    
            isValid = false;
        } 
        else{
            component.set("v.emailError",false); 
            if(isDuplicateEmail){
                alert("isDuplicateEmail => " + isDuplicateEmail);
                isValid = false;
            }
        }
        if (telephonecheck == undefined || telephonecheck == "" || telephonecheck == null ) {  
            component.set("v.telephoneNumError",true);   
            component.set("v.phonelengthError",false);
            isValid = false;
        }else if(phoneCode == "+44"){
            if (telephonecheck.length != 11 || !telephonecheck.startsWith("07")) {
                component.set("v.telephoneNumError",false);
                component.set("v.phonelengthError",true);    
                isValid = false;
            }
            else{
                component.set("v.telephoneNumError",false); 
                component.set("v.phonelengthError",false); 
            }
        }else{
            component.set("v.phonelengthError",false); 
            component.set("v.telephoneNumError",false); 
        }
        
        if (altertelephonecheck == undefined || altertelephonecheck == "" || altertelephonecheck == null ) {  
            component.set("v.altertelephoneNumError",true);   
            component.set("v.OtherPhonelengthError",false);
            isValid = false;
        }else if(otherPhoneCode == "+44"){
            //alert("otherPhoneCode => " +  otherPhoneCode+ (altertelephonecheck.length != 11 || !altertelephonecheck.startsWith("07") ));
            if (altertelephonecheck.length != 11 || !altertelephonecheck.startsWith("07")) {
               // alert("altertelephonecheck => " + otherPhoneCode + " " + altertelephonecheck );
                component.set("v.OtherPhonelengthError",true);   
                component.set("v.altertelephoneNumError",false); 
                isValid = false;
            }
            else{
                component.set("v.altertelephoneNumError",false);
                component.set("v.OtherPhonelengthError",false);  
            }
        }else{
            component.set("v.altertelephoneNumError",false); 
            component.set("v.OtherPhonelengthError",false);   
        }
        if (alteremailcheck == undefined || alteremailcheck == "" || alteremailcheck == null ) {  
            component.set("v.alteremailError",true);    
            isValid = false;
        } 
        else{
            component.set("v.alteremailError",false); 
        }
        if (streetCheck == undefined || townCheck == undefined || countyCheck == undefined ||countryCheck == undefined || postcodeCheck ==undefined) {  
            component.set("v.isAddressValidError",true);    
            isValid = false;
        } 
        else{
            component.set("v.isAddressValidError",false); 
        }
        if(isValid){
            action.setParams({
                landlordtitle:titlecheck,
                landlordaccount: component.get("v.Landlorddetails"),
                landlordPhoneCode: phoneCode,
                landlordOtherPhoneCode: otherPhoneCode
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(`state=> ${state}`);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("result :" + JSON.stringify(result));
                    if(result){
                        component.set("v.succeessmessage",true); 
                    }
                    else{
                        component.set("v.succeessmessage",false);     
                    }
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log("result :" + JSON.stringify(errors));
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
        }
    },
    
    cancelRefresh:function(component, event, helper) {
        document.getElementById("myform1").reset();
        $A.get('e.force:refreshView').fire();
    },
    
    deleteLandlord : function(component, event, helper) {
        var landlordid = event.getSource().get("v.value"); 
        //    alert(landlordid);
        var depositid = component.get("v.depsumlist[0].objdeposit.Id");
        //   alert(depositid);
        // alert(landlordid);   
        var action = component.get("c.deletelandlord");
        action.setParams({ 
            landlordid :landlordid,
            depositdelid  :depositid                    
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // alert('line 124');
                console.log('check value' + JSON.stringify(response.getReturnValue()));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Landlord has been deleted successfully."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                // alert('line 134');
                
            }
                else if (state === "ERROR") {
                    //   alert('line 138');
                    var errors = response.getError();
                    if (errors) {
                        //  alert('line 141');
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                }
        });
        
        $A.enqueueAction(action);    
    },
    
    handleLinkToViewLandlord : function(component, event, helper){
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {
                    id: event.target.id,
                    branchId : branchId
                }
            }); 
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {
                    id: event.target.id,
                }
            }); 
        }
    }
    
})