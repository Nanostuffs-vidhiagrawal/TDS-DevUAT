({
    /*updateBankDetails : function(component, event) {  
        var isValid = true;
        var toastEvent = $A.get("e.force:showToast");
        var accountNumber = component.find("accountNumber").get("v.value");
        var sortCode = component.find("sortCode").get("v.value");
        var bankAccountName = component.find("bankAccountName").get("v.value");
        var bankName = component.find("bankName").get("v.value");
        console.log('sortCode+++++++++++'+sortCode);
        console.log('accountNumber+++++++++++'+accountNumber);
        //if(bankName == undefined || bankName == "" || bankName==null){
        //    toastEvent.setParams({
        //        "type" : "error",
        //        "message": "You must provide Bank Name."                    
        //    });
        //    isValid = false;
        //    toastEvent.fire();
        //}
          if(bankAccountName == undefined || bankAccountName == "" || bankAccountName==null){
              toastEvent.setParams({
                  "type" : "error",
                  "message": "You must provide Bank Account Name."
              });
              isValid = false;
              toastEvent.fire();
          }
          else if(sortCode == undefined || sortCode == "" || sortCode==null){
              toastEvent.setParams({
                  "type" : "error",
                  "message": "You must provide Sort Code."                    
              });
              isValid = false;
              toastEvent.fire();
          }
              else if(accountNumber == undefined || accountNumber == "" || accountNumber==null){
                  toastEvent.setParams({
                      "type" : "error",
                      "message": "You must provide Account Number."                    
                  });
                  isValid = false;
                  toastEvent.fire();
              }
          if(isValid){            
              var action = component.get("c.updateBankDetailsOfTenant");
              action.setParams({accountNumber : accountNumber ,
                                sortCode:sortCode,
                                bankAccountName : bankAccountName,
                                bankName : bankName,
                                accountId : '',
                                contactId : ''});
              action.setCallback(this, function(response) {
                  var state = response.getState();
                  if(state == 'SUCCESS'){
                      var messageValue = response.getReturnValue();
                      console.log('messageValue111111111 ' + messageValue);
                      if(messageValue=='UnknownSortCode'){
                          toastEvent.setParams({
                              "type" : "error",
                              "message": "You must provide a valid sort code."                    
                          });
                          isValid = false;
                          toastEvent.fire();				
                      }
                      else if(messageValue=='InvalidAccountNumber'){
                          toastEvent.setParams({
                              "type" : "error",
                              "message": "You must provide a valid account number."
                          });
                          isValid = false;
                          toastEvent.fire();				
                      }else if(messageValue=='successMessage'){
                          toastEvent.setParams({
                              "type" : "success",
                              "message": "Bank account updated successfully."                  
                          });
                          isValid = false;                        
                          toastEvent.fire();
                          // $A.get('e.force:refreshView').fire();
                          component.set("v.fieldBankDetailsEdit", true);
                          component.set("v.toggleBankDetails", true);
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
    
    updateInternationalBankDetails : function(component, event) {  
        var isValid = true;
        var toastEvent = $A.get("e.force:showToast");
        var bankIntName = component.find("bankIntName").get("v.value");
        var bankIntaddress = component.find("bankIntaddress").get("v.value");
        var bankIntAccountName = component.find("bankIntAccountName").get("v.value");
        if(bankIntName == undefined || bankIntName == "" || bankIntName==null){
            toastEvent.setParams({
                "type" : "error",
                "message": "You must Bank Name."                    
            });
            isValid = false;
            toastEvent.fire();
        }
        else if(bankIntaddress == undefined || bankIntaddress == "" || bankIntaddress==null){
            toastEvent.setParams({
                "type" : "error",
                "message": "You must provide Bank Address."
            });
            isValid = false;
            toastEvent.fire();
        }
            else if(bankIntAccountName == undefined || bankIntAccountName == "" || bankIntAccountName==null){
                toastEvent.setParams({
                    "type" : "error",
                    "message": "You must provide Account Name."                    
                });
                isValid = false;
                toastEvent.fire();
            }
        if(isValid){
            var action = component.get("c.updateIntBankDetailsOfTenant");
            action.setParams({bankIntName : bankIntName ,
                              bankIntaddress:bankIntaddress,
                              bankIntAccountName : bankIntAccountName,
                              bankIdentificationCode : component.find("bankIdentificationCode").get("v.value"),
                              bankSwiftCode : component.find("bankSwiftCode").get("v.value"),
                              IBAN : component.find("IBAN").get("v.value"),
                              accountId : '',
                              contactId : ''
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var messageValue = response.getReturnValue();
                if(state == 'SUCCESS'){
                    if(messageValue=='successMessage'){
                        toastEvent.setParams({
                            "type" : "success",
                            "message": "Bank account updated successfully."                  
                        });
                        isValid = false;                        
                        toastEvent.fire(); 
                        component.set("v.fieldInternationalBankDetailsEdit", true);
                        component.set("v.toggleInternationalBankDetails", true);
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
    }, */
    
    updateBankDetails : function(component, event) {
        component.set('v.bankSuccessMessage',false);
        component.set('v.bankErrorMessage',false);
        component.set('v.nameOnAccountBlankError',false);
        component.set('v.accountNumberBlankError',false);
        component.set('v.invalidAccountNumberError',false);
        component.set('v.sortCodeBlankError',false);
        component.set('v.invalidSortCodeError',false);
        component.set('v.nameOnAccountSpecialCharError',false);
        component.set('v.bankOfAmericaSortCode',false);
        
        var isValid = true;
        //var toastEvent = $A.get("e.force:showToast");

        var bankAccountName = component.find("bankAccountName").get("v.value");
        var accountNumber = component.find("accountNumber").get("v.value");
        var sortCode = component.find("sortCode").get("v.value");
        var bankName = component.find("bankName").get("v.value");
        var specials = new RegExp('[-!$%^&*()_+|~=`{}\[\]:";\'<>?,.\/]');
        
        if(bankAccountName == undefined || bankAccountName == "" || bankAccountName==null){
            component.set('v.nameOnAccountBlankError',true);
            isValid = false;
        }
        if(sortCode == undefined || sortCode == "" || sortCode==null){
            component.set('v.sortCodeBlankError',true);
            isValid = false;
        }
      	if(accountNumber == undefined || accountNumber == "" || accountNumber==null){
          component.set('v.accountNumberBlankError',true);
          isValid = false;
       	}
        if(specials.test(bankAccountName)){
            component.set("v.nameOnAccountSpecialCharError", true);
            isValid = false;
        }
        if(sortCode == '234079') {
            component.set("v.bankOfAmericaSortCode", true);
            isValid = false;
        }
        
        if(isValid) {
            console.log('isValid'+isValid);
            var action = component.get("c.updateBankDetailsOfTenant");
            action.setParams({accountNumber : accountNumber ,
                              sortCode:sortCode,
                              bankAccountName : bankAccountName,
                              bankName : bankName,
                              accountId:component.get("v.currentUser.AccountId"),
                              contactId:component.get("v.currentUser.ContactId")
                              });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state ' + state);
                if(state == 'SUCCESS') {
                    component.set("v.isBankDetailsPresent",true);
                    component.set("v.noBankDetailsFoundError",false);
                    component.set("v.disableBankEdit", true);
                    component.set("v.disableInterBankEdit", true);
                    var messageValue = response.getReturnValue();
                    console.log('messageValue111111111 ' + messageValue);
                    //alert(messageValue);
                    if(messageValue=='UnknownSortCode') {
                        component.set('v.invalidSortCodeError',true);					
                    } else if(messageValue=='InvalidAccountNumber') {
                         component.set('v.invalidAccountNumberError',true);				
                    } else {
                        component.set('v.bankName',messageValue);
                        
                        component.set("v.bankSuccessMessage",true);
                        component.set("v.fieldBankDetailsEdit", true);
        				component.set("v.toggleBankDetails", true);
                        
                        //$A.get('e.force:refreshView').fire();
                        component.set("v.noBankDetails", false);
                    }
                }
                else if(state =='ERROR') {
                    
                    console.log('In Error');
                    var errors = action.getError();
                    console.log('errors---'+JSON.stringify(errors));
                    
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
        component.set('v.intbankSuccessMessage',false);
        
        var isValid = true;
      	//  var toastEvent = $A.get("e.force:showToast");
        
        var bankIntName = component.find("bankIntName").get("v.value");
        var bankIdentificationCode = component.find("bankIdentificationCode").get("v.value");
        var bankSwiftCode = component.find("bankSwiftCode").get("v.value");
        var IBAN = component.find("IBAN").get("v.value");
        var bankIntAccountName = component.find("bankIntAccountName").get("v.value");
        var specials = new RegExp('[-!$%^&*()_+|~=`{}\[\]:";\'<>?,.\/]');
       	//var bankIntaddress = component.find("bankIntaddress").get("v.value");

        if(bankIntName == undefined || bankIntName == "" || bankIntName==null) {
            isValid = false;
            component.set("v.intbanknameerror", true);
        }
        else {
           component.set("v.intbanknameerror", false); 
        }

        if(bankIntAccountName == undefined || bankIntAccountName == "" || bankIntAccountName==null){
            isValid = false;
            component.set("v.intbankaccounterror", true);
        }
        else{
          component.set("v.intbankaccounterror", false);  
        }
        
        if(specials.test(bankIntAccountName)){
            component.set("v.intNameOnAccountSpecialCharError", true);
            isValid = false;
        }
        else{
          component.set("v.intNameOnAccountSpecialCharError", false);  
        }
        
        if(isValid){
            var action = component.get("c.updateIntBankDetailsOfTenant");
            action.setParams({bankIntName : bankIntName ,
                             // bankIntaddress:bankIntaddress,
                              bankIntAccountName : bankIntAccountName,
                              bankIdentificationCode : component.find("bankIdentificationCode").get("v.value"),
							  bankSwiftCode : component.find("bankSwiftCode").get("v.value"),
							  IBAN : component.find("IBAN").get("v.value"),
                              accountId:component.get("v.currentUser.AccountId"),
                              contactId:component.get("v.currentUser.ContactId")
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
                      //  component.set("v.ShowSubmit", false);
                        component.set("v.intbankSuccessMessage", true);
                       // component.set("v.fieldInternationalBankDetailsEdit", true);
        				//component.set("v.toggleInternationalBankDetails", true);
                       //$A.get('e.force:refreshView').fire();
                       component.set("v.noBankDetails", false); 
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
    
    tenentDetails : function(component, event, helper) {
        
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        console.log(depositId);
        var action = component.get("c.getTenantAndDepositDetails");         
        action.setParams({
            depositId : depositId          
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            console.log('@@ '+a.getReturnValue());
            if (state == "SUCCESS" ) {
                var returnResult = a.getReturnValue();
                component.set("v.depositDetails",returnResult);
            }
        });
        $A.enqueueAction(action);
    },
    
    tenentDetailslist : function(component, event, helper) {
        
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        var action = component.get("c.alltenantlist");         
        action.setParams({
            depositId : depositId          
        });
        action.setCallback(this, function (response) {
            //alert('208');
            var state = response.getState();
            var errors = response.getError();
            console.log("errors new --->> " + JSON.stringify(errors));
            if (state == "SUCCESS" ) {
                
                var returnResult = response.getReturnValue();
                console.log("tenantlist new --->> " + JSON.stringify(returnResult));
                component.set("v.depositDetailslist",returnResult);
            }
        });
        $A.enqueueAction(action);
    }, 
    
    bankDetails : function(component, event, helper) { 
        var action = component.get("c.displayBankDetails");
        action.setCallback(this, function (response) {
            var state = response.getState();
            var tenantBankDetails = response.getReturnValue();
            console.log("200state: " + tenantBankDetails[0].Sort_Code__c);
            if (state === "SUCCESS") {
                //if(tenantBankDetails[0].Sort_Code__c != '' ){
                if(tenantBankDetails.length>0) {
                    //  alert(tenantBankDetails.length);
                    console.log("tenantBankDetails: " + tenantBankDetails);
                    component.set("v.noBankDetails",false);
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
    
    submitCase : function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const depositId = urlParams.get('id');
        //     alert('submit '+ depositId + component.get("v.depositDetails.Deposit__r.Customer__c"));

        var action = component.get("c.submitCaseOnChangeOver");         
        action.setParams({
            depositId : depositId,
            AgentId :component.get("v.depositDetails.Deposit__r.Customer__c"),
            depositDetails : component.get("v.depositDetails")
        });
        action.setCallback(this, function (a) {
            
            
            var state = a.getState();
            var errors = a.getError();
            //    alert('submit '+state);
            var result = a.getReturnValue();            
            if (result == "Success" ) {
                alert('Successfully initiated change over');  
                component.find("navService").navigate({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "home"
                    },
                    state: {
                        
                    }
                });
            }
            else{
                alert('Error '+result);  
            }
        });
        $A.enqueueAction(action);
        
    },
    
     getError:function (component, event, helper){
       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
        console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
            component.set("v.errorList",response.getReturnValue());
                  var   errorList= component.get("v.errorList");                 
                	var userErr;
                
              for(var i=0; i<errorList.length; i++){
                  //console.log("line-->9  " +errorList[i].MasterLabel );
                   //console.log("line-->9  " +errorList[i].Error_Message__c );
                     
                /*  if(errorList[i].MasterLabel === 'Tenant Repayment Add Button'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.addRepButtonErrorNew",userErr);
                  } */
                  
                   if(errorList[i].MasterLabel === 'Changeover Account Number'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.addNumberErrorNew",userErr);
                  } 
                  else if(errorList[i].MasterLabel === 'Changeover Sort Code'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.addsortcodeErrorNew",userErr);
                  }  
                  
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }

    
    
    
})