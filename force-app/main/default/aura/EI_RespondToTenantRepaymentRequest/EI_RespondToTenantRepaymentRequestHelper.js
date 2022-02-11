({
    doSubmitHelper : function(component, repaymentRec) {
	// console.log(JSON.stringify(repaymentRec));
         if(repaymentRec.Tenant_Cleaning__c=="" || repaymentRec.Tenant_Cleaning__c==undefined){           
            repaymentRec.Tenant_Cleaning__c = 0;         
        }
        if(repaymentRec.Tenant_Dmg_to_Property__c=="" || repaymentRec.Tenant_Dmg_to_Property__c==undefined){           
            repaymentRec.Tenant_Dmg_to_Property__c = 0;         
        }
        if(repaymentRec.Tenant_Gardening__c=="" || repaymentRec.Tenant_Gardening__c==undefined){           
            repaymentRec.Tenant_Gardening__c = 0;         
        }
        if(repaymentRec.Tenant_Rent_Arrears__c=="" || repaymentRec.Tenant_Rent_Arrears__c==undefined){           
            repaymentRec.Tenant_Rent_Arrears__c = 0;         
        }
        if(repaymentRec.Tenant_Redecoration__c=="" || repaymentRec.Tenant_Redecoration__c==undefined){           
            repaymentRec.Tenant_Redecoration__c = 0;         
        }
        if(repaymentRec.Tenant_Other__c=="" || repaymentRec.Tenant_Other__c==undefined){           
            repaymentRec.Tenant_Other__c = 0;         
        }
        var tenantrequestedAmount = parseFloat(repaymentRec.Tenant_Cleaning__c) + parseFloat(repaymentRec.Tenant_Dmg_to_Property__c) +
            parseFloat(repaymentRec.Tenant_Gardening__c) + parseFloat(repaymentRec.Tenant_Rent_Arrears__c) +
            parseFloat(repaymentRec.Tenant_Redecoration__c) + parseFloat(repaymentRec.Tenant_Other__c);
      //  console.log("requestedAmount",tenantrequestedAmount);
        component.set("v.tenantrequestedAmount", tenantrequestedAmount);
    },
    
    checkBankDetails : function(component, event, helper) {
        let action = component.get("c.fetchBankDetails");
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log("state-->>" + state);
            if (state === "SUCCESS") {

                var result = response.getReturnValue();
                //console.log("result 9 bank details - :", JSON.stringify(result));
                
                if(result ==null || result == '' || result==undefined) {
                    console.log('@@bank 1111');
                    //component.set("v.noBankDetails",true);
                    component.set("v.isBankDetailsPresent", false);
                }
                else if(result != '' && result != null && result != undefined) {
                    component.set("v.bankDetails",result);
                    //alert(`${JSON.stringify(result)}`)
                    component.set("v.bankAccountName",result[0].Bank_Account_Holder_Name__c);
                    component.set("v.accountNumber",result[0].Account_Number__c);
                    component.set("v.sortCode",result[0].Sort_Code__c);
                    component.set("v.bankName",result[0].Bank_Name__c);
                    
                    component.set("v.bankIntName",result[0].International_Bank_Account_Holder_Name__c);
                    component.set("v.bankIdentificationCode",result[0].BIC__c);
                    component.set("v.bankSwiftCode",result[0].Swift_Code__c);
                    component.set("v.IBAN",result[0].IBAN__c);
                    component.set("v.nameOnAccount",result[0].International_Bank_Name__c);
                    component.set("v.isBankDetailsPresent", true);
                }
                
            } else if (state === "ERROR") {
                var error = response.getError();
                console.log(error);
            }
        });
        $A.enqueueAction(action);
    },
    
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
        var toastEvent = $A.get("e.force:showToast");
        
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
                              bankName : bankName});
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
                    if(messageValue=='UnknownSortCode') {
                        component.set('v.invalidSortCodeError',true);					
                    } else if(messageValue=='InvalidAccountNumber') {
                         component.set('v.invalidAccountNumberError',true);				
                    } else {
                        component.set('v.bankName',messageValue);
                        
                        component.set("v.bankSuccessMessage",true);
                        component.set("v.fieldBankDetailsEdit", true);
        				component.set("v.toggleBankDetails", true);
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
        var toastEvent = $A.get("e.force:showToast");
        
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
                        //  component.set("v.ShowSubmit", false);
                        // component.set("v.fieldInternationalBankDetailsEdit", true);
                        //component.set("v.toggleInternationalBankDetails", true);
                        //  $A.get('e.force:refreshView').fire();
                        component.set("v.intbankSuccessMessage", true);
                        component.set("v.isBankDetailsPresent",true);
                        component.set("v.noBankDetailsFoundError",false);
                        component.set("v.disableBankEdit", true);
                        component.set("v.disableInterBankEdit", true);
                        component.set("v.intbankSuccessMessage", true);
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
    
})