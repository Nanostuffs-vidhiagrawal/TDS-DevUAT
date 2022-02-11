({
    doInit : function(component, event, helper) {
        helper.getActiveDeposits(component, event,helper);
        helper.getLoggedInDetails(component, event);
        helper.getSalutationPicklist(component, event);
        helper.getBankDetails(component, event);
        
        //helper.getActiveDeposits(component, event,helper);
    },
    
    paymentClick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#payment-details").offset().top - 30 },
      1000
    );
     },
    corresPondenceClick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#Correspondence-email").offset().top - 30 },
      1000
    );
     },
    autorizedpersonclick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#prescribed-info").offset().top - 30 },
      1000
    );
     },
    marketingclick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#additional-user").offset().top - 30 },
      1000
    );
     },
        datashareclick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#account-type").offset().top - 30 },
      1000
    );
     },
     closeaccoutclick: function(component, event, helper) {
     $("html, body").animate(
      { scrollTop: $("#account-type").offset().top - 30 },
      1000
    );
     },
    
    
    shownomessage: function(component, event, helper) {
       component.set("v.shownomessage",true);  
    },
    closeAccount : function(component, event, helper) {
        component.set("v.closeAccountPopUp",true);
    },
    
    closeModel: function(component, event, helper){
        component.set("v.closeAccountPopUp", false);
    },
    
    goToMyDetails : function(component, event, helper) {
        component.set("v.closeAccountPopUp", false);
        $A.get('e.force:refreshView').fire();
    },
    
    closeTenantAccount : function(component, event, helper) {
        helper.closeAccount(component, event);
    },
    
    cancelEdit: function (component, event, helper) {
        component.set("v.fieldnotEdit", true);
        component.set("v.toggle", true);
        $A.get('e.force:refreshView').fire();
    },	
    
    enableEdit: function (component, event, helper) {
        var tenantFirstName = component.get("v.tenant.FirstName");
        var tenantLastName = component.get("v.tenant.LastName");
        component.set("v.tenantFirstName", tenantFirstName);
        component.set("v.tenantLastName", tenantLastName);
        component.set("v.fieldnotEdit", false);
        component.set("v.toggle", false);
    }, 
    
    submitDetails: function (component, event, helper) {        
        helper.submitDetails(component, event);
    },
    
    
    editAdd: function(component, event, helper) {
        component.set("v.editAddress",true);
    },
     closeEditAdd: function(component, event, helper) {
        component.set("v.editAddress",false);
    },
    
    enableBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldBankDetailsEdit", false);
        component.set("v.toggleBankDetails", false);
    }, 
    
    cancelBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldBankDetailsEdit", true);
        component.set("v.toggleBankDetails", true);
    },
    
    updateBankDetails: function (component, event, helper) {
        helper.updateBankDetails(component, event);
    },
    
    enableInternationalBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldInternationalBankDetailsEdit", false);
        component.set("v.toggleInternationalBankDetails", false);
    }, 
    
    cancelInternationalBankDetailsEdit: function (component, event, helper) {
        component.set("v.fieldInternationalBankDetailsEdit", true);
        component.set("v.toggleInternationalBankDetails", true);
    },
    
    updateInternationalBankDetails: function (component, event, helper) {
        helper.updateInternationalBankDetails(component, event);
    },
    
    removeInternationalBankDetails: function (component, event, helper) {
        helper.removeInternationalBankDetails(component, event);
    },
    
    passwordChange: function (component, event, helper) {        
        helper.passwordChange(component, event);
    },
    
    cancelPasswordChange: function (component, event, helper) {
        component.set("v.passwordCancelPopUp", true);
    },
    
    closePasswordModel: function (component, event, helper) {
        component.set("v.passwordChangePopUp", false);
    },
    
    closePasswordCancelModel: function (component, event, helper) {
        component.set("v.passwordCancelPopUp", false);
        $A.get('e.force:refreshView').fire();
    },
    
    enableAuthorizedPersonEdit: function (component, event, helper) {
        component.set("v.authorizedPersonEdit", false);
        component.set("v.toggleAuthorizedPersonEdit", false);
    }, 
    
    cancelAuthorizedPersonEdit: function (component, event, helper) {
        component.set("v.authorizedPersonEdit", true);
        component.set("v.toggleAuthorizedPersonEdit", true);
    },
    
    updateAuthorizedPerson: function (component, event, helper) {
        helper.updateAuthorizedPerson(component, event);
    },
    
    enableMarketDetailsEdit: function (component, event, helper) {
        component.set("v.marketFieldNotEdit", false);
        component.set("v.toggleMarketDetails", false);
    }, 
    
    cancelMarketDetailsEdit: function (component, event, helper) {
        component.set("v.marketFieldNotEdit", true);
        component.set("v.toggleMarketDetails", true);
    },
    
    updateMarketDetails: function (component, event, helper) {
        helper.updateMarketDetails(component, event);
    },
    
    MarketingMaterialsFunc: function (component, event, helper) {
        var market = document.getElementById("gridAgreement");
        if(market.checked){
        	component.set("v.tenant.Marketing_Agreement__c", true);
        }
        else{
            component.set("v.tenant.Marketing_Agreement__c", false);
        }
    },
    
    updateViewableDetails: function (component, event, helper) {
        //helper.updateTenantViewableDetails(component, event,'tenantDetailsViewable');
        component.set("v.datesharingtenent",'tenantDetailsViewable');
    },
    
    updateNotViewableDetails: function (component, event, helper) {
        component.set("v.datesharingtenent",'tenantDetailsNotViewable');
        
       // helper.updateTenantViewableDetails(component, event,'tenantDetailsNotViewable');
    },
    
    updateTenantViewableDetails: function (component, event, helper) {
      helper.updateTenantViewableDetail(component, event,helper);  
    },
    
    hideBootstrapErrors: function(component, event) {
    var button_Name = event.target.name;
    switch (button_Name) {
            
         case "authorisedPerson":
       	 	component.set("v.authorisedPerson", false);
       break;
       case "passSuccessMessage":
       	 	component.set("v.passwordSuccessMsg", false);
       break;
       case "passErrorMessage":
        	component.set("v.passwordErrorMsg", false);
       break;
       case "SuccessMessage":
        component.set("v.successMsg", false);
        break;
        case "successMessagedatasharing":
            component.set("v.datasharesuccess", false);
            break;
            case "successmarketingpref":
            component.set("v.marketingprefsuccess", false);
            break;
            
       case "ErrorMessage":
        component.set("v.errorMsg", false);
        break;
      case "title":
        component.set("v.titleError", false);
        break;
      case "firstName":
        component.set("v.firstNameError", false);
        break;
      case "surName":
        component.set("v.SurNameError", false);
        break;
        case "firstnamechange":
        component.set("v.firstnamechangeerror", false);
        break;
      case "lastnamechange":
        component.set("v.lastnamechangeerror", false);
        break;
        case "firstnamemorechange":
        component.set("v.firstnamemorechangeerror", false);
        break;
      case "lastnamemorechange":
        component.set("v.lastnamemorechangeerror", false);
        break;
      case "emailOfUser":
        component.set("v.EmailError", false);
        break;
      case "mobileNumber":
        component.set("v.mobileError", false);
        break;
             case "phoneformat":
        component.set("v.phoneformaterror", false);
        break;
            
      case "landlineNumber":
        component.set("v.landlineError", false);
        break;
      case "marketingPreference":
        component.set("v.marketingError", false);
        break;
      case "newsLetter":
        component.set("v.newsLetterError", false);
        break;
      case "generalEmail":
        component.set("v.grnlEmailError", false);
        break;
      case "disputeEmail":
        component.set("v.disputeEmailError", false);
        break;
      case "financeEmail":
        component.set("v.financeEmailError", false);
        break;
      case "extraEmailSuccessMessage":
        component.set("v.extraEmailSuccessMessage", false);
        break;
      case "extraEmailErrorMessage":
        component.set("v.extraEmailErrorMessage", false);
        break;
      case "accountNameError":
        component.set("v.accountNameError", false);
        break;
      case "companyNameError":
        component.set("v.companyNameError", false);
        break;
      case "tradingNameError":
        component.set("v.tradingNameError", false);
        break;
      case "companyRegistationNumberError":
        component.set("v.companyRegistationNumberError", false);
        break;
      case "telephoneNumberError":
        component.set("v.telephoneNumberError", false);
        break;
      case "addressError":
        component.set("v.addressError", false);
        break;
      case "prescribedError":
        component.set("v.prescribedError", false);
        break;
      case "grnlEmailPatternError":
        component.set("v.grnlEmailPatternError", false);
        break;
      case "disputeEmailPatternError":
        component.set("v.disputeEmailPatternError", false);
        break;
      case "financeEmailPatternError":
        component.set("v.financeEmailPatternError", false);
        break;
      case "prescribedError":
        component.set("v.prescribedError", false);
        break;
      case "prescribedLengthError":
        component.set("v.prescribedLengthError", false);
        break;
      case "prescribedSuccessMessage":
        component.set("v.prescribedSuccessMessage", false);
        break;
      case "prescribedErrorMessage":
        component.set("v.prescribedErrorMessage", false);
        break;

      case "nameOnAccountBlankError":
        component.set("v.nameOnAccountBlankError", false);
        break;
      case "accountNumberBlankError":
        component.set("v.accountNumberBlankError", false);
        break;
      case "sortCodeBlankError":
        component.set("v.sortCodeBlankError", false);
        break;
      case "invalidSortCodeError":
        component.set("v.invalidSortCodeError", false);
        break;
            case "bankOfAmericaSortCode":
        component.set("v.bankOfAmericaSortCode", false);
        break;
        case "nameOnAccountSpecialCharError":
        component.set("v.nameOnAccountSpecialCharError", false);
        break;
            case "nameOnIntAccountSpecialCharError":
        component.set("v.nameOnIntAccountSpecialCharError", false);
        break;
      case "invalidAccountNumberError":
        component.set("v.invalidAccountNumberError", false);
        break;
      case "bankSuccessMessage":
        component.set("v.bankSuccessMessage", false);
        break;
        case "intbankSuccess":
        component.set("v.intbankSuccessMessage", false);
        break;
        case "intbankname":
        component.set("v.intbanknameerror", false);
        break;
        case "intbankaccount":
        component.set("v.intbankaccounterror", false);
        break;
            
        
      case "bankErrorMessage":
        component.set("v.bankErrorMessage", false);
        break;
      case "usernameError":
        component.set("v.usernameErrorMessage", false);
        break;
    }
  },
    
   submitDetails2: function(component, event) {
        var isValid = true;
         var title = document.getElementById("tenantTitle").value;
        var toastEvent = $A.get("e.force:showToast");
        var firstName = component.find("tenantFirstName").get("v.value");
        var lastName = component.find("tenantLastName").get("v.value");
      //  var email = component.find("txtEmail").get("v.value");
        var phone = component.find("tenantphone").get("v.value");
       var street = component.get("v.Street");
       var city = component.get("v.Town");
       var state = component.get("v.County");
       var postCode = component.get("v.PostCode");
       var country = component.get("v.Country");
        var regExpPhoneformat = /^[07]{2}[0-9]{9}$/;
		var tenantFirstName = component.get("v.tenantFirstName");
		var tenantLastName = component.get("v.tenantLastName");
         var addresscheck = component.get("v.textareaval");
       
        if(title==undefined || title==null || title=='' || title=='-- Select Title --'){
          /*  toastEvent.setParams({
                "type" : "error",
                "message": "Please provide Title"                    
            });
            
            toastEvent.fire();*/
            component.set("v.titleError", true);
            isValid = false;
        }
       else{
           
      component.set("v.titleError", false);     
       }
            
        console.log('++ contains ++ firstName '+firstName);
       if(firstName==undefined || firstName==null || firstName==''){
            /*toastEvent.setParams({
                "type" : "error",
                "message": "Please provide First Name"                    
            });
            toastEvent.fire();
            isValid = false;*/
            component.set("v.firstNameError", true);
            
        }
            else{
             component.set("v.firstNameError", false);   
                
            }
       var oneTime = component.get("v.tenant.OneTimeUpdate__c");
       if(typeof oneTime == 'undefined'){
           oneTime = 'NoUpdate';
           console.log('++ inIF ');
       }
        console.log('++ oneTime ++ firstName '+oneTime); 
		if(firstName.trim().length!=tenantFirstName.trim().length){
            
           /* toastEvent.setParams({
                "type" : "error",
                "message": "If you need to change more than 2 characters of your First name, you need to contact the scheme."                    
            });
            
            toastEvent.fire();*/
            console.log('++ contains ++'+oneTime);
            if(oneTime.includes('FirstName') ){
           isValid = false;
                component.set("v.firstnamemorechangeerror", true);
            }else{
            component.set("v.firstnamechangeerror", true);
            isValid = false;
            }
        }	
       else{
         component.set("v.firstnamechangeerror", false);  
       }
      
	  if(firstName.trim().length==tenantFirstName.trim().length && firstName.trim()!=tenantFirstName.trim()){
          
          if(oneTime.includes('FirstName') ){
           isValid = false;
                component.set("v.firstnamemorechangeerror", true);
          }else{
			var counter = 0;
			for(var i=0;i<firstName.length;i++){
				var obj = tenantFirstName[i];
				console.log('++++firstName[i]++'+firstName[i]);
				console.log('+++++obj+'+obj);
				if(obj != firstName[i]){
					counter++;
				}
			}console.log('+++++counter+'+counter);
			if(counter>2){
				/*toastEvent.setParams({
					"type" : "error",
					"message": "If you need to change any more of your First name, you need to contact the scheme."                    
				});
                toastEvent.fire();*/
				isValid = false;
                component.set("v.firstnamemorechangeerror", true);
			}
          else{
            component.set("v.firstnamemorechangeerror", false);  
          }
          }
        }
        else{
            component.set("v.firstnamemorechangeerror", false);  
          }
        console.log('+lastName '+lastName);
		 if(lastName==undefined || lastName==null || lastName==''){
		/*	toastEvent.setParams({
				"type" : "error",
				"message": "Please provide Last Name"                    
			});
            toastEvent.fire();*/
             component.set("v.SurNameError", true);
			isValid = false;
		}
       else{
       component.set("v.SurNameError", false);    
       }
       
		if(lastName.trim().length!=tenantLastName.trim().length){
			/*toastEvent.setParams({
				"type" : "error",
				"message": "If you need to change more than 2 characters of your Last name, you need to contact the scheme."  
			});
             toastEvent.fire();*/
            if(oneTime.includes('LastName') ){
           isValid = false;
                component.set("v.lastnamemorechangeerror", true);
               
          }else{
			isValid = false;
              component.set("v.lastnamechangeerror", true);}
		}
       else{
         component.set("v.lastnamechangeerror", false);  
       }
		 if(lastName.trim().length==tenantLastName.trim().length && lastName.trim()!=tenantLastName.trim()){
			 if(oneTime.includes('LastName') ){
           		isValid = false;
                component.set("v.lastnamemorechangeerror", true);
             }else{
                 var counter = 0;
                for(var i=0;i<lastName.length;i++){
                    var obj = tenantLastName[i];
                    if(obj != lastName[i]){
                        counter++;
                    }
                }
                if(counter>2){
                    /*toastEvent.setParams({
                        "type" : "error",
                        "message": "If you need to change any more of your Last name, you need to contact the scheme."                    
                    });
                    toastEvent.fire();*/
                    isValid = false;
                    component.set("v.lastnamemorechangeerror", true);
                }
                 else{
                   component.set("v.lastnamemorechangeerror", false);  
                 }
             }
        }
         else{
               component.set("v.lastnamemorechangeerror", false);  
             }
		
		 if(phone==undefined || phone==null || phone==''){
			/*toastEvent.setParams({
				"type" : "error",
				"message": "Please provide Phone"                    
			});
			
			toastEvent.fire();*/
            isValid = false;
            component.set("v.mobileError", true);
		}
            else{
            component.set("v.mobileError", false);    
            }
		if(!phone.match(regExpPhoneformat)){
			/*toastEvent.setParams({
					"message": "Enter valid phone number starts with '07' and it must be of 11 digits"                    
				});
                toastEvent.fire();*/
            component.set("v.phoneformaterror", true);
			isValid = false;
		}
        else{
            component.set("v.phoneformaterror", false);    
            }
       if(!addresscheck){
       if(street ==undefined ||city==undefined||state==undefined||postCode==undefined||country==undefined)
       {
           component.set("v.addressError",true);  
           isValid = false;
       }
       else{
           component.set("v.addressError",false);
       } 
       }   
       

	/*	else if(street==undefined || street==null || street==''){
			toastEvent.setParams({
				"type" : "error",
				"message": "Please provide Street"                    
			});
			isValid = false;
			toastEvent.fire();
		}
		else if(city==undefined || city==null || city==''){
			toastEvent.setParams({
				"type" : "error",
				"message": "Please provide City"                    
			});
			isValid = false;
			toastEvent.fire();
		}
		else if(state==undefined || state==null || state==''){
			toastEvent.setParams({
				"type" : "error",
				"message": "Please provide State"                    
			});
			isValid = false;
			toastEvent.fire();
		}
		else if(postCode==undefined || postCode==null || postCode==''){
			toastEvent.setParams({
				"type" : "error",
				"message": "Please provide Postcode"                    
			});
			isValid = false;
			toastEvent.fire();
		}
		else if(country==undefined || country==null || country==''){
			toastEvent.setParams({
				"type" : "error",
				"message": "Please provide Country"                    
			});
			isValid = false;
			toastEvent.fire();
		}*/
        if(isValid){
            console.log('tenantFirstName '+tenantFirstName);
            var con = component.get("v.tenant");
            var action = component.get("c.updateContactTenantDetails");
            action.setParams({
                con: con,
                tenantFirstName:tenantFirstName,
                tenantLastName:tenantLastName,
                title:title,
                street:street,
                town:city,
                county:state,
                country:country,
                postcode:postCode
            });
            action.setCallback(this, function(response) {
                var resMessage = response.getReturnValue();
                var state = response.getState();
                console.log('resMessage>> '+resMessage);
                if (state === "SUCCESS"){
                   /* component.set("v.fieldnotEdit", true);
                    component.set("v.toggle", true);
                    toastEvent.setParams({
                        title: "Success",
                        type: "success",
                        message: "Details has been updated.",
                        duration: " 5000",
                        key: "info_alt",
                        mode: "dismissible"
                    });
                    toastEvent.fire();*/
                     component.set("v.successMsg", true);
                    var appEvent = $A.get("e.c:EI_Tenantpercentagebarupdate"); 
                    appEvent.fire(); 
                     setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 1200);
                  
                  //  window.location.reload();
                }else{
                  component.set("v.successMsg", false);  
                }
            });
            $A.enqueueAction(action);
        }
       else{
           console.log('else '+tenantLastName);
          var lname=  component.find("tenantLastName");
           lname.set("v.value",tenantLastName);
            var fname=  component.find("tenantFirstName");
           fname.set("v.value",tenantFirstName);
       }
    },
    
    updatePassword: function(component, event) {
    var isValid = true;
    var CurrentPassword = document.getElementById("sf-currentPassword").value;
    var newPassword = document.getElementById("sf-NewPassword").value;
    var verifyPassword = document.getElementById("sf-VerifyPassword").value;
    var action = component.get("c.changeuserpassword");
    action.setParams({
      newPassword: newPassword,
      verifyNewPassword: verifyPassword,
      oldPassword: CurrentPassword
    });
    action.setCallback(this, function(response) {
      var state = response.getReturnValue();
      //  alert(state);
      if (state === "Success") {
        component.set("v.fieldnotEdit", true);
        var result = response.getReturnValue();
        console.log("result :" + JSON.stringify(result));
	component.set("v.passwordSuccessMsg", true);
        document.getElementById("sf-currentPassword").value = "";
        document.getElementById("sf-NewPassword").value = "";
        document.getElementById("sf-VerifyPassword").value = "";
        console.log("Modal Close");
        //   $('#modalwindow').modal('hide');
        $A.get("e.force:refreshView").fire();
      } else {
        document.getElementById("sf-currentPassword").value = "";
        document.getElementById("sf-NewPassword").value = "";
        document.getElementById("sf-VerifyPassword").value = "";
        component.set("v.ErrorMessage", state);
     
	component.set("v.passwordErrorMsg", true);
        $A.get("e.force:refreshView").fire();
      }
    });
    $A.enqueueAction(action);
  },
    
    closePopup: function(component, event, helper) {
		 component.set("v.passwordSuccessMsg", false);
          component.set("v.passwordErrorMsg", false);
    },
    
    changepassword: function(component, event, helper) {
        var action = component.get("c.changeuserpassword");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(`state=> ${state}`);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("result :" + JSON.stringify(result));
                component.set("v.passwordSuccessMsg", true);
              /*  var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success",
                    type: "success",
                    message: "Password Change email sent successfully.",
                    duration: " 5000",
                    key: "info_alt",
                    mode: "dismissible"
                });
                toastEvent.fire();*/
                //     component.set("v.toggle", true);
                //     helper.initHelper(component, event);
                //     $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log('line 678' + JSON.strigify(errors));
                console.log('line 679' + `${errors}`);
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
    
     
    parentPress: function (component, event, helper) {
    helper.PassVariable(component, event, helper);
  },
    logOut: function (component, event, helper){
        let currentURL = window.location.origin;
        let redirectURL = currentURL + "/Sds/secur/logout.jsp?retUrl=https://staging-thedisputeservice.cs122.force.com/Sds/CommunitiesLanding";
        window.location.replace(redirectURL);
    },
    NumSplCharsCheck: function(component, event, helper){
        var keyCode = (event.which) ? event.which : event.keyCode;
        if(keyCode!= 32 && ((keyCode < 65 || keyCode > 90) && (keyCode < 97 || keyCode > 123))
          	&& (keyCode != 46 && keyCode > 31 && (keyCode < 48 || keyCode > 57))) {
            
            if (event.preventDefault) {
                event.preventDefault();
                
            } else {
                event.returnValue = false;
                
            } 
            
        }
       
    },
})