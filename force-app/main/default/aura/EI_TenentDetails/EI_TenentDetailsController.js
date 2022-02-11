({
    getdata : function(component, event, helper) {
        component.set("v.titleError", false);
        component.set("v.firstNameError", false);
        component.set("v.surNameError", false);
        component.set("v.emailError", false);
        component.set("v.personPhonelengthError",false); 
        component.set("v.telephoneNumError", false);
        component.set("v.personOtherPhonelengthError",false); 
        component.set("v.altertelephoneNumError", false);
        component.set("v.alteremailError", false);
        component.set("v.duplicateEmailError", false);
        component.set("v.isAddressValidError", false);
        component.set("v.succeessmessage", false);
        var contid = event.target.id;
     //   var tenantid = component.get("v.strRecordId");
        
        var action = component.get("c.getTenentDetails");
        action.setParams({
            tenantid: contid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.tenentdetails", result);
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
        // Get Salutation Picklist Values
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
    parentPress: function (component, event, helper) {
        var objChild = component.find("compB");
        component.set("v.tenentdetails.PersonMailingCountry", objChild.get("v.Country"));
        component.set("v.tenentdetails.PersonMailingPostalCode", objChild.get("v.PostCode"));
        component.set("v.tenentdetails.PersonMailingCity", objChild.get("v.Town"));
        component.set("v.tenentdetails.PersonMailingState", objChild.get("v.County"));
        var StreetAddress =
            objChild.get("v.AddressLine1") + " \n " + objChild.get("v.Street");
        component.set("v.tenentdetails.PersonMailingStreet", StreetAddress);
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
            case "phonelength" :
                component.set("v.personPhonelengthError",false);  
                break;
            case "telephoneNumber":
                component.set("v.telephoneNumError", false);
                break;
            case "otherPhonelength":
                component.set("v.personOtherPhonelengthError",false);  
                break;
            case "altermobilenumber":
                component.set("v.altertelephoneNumError", false);
                break;
            case "alternateemail":
                component.set("v.alteremailError", false);
                break;
            case "duplicateEmailError":
                component.set("v.duplicateEmailError", false);
                break;
            case "validAddress":
                component.set("v.isAddressValidError", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
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
        let email = component.get("v.email");	
         helper.checkEmailDuplicacy(component, email);	
    },
    
    updatetenantdetails: function (component, event, helper) {
       // component.set("v.fieldnotEdit", false);
        var tenantdata = component.get("v.tenentdetails");
        console.log("tenantdata : " + tenantdata);
        /*var accId = component.get("v.tenentdetails.Id");
        helper.checkEmailDuplicacy(component, accId);
        */
        var isDuplicateEmail =  component.get("v.duplicateEmailError");
        var isValid = true;
        var action = component.get("c.updatetenentdetails");
        var titlecheck = document.getElementById("selectedtitle").value;
        var firstnamecheck = component.find("firstname").get("v.value");
        var surnamecheck = component.find("surname").get("v.value");
        var emailcheck = component.find("personemail").get("v.value");
        var phoneCode =  document.getElementById("selectPersonPhoneCode").value;
        var telephonecheck = component.find("telephone").get("v.value");
        var otherPhoneCode =  document.getElementById("selectPersonOtherPhoneCode").value;
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
        if ((emailcheck == undefined && telephonecheck == undefined) || (emailcheck == "" && telephonecheck == "" ) || (emailcheck == null && telephonecheck == null) ) {  
            component.set("v.emailError",true);    
            isValid = false;
        } 
        else{
            if(isDuplicateEmail){	
                isValid = false;	
            }
            component.set("v.emailError",false); 
        }
        if (telephonecheck != undefined || telephonecheck != "" || telephonecheck != null ) {  
            if(phoneCode == "+44"){
            if (telephonecheck.length != 11 || !telephonecheck.startsWith("07")) {
                component.set("v.personPhonelengthError",true);    
                isValid = false;
            }
            else{
                component.set("v.telephoneNumError",false); 
                component.set("v.personPhonelengthError",false);   
            }
        }else{
            component.set("v.telephoneNumError",false); 
            component.set("v.personPhonelengthError",false); 
        }
        }
     /*   else{
             component.set("v.telephoneNumError",true);    
             isValid = false;
            
        }*/
        
   /*     if (altertelephonecheck == undefined || altertelephonecheck == "" || altertelephonecheck == null ) {  
            component.set("v.altertelephoneNumError",true);    
            isValid = false;
        } 
        else if(otherPhoneCode == "+44"){
            if (altertelephonecheck.length != 11 || !altertelephonecheck.startsWith("07")) {
                component.set("v.personOtherPhonelengthError",true);    
                isValid = false;
            }
            else{
                component.set("v.altertelephoneNumError",false); 
                component.set("v.personOtherPhonelengthError",false);   
            }
        }else{
            component.set("v.altertelephoneNumError",false); 
            component.set("v.personOtherPhonelengthError",false);   
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
        }*/
        if(isValid){
        action.setParams({
                tenantaccount: tenantdata,
                //tenanttitle:titlecheck,
             	tenantPhoneCode:phoneCode,
                tenantOtherPhoneCode:otherPhoneCode
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
        $A.get('e.force:refreshView').fire();
    }
    
    
   
})