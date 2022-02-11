({
    chDate : function(component) {
        //    alert('recievedDateYMD');   
        let allDateValid = false; 
        
        let arraydate = [];
        //Grab Date Elements   
        let depositRecievedDate = document.getElementById("tenancyStartDate").value;
        let depositRecievedMonth = document.getElementById("tenancyStartMonth").value;
        let depositRecievedYear = document.getElementById("tenancyStartYear").value;
        let receivedDate = depositRecievedDate+'-'+depositRecievedMonth+'-'+depositRecievedYear;
        let recievedDateYMD =depositRecievedYear+'-'+depositRecievedMonth+'-'+depositRecievedDate;
        let jsData =   depositRecievedMonth+'-'+ depositRecievedDate+'-'+depositRecievedYear;
        
        arraydate.push(receivedDate);
        let isValidDate = validatedate(receivedDate);
        let loopCounter = 0;
        for(var i=0; i<arraydate.length; i++) {
            allDateValid = validatedate(arraydate[i]);        
            if(allDateValid==false) {
                if(loopCounter == 0) {
                    component.set("v.showRecievedDateError",true);
                    component.set("v.dateCantGreat",false);
                } else {
                    component.set("v.showRecievedDateError",false);
                    component.set("v.showTenancyDateError",true);
                }
                break;
            } else {
                component.set("v.showRecievedDateError",false);
                component.set("v.showTenancyDateError",false);	
            }
            loopCounter++;
        }
        
        //GOD Class for Required Field Validation
        function requiredFieldValidation(x) {
            if(x==undefined || x==null || x==""){             
                return false;  
            }
            else{
                return true;  
            }  
        }
        
        //GOD class to check date validity
        function validatedate(d)
        {
            var dateformat = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
            // Match the date format through regular expression
            if(d.match(dateformat))
            {     
                var splittedDate = d.split('-');
                var splittedDateLength = splittedDate.length;
                if (splittedDateLength>1)
                {
                    var pdate = d.split('-');
                }
                var dd = parseInt(pdate[0]);
                var mm  = parseInt(pdate[1]);
                var yy = parseInt(pdate[2]);
                
                // Create list of days of a month [assume there is no leap year by default]
                var ListofDays = [31,28,31,30,31,30,31,31,30,31,30,31];
                if (mm==1 || mm>2)
                {
                    if (dd>ListofDays[mm-1])
                    {
                        return false;
                    }
                }
                if (mm==2)
                {
                    var lyear = false;
                    if ( (!(yy % 4) && yy % 100) || !(yy % 400)) 
                    {
                        lyear = true;
                    }
                    if ((lyear==false) && (dd>=29))
                    {
                        return false;
                    }
                    if ((lyear==true) && (dd>29))
                    {
                        return false;
                    }
                }
                return true;
            }
            else
            {
                return false;
            }
        }
        console.log('today date '+jsData); 
        var today = new Date();
        var endDate = new Date(jsData)
        console.log('endDate date '+endDate); 
        /*var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();        
        today = dd + '-' + mm + '-' + yyyy;*/
        console.log('today date '+today.getTime()+' '+endDate.getTime()); 
        console.log('aaj date '+today.getTime());
        console.log('last date '+endDate.getTime());
        if(endDate.getTime() > today.getTime()) {
            console.log('great '); 
            allDateValid = false;
            component.set("v.dateCantGreat",true);
            
        } else if(!endDate.getTime()) {
            allDateValid = false;
            
        } else {
            allDateValid = true;
            component.set("v.dateCantGreat",false);
        }
        
        if(allDateValid) {
            component.set("v.depositRecievedDate",recievedDateYMD);
            console.log(component.get("v.depositRecievedDate"));
        }
        else {
            component.set("v.depositRecievedDate",""); 
        }
           
       },
    
    helperAgentTotal: function(component, event, helper, total){
        var amountValue = total;
        // alert(amountValue);
        
        var tenantTitle = component.get("v.depositAllocation[0].Deposit__r.Customer__c"); //alert(tenantTitle);
        var jsonArrayData = component.get("v.tenInfo");
        let keyfound=false;
        if(jsonArrayData == undefined || jsonArrayData == null) {	
            console.log(' 11111');
            jsonArrayData=[];
            jsonArrayData.push({key:tenantTitle,value:Number(amountValue)}); 
        }
        else {	
            console.log(' 1111jsonArrayData1'+jsonArrayData);
            if(jsonArrayData.length>0)
            {
                for(let i=0;i<jsonArrayData.length;i++) {	
                    console.log(' 222333333333333333333333322');
                    let tempobj= jsonArrayData[i];
                    console.log(' tempobj[keyName]'+tempobj[tenantTitle]);
                    console.log(' jsonArrayData[i]'+jsonArrayData[i].key);
                    /*if(tempobj[keyName]!=undefined)
					{
						tempobj[keyName]=tenAmt;
						keyfound=true;
						break;
					}*/
                    if(jsonArrayData[i].key == tenantTitle) {
                        jsonArrayData[i].value = amountValue;
                        keyfound=true;
                        break;
                    }
                }
                if(!keyfound)
                {
                    jsonArrayData.push({key:tenantTitle,value:Number(amountValue)}); 
                }
            }
            else {
                console.log(' 4444444444444444'+jsonArrayData);
                jsonArrayData=[];
                jsonArrayData.push({key:tenantTitle,value:Number(amountValue)});
            }
        }
        //jsonArrayData.push({key:keyName,value:tenAmt}); 
        component.set("v.tenInfo" , jsonArrayData);
        console.log(' 55555'+component.get("v.tenInfo"));
        console.log('+++++++174++++++++tenInfoTenant'+JSON.stringify(component.get("v.tenInfoTenant")));
        console.log('+++++++5454++++++++'+JSON.stringify(component.get("v.tenInfo")));
        
    },
    
    bankDetails : function(component, event, helper) {
        var action = component.get("c.getBankDetails"); 
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            var returnResult = a.getReturnValue();
            console.log('@@bank 2222222222'+returnResult+'5555555state'+state);
            if (state == "SUCCESS" ) {
                if(returnResult ==null || returnResult == '') {
                    console.log('@@bank 1111');
                    component.set("v.noBankDetails",true);
                }
                else if(returnResult != '' || returnResult != null) {
                    component.set("v.bankDetails",returnResult);
                    component.set("v.bankAccountName",returnResult[0].Bank_Account_Holder_Name__c);
                    component.set("v.accountNumber",returnResult[0].Account_Number__c);
                    component.set("v.sortCode",returnResult[0].Sort_Code__c);
                    component.set("v.bankName",returnResult[0].Bank_Name__c);
                    
                    component.set("v.bankIntName",returnResult[0].International_Bank_Account_Holder_Name__c);
                    component.set("v.bankIdentificationCode",returnResult[0].BIC__c);
                    component.set("v.bankSwiftCode",returnResult[0].Swift_Code__c);
                    component.set("v.IBAN",returnResult[0].IBAN__c);
                    component.set("v.nameOnAccount",returnResult[0].International_Bank_Name__c);
                    component.set("v.noBankDetails",false);
                }
            }
            console.log('@@bank '+component.get("v.noBankDetails"));
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
        
        if(bankAccountName == undefined || bankAccountName == "" || bankAccountName==null) {
            component.set('v.nameOnAccountBlankError',true);
            isValid = false;
        }
        if(sortCode == undefined || sortCode == "" || sortCode==null) {
            component.set('v.sortCodeBlankError',true);
            isValid = false;
        }
        if(accountNumber == undefined || accountNumber == "" || accountNumber==null) {
            component.set('v.accountNumberBlankError',true);
            isValid = false;
        }
        if(specials.test(bankAccountName)) {
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
            action.setParams({
                accountNumber : accountNumber ,
                sortCode:sortCode,
                bankAccountName : bankAccountName,
                bankName : bankName
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state ' + state);
                if(state == 'SUCCESS') {
                    var messageValue = response.getReturnValue();
                    //console.log('messageValue111111111 ' + messageValue);
                    if(messageValue=='UnknownSortCode') {
                        component.set('v.invalidSortCodeError',true);					
                    }
                    else if(messageValue=='InvalidAccountNumber') {
                        component.set('v.invalidAccountNumberError',true);				
                    } else {
                        component.set('v.bankName',messageValue);
                        component.set("v.noBankDetails",false);
                        component.set("v.bankSuccessMessage",true);
                        component.set("v.fieldBankDetailsEdit", true);
                        component.set("v.toggleBankDetails", true);
                        setTimeout(function(){ 
                        component.set('v.ShowBankDetails',false);
      					component.set('v.ShowErrorBank',false);
                             component.set("v.bankSuccessMessage",false);
                            }, 1000);
                    } 
                }
                else if(state =='ERROR') {
                    console.log('In Error');
                    var errors = action.getError();
                    console.log('errors---'+JSON.stringify(errors));
                    
                } else {
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
        var bankIntAccountName = component.find("bankIntAccountName").get("v.value");
        var bankIdentificationCode = component.find("bankIdentificationCode").get("v.value");
        var bankSwiftCode = component.find("bankSwiftCode").get("v.value");
        var IBAN = component.find("IBAN").get("v.value");
        var specials = new RegExp('[-!$%^&*()_+|~=`{}\[\]:";\'<>?,.\/]');
        // var bankIntaddress = component.find("bankIntaddress").get("v.value");
        
        if(bankIntName == undefined || bankIntName == "" || bankIntName==null) {
            isValid = false;
            component.set("v.intbanknameerror", true);
            
        } else {
            component.set("v.intbanknameerror", false); 
        }
        
        if(bankIntAccountName == undefined || bankIntAccountName == "" || bankIntAccountName==null) {
            isValid = false;
            component.set("v.intbankaccounterror", true);
            
        } else {
            component.set("v.intbankaccounterror", false);  
        }
        
        if(specials.test(bankIntAccountName)) {
            component.set("v.intNameOnAccountSpecialCharError", true);
            isValid = false;
            
        } else {
            component.set("v.intNameOnAccountSpecialCharError", false);  
        }
        
        if(isValid) {
            var action = component.get("c.updateIntBankDetailsOfTenant");
            action.setParams({
                bankIntName : bankIntName ,
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
                if(state == 'SUCCESS') {
                    if(messageValue=='successMessage') {
                        /*  toastEvent.setParams({
                            "type" : "success",
                            "message": "Bank account updated successfully."                  
                        });                        
                        toastEvent.fire(); */
                        //  component.set("v.ShowSubmit", false);
                        component.set("v.intbankSuccessMessage", true);
                        component.set("v.noBankDetails",false);
                        component.set("v.ShowErrorBank",false);
                        // component.set("v.fieldInternationalBankDetailsEdit", true);
                        //component.set("v.toggleInternationalBankDetails", true);
                        //  $A.get('e.force:refreshView').fire();
                          setTimeout(function(){ 
                             
                        component.set('v.ShowBankDetails',false);
      					component.set('v.ShowErrorBank',false);
                             component.set("v.intbankSuccessMessage",false);
                            }, 1000);
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
                else {
                    toastEvent.setParams({
                        "message": messageValue                    
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    insertRequestRepaymentRecord :function(component) {
        var isValid = true;
        var amount = 0.0;
        var totalamt = component.get("v.depositAllocation[0].Deposit__r.Protected_Amount__c");
        var tenantsAmountInfo;
        var jsonArrayData2 = component.get("v.tenInfo");
        jsonArrayData2=[];
        
        /*Newly added code START*/
        var contactId = component.get("v.currentUser.ContactId");
        var depositAlloc = component.get("v.depositAllocation");
        /*Newly added code END*/
        
        if(tenantsAmountInfo == null && component.get("v.replyToMe")) {
            amount =  component.get("v.depositAllocation[0].Deposit__r.Protected_Amount__c");
            /*Newly added code START*/
            component.set("v.tenInfo", null);
            for(let i=0; i<depositAlloc.length; i++) {
                if(contactId==depositAlloc[i].Deposit_Holder__r.PersonContactId) {
                    jsonArrayData2.push({key:depositAlloc[i].Deposit_Holder__c,value:Number(amount)});
                } else {
                    jsonArrayData2.push({key:depositAlloc[i].Deposit_Holder__c,value:0.0});
                }
            }
            jsonArrayData2.push({key:component.get("v.deposit").Customer__c,value:0.0});
            /*Newly added code END*/
            //var tenantTitle = component.get("v.loggedindepositholder[0].Deposit_Holder__c");
            //jsonArrayData2.push({key:tenantTitle,value:Number(amount)});
            component.set("v.tenInfo" , jsonArrayData2);
        }
        
        /*Newly added code START*/
        if(component.get("v.replyToAll")) {
            var jsonTenantInfo = component.get("v.tenInfo");
            jsonTenantInfo.push({key:component.get("v.deposit").Customer__c,value:0.0});
            component.set("v.tenInfo" , jsonTenantInfo);
        }
        /*Newly added code END*/
        
        console.log('Line 427 -> ',JSON.stringify(component.get("v.tenInfo")));
        
        tenantsAmountInfo = component.get("v.tenInfo");
        for(let i=0;i<tenantsAmountInfo.length;i++) {
            amount = amount + tenantsAmountInfo[i].value;
        }        
        var tenancyDate = component.get("v.depositRecievedDate");
        if(isValid) {
            console.log('+isValid2++'+isValid);
            component.set("v.disabledBtn",true);
            var action = component.get('c.insertRepaymentReqTenant');
            action.setParams({
                depositId : component.get("v.depositRecordId"),
                accId : component.get("v.depositAllocation[0].Deposit_Holder__c"),
                tenancyDate : tenancyDate,
                values : JSON.stringify(component.get("v.tenInfo")),
                customerName : component.get("v.deposit.Customer_Name__c"),
                Tenant_Other:component.get("v.OtherAmount"),
                Tenant_Rent_Arrears:component.get("v.rentAmount"),
                Tenant_Gardening:component.get("v.gardeningAmount"),
                Tenant_Redecoration:component.get("v.redecorationAmount"),
                Tenant_Dmg_to_Property:component.get("v.damageAmount"),
                Tenant_Cleaning:component.get("v.cleaningAmount"),
                Tenant_Other_Reason:component.get("v.tArea")
            });
            action.setCallback(this, function(response) {
                var allValues = response.getReturnValue();
                var state = response.getState();
                console.log('insertRequestRepaymentRecord state'+state)
                if(state == 'SUCCESS') {
                    if(allValues!=null) {
                        component.set("v.ShowThanq",true);
                    }
                }
                else if (state === "ERROR") {
                    document.body.scrollTop = 0;
                    document.documentElement.scrollTop = 0;
                    component.set("v.disabledBtn",false);
                    component.set("v.submitError",true);
                    
                    console.log("In Error mode");
                    var errors = action.getError();
                    console.log('errors---'+JSON.stringify(errors));
                }
            });
        }
        $A.enqueueAction(action);
    },
    
    getDepositDetails :function(component,event,helper) {
        var action = component.get('c.getDepositInformation');
        action.setParams({depositRecordId : component.get("v.depositRecordId")});
        action.setCallback(this, function(response) {
            var allValues = response.getReturnValue();
            if(allValues!=null) {
                console.log('allValues display-- >> ' + allValues);
                component.set("v.deposit", allValues);
                var protAmount =  component.get("v.deposit.Protected_Amount__c");
                console.log('protAmount '+protAmount);
                component.set("v.loggedindepositholder[0].value",protAmount); 
            }
        });        
        $A.enqueueAction(action);
    },
    
    getTenantDetails :function(component,event,helper) {
        var action = component.get('c.getTenantsInformation');
        // console.log('11111-- >> '+component.get("v.depositRecordId"));
        action.setParams({depositRecordId : component.get("v.depositRecordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('ddhk-->'+JSON.stringify(response.getReturnValue()));
                var allValues = response.getReturnValue();
                
                if(allValues!=null) {
                    component.set("v.depositAllocation",allValues);
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
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
    
    getError:function (component, event, helper) {
        
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {               
                // console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
                component.set("v.errorList",response.getReturnValue());
                var errorList= component.get("v.errorList");                 
                var userErr;
                
                for(var i=0; i<errorList.length; i++) {
                   // console.log("line-->9  " +errorList[i].MasterLabel );
                   // console.log("line-->9  " +errorList[i].Error_Message__c );
                    if(errorList[i].MasterLabel === 'Repayment Requested By Tenant') {
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.repRequestErrorNew",userErr);
                    }
                    else if(errorList[i].MasterLabel === 'Date Repayment') {
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.repDateErrorNew",userErr);
                    }  
                    else if(errorList[i].MasterLabel === 'Tenant Repayment Request') {
                            userErr = errorList[i].Error_Message__c;
                            component.set("v.repTenantErrorNew",userErr);
                    }
                    else if(errorList[i].MasterLabel === 'Tenant Repayment Request Deposit Amount') {
                    	userErr = errorList[i].Error_Message__c;
                        component.set("v.depTenantErrorNew",userErr);
                    }
                    else if(errorList[i].MasterLabel === 'Other Disputed Items') {
                    	userErr = errorList[i].Error_Message__c;
                        component.set("v.disputeItemErrorNew",userErr);
                    }                                    
                }
            }
            else {
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }
    
})