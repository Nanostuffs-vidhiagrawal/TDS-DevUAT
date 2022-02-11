({
    getLoggedInDetails: function(component, event){
        console.log("Error message: " );
        var action = component.get("c.displayLoggedInTenantInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            var userCon = response.getReturnValue();
            console.log("state: " + state);
            console.log("userCon: " + JSON.stringify(userCon));
            if (state === "SUCCESS") {
                component.set("v.tenant", userCon);
                component.set("v.tenantFirstName" ,userCon.FirstName);
                component.set("v.tenantLastName" ,userCon.LastName);
                
                var valz='';
                if(component.get("v.tenant.MailingStreet")!=null && component.get("v.tenant.MailingStreet")!=undefined 
                   && component.get("v.tenant.MailingStreet")!='') {
                	valz = valz+component.get("v.tenant.MailingStreet")+"\n";
                } else {
                    valz = valz+"\n";
                }
                if(component.get("v.tenant.MailingCity")!=null && component.get("v.tenant.MailingCity")!=undefined 
                   && component.get("v.tenant.MailingCity")!='') {
                	valz = valz+component.get("v.MailingCity")+"\n";
                } else {
                    valz = valz+"\n";
                }
                if(component.get("v.tenant.MailingState")!=null && component.get("v.tenant.MailingState")!=undefined 
                   && component.get("v.tenant.MailingState")!='') {
                	valz = valz+component.get("v.tenant.MailingState")+"\n";
                } else {
                    valz = valz+"\n";
                }
                if(component.get("v.tenant.MailingPostalCode")!=null && component.get("v.tenant.MailingPostalCode")!=undefined 
                   && component.get("v.tenant.MailingPostalCode")!='') {
                	valz = valz+component.get("v.tenant.MailingPostalCode")+"\n";
                } else {
                    valz = valz+"\n";
                }
                if(component.get("v.tenant.MailingCountry")!=null && component.get("v.tenant.MailingCountry")!=undefined 
                   && component.get("v.tenant.MailingCountry")!='') {
                	valz = valz+component.get("v.tenant.MailingCountry");
                } else {
                    valz = valz+"\n";
                }
                /*var valz = component.get("v.tenant.MailingStreet")+"\n"+component.get("v.tenant.MailingCity")+"\n"
                +component.get("v.tenant.MailingState")+"\n"+component.get("v.tenant.MailingPostalCode")+"\n"
                +component.get("v.tenant.MailingCountry"); */
                
                component.set("v.textareaval",valz);
                
                if(userCon.Tenant_Details_Not_Viewable__c==true){
                    component.set("v.datesharingtenent",'tenantDetailsNotViewable');
                }
                else if(userCon.Tenant_Details_Viewable__c==true){
                    component.set("v.datesharingtenent",'tenantDetailsViewable');    
                }
            } else if (state === "ERROR") {
                console.log("Error message: " + userCon);
            } else {
                console.log("Unknown error");
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getSalutationPicklist: function(component, event) {
    var action = component.get("c.tenentSalutation");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
          
        var result = response.getReturnValue();
          console.log('line-->29 ' + result );
        var salutationMap = [];
        for (var key in result) {
          salutationMap.push({ key: key, value: result[key] });
        }
        component.set("v.salutationMap", salutationMap);
      }
        else if (state === "ERROR") {
            console.log("line-->@@ error")
                
            } else {
                console.log("line-->39 Unknown error");
            }
    });
    $A.enqueueAction(action);
  },
    
    getBankDetails: function(component, event){
        var action = component.get("c.displayBankDetails");
        action.setCallback(this, function (response) {
            var state = response.getState();
            var tenantBankDetails = response.getReturnValue();
            console.log("state: " + state);
            if (state === "SUCCESS") {
                if(tenantBankDetails!=null){
                    component.set("v.bankName", tenantBankDetails[0].Bank_Name__c);
                    component.set("v.bankAccountName", tenantBankDetails[0].Bank_Account_Holder_Name__c);
                    component.set("v.sortCode", tenantBankDetails[0].Sort_Code__c);
                    component.set("v.accountNumber", tenantBankDetails[0].Account_Number__c);
                    component.set("v.bankIntName", tenantBankDetails[0].International_Bank_Name__c);
                    component.set("v.bankIntAddress", tenantBankDetails[0].Bank_Address__c);
                    component.set("v.bankIdentificationCode", tenantBankDetails[0].BIC__c);
                    component.set("v.bankSwiftCode", tenantBankDetails[0].Swift_Code__c);
                    component.set("v.IBAN", tenantBankDetails[0].IBAN__c);
                    component.set("v.nameOnAccount", tenantBankDetails[0].International_Bank_Account_Holder_Name__c);
                }
            } else if (state === "ERROR") {
                
            } else {
                console.log("Unknown error");
            }
        });
        
        $A.enqueueAction(action);
    },
    
    PassVariable: function (component, event, helper) {
      var objChild = component.find("compB");
        component.set("v.Country", objChild.get("v.Country"));
        component.set("v.PostCode", objChild.get("v.PostCode"));
        component.set("v.Town", objChild.get("v.Town"));
        component.set("v.County", objChild.get("v.County"));
        var StreetAddress;
        if (objChild.get("v.AddressLine1") != "undefined ") {
            StreetAddress =
                objChild.get("v.AddressLine1") + "\n " + objChild.get("v.Street");
        } else {
            StreetAddress = objChild.get("v.Street");
        }
        component.set("v.Street", StreetAddress);
  },
    
    getActiveDeposits : function(component, event,helper) {
        console.log('resMessageactiveeposits>> ');
        var action = component.get("c.getActiveDepositDetails");
		console.log('11111>> '+action);
        action.setCallback(this, function(response) {
			console.log('222222>> '+action);
            var resMessage = response.getReturnValue();
			console.log('resMessage>> '+resMessage); 
            var state = response.getState();
			console.log('state>> '+state);
            if (state === "SUCCESS"){
                if(resMessage==null || resMessage=='' || resMessage.length==0){
                    component.set("v.activeDeposits",true);
                }
                else if(resMessage!=null && resMessage.length>0){
                    component.set("v.activeDeposits",false);
                }
            }else{
                 console.log('resMessage>> '+resMessage);
            }
        });
        $A.enqueueAction(action); 
    },
    
    closeAccount : function(component, event) {
        var action = component.get("c.deActivateTenantAccount");
        action.setCallback(this, function(response) {
            var resMessage = response.getReturnValue();
            var state = response.getState();
            console.log('resMessage>> '+resMessage);
            if (state === "SUCCESS"){
                if(resMessage=='deactivated'){
                    let currentURL = window.location.origin;
                 //   let redirectURL = currentURL + "/Sds/secur/logout.jsp?retUrl=https://staging-thedisputeservice.cs122.force.com/Sds/CommunitiesLanding";
                  let redirectURL = currentURL + "/Sds/secur/logout.jsp";
                    window.location.replace(redirectURL);
                }
            }else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    removeInternationalBankDetails : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.removeInternationalBankDetailsInfo");
        action.setParams({contactId : component.get("v.tenant.Id")});
        action.setCallback(this, function(response) {
            var resMessage = response.getReturnValue();
            var state = response.getState();
            console.log('resMessage>> '+resMessage);
            if (state === "SUCCESS"){
                if(resMessage=='successMessage'){
                    toastEvent.setParams({
                        "type" : "success",
                        "message": "Bank account removed successfully."                  
                    });                        
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    toastEvent.setParams({
                        "type" : "success",
                        "message":  resMessage                 
                    });                        
                    toastEvent.fire();
                }
            }else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    submitDetails: function(component, event) {
        var isValid = true;
        var toastEvent = $A.get("e.force:showToast");
        var title = component.find("txtTitle").get("v.value");
        var firstName = component.find("txtFirstName").get("v.value");
        var lastName = component.find("txtLastName").get("v.value");
        var email = component.find("txtEmail").get("v.value");
        var phone = component.find("phoneid").get("v.value");
        var street = component.find("streetId").get("v.value");
        var city = component.find("cityId").get("v.value");
        var state = component.find("stateId").get("v.value");
        var postCode = component.find("postCodeId").get("v.value");
        var country = component.find("countryId").get("v.value");
        var regExpPhoneformat = /^[07]{2}[0-9]{9}$/;
		var tenantFirstName = component.get("v.tenantFirstName");
		var tenantLastName = component.get("v.tenantLastName");
        if(title==undefined || title==null || title=='' ){
            toastEvent.setParams({
                "type" : "error",
                "message": "Please provide Title"                    
            });
            isValid = false;
            toastEvent.fire();
        }
        else if(firstName==undefined || firstName==null || firstName==''){
            toastEvent.setParams({
                "type" : "error",
                "message": "Please provide First Name"                    
            });
            isValid = false;
            toastEvent.fire();
        }
		else if(firstName.trim().length!=tenantFirstName.trim().length){
            toastEvent.setParams({
                "type" : "error",
                "message": "If you need to change more than 2 characters of your First name, you need to contact the scheme."                    
            });
            isValid = false;
            toastEvent.fire();
        }
		else if(firstName.trim().length==tenantFirstName.trim().length && firstName.trim()!=tenantFirstName.trim()){
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
				toastEvent.setParams({
					"type" : "error",
					"message": "If you need to change any more of your First name, you need to contact the scheme."                    
				});
				isValid = false;
				toastEvent.fire();
			}
        }
		else if(lastName==undefined || lastName==null || lastName==''){
			toastEvent.setParams({
				"type" : "error",
				"message": "Please provide Last Name"                    
			});
			isValid = false;
			toastEvent.fire();
		}
		else if(lastName.trim().length!=tenantLastName.trim().length){
			toastEvent.setParams({
				"type" : "error",
				"message": "If you need to change more than 2 characters of your Last name, you need to contact the scheme."  
			});
			isValid = false;
			toastEvent.fire();
		}
		else if(lastName.trim().length==tenantLastName.trim().length && lastName.trim()!=tenantLastName.trim()){
			var counter = 0;
			for(var i=0;i<lastName.length;i++){
				var obj = tenantLastName[i];
				if(obj != lastName[i]){
					counter++;
				}
			}
			if(counter>2){
				toastEvent.setParams({
					"type" : "error",
					"message": "If you need to change any more of your Last name, you need to contact the scheme."                    
				});
				isValid = false;
				toastEvent.fire();
			}
        }
		else if(email==undefined || email==null || email==''){
			toastEvent.setParams({
				"type" : "error",
				"message": "Please provide Email"                    
			});
			isValid = false;
			toastEvent.fire();
		}
		else if(phone==undefined || phone==null || phone==''){
			toastEvent.setParams({
				"type" : "error",
				"message": "Please provide Phone"                    
			});
			isValid = false;
			toastEvent.fire();
		}
		if(!phone.match(regExpPhoneformat)){
			toastEvent.setParams({
					"message": "Enter valid phone number starts with '07' and it must be of 11 digits"                    
				});
			isValid = false;
			toastEvent.fire();
		}
		else if(street==undefined || street==null || street==''){
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
		}
        if(isValid){
            var con = component.get("v.tenant");
            var action = component.get("c.updateContactTenantDetails");
            action.setParams({
                con: con
            });
            action.setCallback(this, function(response) {
                var resMessage = response.getReturnValue();
                var state = response.getState();
                console.log('resMessage>> '+resMessage);
                if (state === "SUCCESS"){
                    component.set("v.fieldnotEdit", true);
                    component.set("v.toggle", true);
                    toastEvent.setParams({
                        title: "Success",
                        type: "success",
                        message: "Details has been updated.",
                        duration: " 5000",
                        key: "info_alt",
                        mode: "dismissible"
                    });
                    toastEvent.fire();
                }else{
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    updateBankDetails : function(component, event) {  
        var isValid = true;
        var toastEvent = $A.get("e.force:showToast");
        var accountNumber = component.find("accountNumber").get("v.value");
        var sortCode = component.find("sortCode").get("v.value");
        var bankAccountName = component.find("bankAccountName").get("v.value");
        var bankName = component.find("bankName").get("v.value");
        console.log('sortCode+++++++++++'+sortCode);
        console.log('accountNumber+++++++++++'+accountNumber);
       
        /*if(bankName == undefined || bankName == "" || bankName==null){
            toastEvent.setParams({
                "type" : "error",
                "message": "You must provide Bank Name."                    
            });
            isValid = false;
            toastEvent.fire();
        }*/
        var specials = new RegExp('[-!$%^&*()_+|~=`{}\[\]:";\'<>?,.\/]');
        if(bankAccountName == undefined || bankAccountName == "" || bankAccountName==null){
           /* toastEvent.setParams({
                "type" : "error",
                "message": "You must provide Bank Account Name."
            });
            
            toastEvent.fire();*/
            isValid = false;
            component.set("v.nameOnAccountBlankError", true);
        }else if(specials.test(bankAccountName)){
            isValid = false;
            component.set("v.nameOnAccountSpecialCharError", true);
        }
        else{
             component.set("v.nameOnAccountBlankError", false); 
             component.set("v.nameOnAccountSpecialCharError", false);
        }
         if(sortCode == undefined || sortCode == "" || sortCode==null){
          /*  toastEvent.setParams({
                "type" : "error",
                "message": "You must provide Sort Code."                    
            });
            
            toastEvent.fire();*/
            isValid = false;
            component.set("v.sortCodeBlankError", true);
           
       }else if(sortCode == '234079'){
            isValid = false;
            component.set("v.bankOfAmericaSortCode", true);
       }
         else{
              component.set("v.sortCodeBlankError", false);  
              component.set("v.bankOfAmericaSortCode", false);
            }
      if(accountNumber == undefined || accountNumber == "" || accountNumber==null){
         /* toastEvent.setParams({
              "type" : "error",
              "message": "You must provide Account Number."                    
          });
            toastEvent.fire();
          */
          isValid = false;
           component.set("v.accountNumberBlankError", true);
       }
        else{
             component.set("v.accountNumberBlankError", false);
        }
        if(isValid){            
            var action = component.get("c.updateBankDetailsOfTenant");
            action.setParams({accountNumber : accountNumber ,
                              sortCode:sortCode,
                              bankAccountName : bankAccountName,
                              bankName : bankName,
                              accountId : component.get("v.tenant.AccountId__c"),
                              contactId : component.get("v.tenant.Id")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var messageValue = response.getReturnValue();
                    console.log('messageValue111111111 ' + messageValue);
                    if(messageValue=='UnknownSortCode'){
                       /* toastEvent.setParams({
                            "type" : "error",
                            "message": "You must provide a valid sort code."                    
                        });
                        toastEvent.fire(); */
                        isValid = false;
                        component.set("v.invalidSortCodeError", true);
                    	                       
                    }
                    else{
                      component.set("v.invalidSortCodeError", false);  
                    }
                     if(messageValue=='InvalidAccountNumber'){
                        /*toastEvent.setParams({
                            "type" : "error",
                            "message": "You must provide a valid account number."
                        });
                        toastEvent.fire();*/
                        component.set("v.invalidAccountNumberError", true);
                        isValid = false;
                    } 
                    else{
                        component.set("v.invalidAccountNumberError", false);
                    }
                    if(messageValue=='successMessage'){
                       /* toastEvent.setParams({
                            "type" : "success",
                            "message": "Bank account updated successfully."                  
                        });                        
                        toastEvent.fire();*/
                        component.set("v.bankSuccessMessage", true);
                        var appEvent = $A.get("e.c:EI_Tenantpercentagebarupdate"); 
                        appEvent.fire(); 
                        setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 1000);
                        
                       // component.set("v.fieldBankDetailsEdit", true);
        				//component.set("v.toggleBankDetails", true);
                    }
                        else {
                            toastEvent.setParams({
                                "type" : "error",
                                "message": messageValue                  
                            });                       
                            toastEvent.fire();    
                        }
                }
                else{
                    toastEvent.setParams({
                        "message": messageValue                    
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    updateInternationalBankDetails : function(component, event) {  
        var isValid = true;
        var toastEvent = $A.get("e.force:showToast");
        var bankIntName = component.find("bankIntName").get("v.value");
       // var bankIntaddress = component.find("bankIntaddress").get("v.value");
        var bankIntAccountName = component.find("bankIntAccountName").get("v.value");
        if(bankIntName == undefined || bankIntName == "" || bankIntName==null){
           /* toastEvent.setParams({
                "type" : "error",
                "message": "You must Provide Bank Name."                    
            });
            toastEvent.fire();*/
            isValid = false;
            component.set("v.intbanknameerror", true);
        }
        else {
           component.set("v.intbanknameerror", false); 
        }
            
       /* else if(bankIntaddress == undefined || bankIntaddress == "" || bankIntaddress==null){
            toastEvent.setParams({
                "type" : "error",
                "message": "You must provide Bank Address."
            });
            isValid = false;
            toastEvent.fire();
        }*/
        var specials = new RegExp('[-!$%^&*()_+|~=`{}\[\]:";\'<>?,.\/]');
        if(bankIntAccountName == undefined || bankIntAccountName == "" || bankIntAccountName==null){
          /*  toastEvent.setParams({
                "type" : "error",
                "message": "You must provide Account Name."                    
            });
            
            toastEvent.fire();*/
            isValid = false;
            component.set("v.intbankaccounterror", true);
        }else if(specials.test(bankIntAccountName)){
            isValid = false;
            component.set("v.nameOnIntAccountSpecialCharError", true);
        }
        else{
          component.set("v.intbankaccounterror", false); 
          component.set("v.nameOnIntAccountSpecialCharError", false);  
        }
        if(isValid){
            var action = component.get("c.updateIntBankDetailsOfTenant");
            action.setParams({bankIntName : bankIntName ,
                             // bankIntaddress:bankIntaddress,
                              bankIntAccountName : bankIntAccountName,
                              bankIdentificationCode : component.find("bankIdentificationCode").get("v.value"),
							  bankSwiftCode : component.find("bankSwiftCode").get("v.value"),
							  IBAN : component.find("IBAN").get("v.value"),
                              accountId : component.get("v.tenant.AccountId__c"),
                              contactId : component.get("v.tenant.Id")
							  });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var messageValue = response.getReturnValue();
                if(state == 'SUCCESS'){
                    if(messageValue=='successMessage'){
                      /*  toastEvent.setParams({
                            "type" : "success",
                            "message": "Bank account updated successfully."                  
                        });                        
                        toastEvent.fire(); */
                        component.set("v.intbankSuccessMessage", true);
                        component.set("v.fieldInternationalBankDetailsEdit", true);
        				component.set("v.toggleInternationalBankDetails", true);
                        var appEvent = $A.get("e.c:EI_Tenantpercentagebarupdate"); 
                        appEvent.fire(); 
                        setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 1000);
                         
                    }
                    else {
                        toastEvent.setParams({
                            "type" : "error",
                            "message": messageValue                  
                        });
                        isValid = false;
                        toastEvent.fire();    
                    }
                }
                else{
                    toastEvent.setParams({
                        "message": messageValue                    
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    passwordChange : function(component, event) {  
        var action = component.get("c.passwordChangeOfTenant");
        var toastEvent = $A.get("e.force:showToast");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var messageValue = response.getReturnValue();
            if(state == 'SUCCESS'){
                if(messageValue=='passwordReset'){
                    component.set("v.passwordChangePopUp", true);
                }
            }
            else{
                toastEvent.setParams({
                    "message": messageValue                    
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    updateAuthorizedPerson : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        var authorizedPerson = component.find("authorizedPerson").get("v.value");
        var action = component.get("c.updateAuthorizedPersonOfTenant");        
        action.setParams({authorizedPerson : authorizedPerson,
                          contactId : component.get("v.tenant.Id")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var messageValue = response.getReturnValue();
            if(state == 'SUCCESS'){
                if(messageValue=='updated'){
                    component.set("v.authorizedPersonEdit", true);
        			component.set("v.toggleAuthorizedPersonEdit", true);
                  //  $A.get('e.force:refreshView').fire();
                   component.set("v.authorisedPerson", true);  
                }
            }
            else{
                toastEvent.setParams({
                    "message": messageValue                    
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    updateMarketDetails : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        var checkboxEmail , checkboxSMS  ,checkboxPost;
        var optionSelected='';
        var market = document.getElementById("gridAgreement");
        var news = document.getElementById("gridSubscription");
        if(market.checked){
          //  checkboxEmail = component.find("checkboxEmail").get("v.value");
          //  checkboxSMS = component.find("checkboxSMS").get("v.value");
          //  checkboxPost = component.find("checkboxPost").get("v.value");
             checkboxEmail = document.getElementById("marketingemail");
            checkboxSMS = document.getElementById("marketingsms");
            checkboxPost = document.getElementById("marketingpost");
            if(checkboxEmail.checked){
                optionSelected = optionSelected+'Email;';
            }
            if(checkboxSMS.checked){
                optionSelected = optionSelected+'SMS;';
            }
            if(checkboxPost.checked){
                optionSelected = optionSelected+'Post;';
            }
             optionSelected = optionSelected.trim();
        }
        var action = component.get("c.updateMarketingDetails");
        if(market.checked){                                              
        	action.setParams({market: market.checked,
                          news: news.checked,
                          checkboxEmail:checkboxEmail.checked,
                          checkboxSMS:checkboxSMS.checked,
                          checkboxPost:checkboxPost.checked,
                          optionSelected : optionSelected,
                          contactId : component.get("v.tenant.Id")});
        }
        else{
            action.setParams({market: null,
                          news: news.checked,
                          checkboxEmail:null,
                          checkboxSMS:null,
                          checkboxPost:null,
                          optionSelected : optionSelected,
                          contactId : component.get("v.tenant.Id")});
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            var messageValue = response.getReturnValue();
            if(state == 'SUCCESS'){
                if(messageValue=='updated'){
                   /* toastEvent.setParams({
                        "message": "Marketing preferences updated"                    
                    });
                    toastEvent.fire();*/
                    component.set("v.marketingprefsuccess", true);
                    component.set("v.marketFieldNotEdit", true);
        			component.set("v.toggleMarketDetails", true);
                    component.set("v.MarketingMaterialsOptions", false);
                    var appEvent = $A.get("e.c:EI_Tenantpercentagebarupdate"); 
                    appEvent.fire(); 
                    setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 1000);
                }
                else{
                    component.set("v.marketingprefsuccess", false);
                }
            }
            else{
                toastEvent.setParams({
                    "message": messageValue                    
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    updateTenantViewableDetail : function(component, event,helper) {
        var toastEvent = $A.get("e.force:showToast");
        var veiwableInfo = component.get("v.datesharingtenent");
        var action = component.get("c.updateTenantViewableDetailsInfo");
        action.setParams({veiwableInfo : veiwableInfo,
                          contactId : component.get("v.tenant.Id")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var messageValue = response.getReturnValue();
            if(state == 'SUCCESS'){
                if(messageValue=='updated'){
                    /*toastEvent.setParams({
                        "message": "Data  Sharing Details updated"                    
                    });
                    toastEvent.fire();*/
                    component.set("v.datasharesuccess", true);
                    
                    setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 1000);
                }
                else{
                 component.set("v.datasharesuccess", false);
                }

            }
            else{
                toastEvent.setParams({
                    "message": messageValue                    
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})