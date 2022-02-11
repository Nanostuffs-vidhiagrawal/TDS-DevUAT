({
    getSalutationPicklist: function(component, event,helper) {
        var action = component.get("c.getSalutation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //   console.log("stategetSalutationPicklist" + state);
                var result = response.getReturnValue();
                var salutationMap = [];
                for (var key in result) {
                    salutationMap.push({ key: key, value: result[key] });
                }
                component.set("v.salutationMap", salutationMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    initHelper: function(component, event,helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchid = urlParams.get('branchId');
        
        var action = component.get("c.displayLoggedInUserContactInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            // console.log("state" + state);
            if (state === "SUCCESS") {
                //  console.log("getst" + state);
                var userCon = response.getReturnValue();
                //   console.log("getrespo" + userCon);
                console.log("getrespo" + JSON.stringify(userCon.Job_role__c));
                component.set("v.con", userCon);
                if(userCon.Job_role__c == 'Head office administrator' || userCon.Job_role__c == 'Account administrator' || userCon.Job_role__c == 'Finance administrator' ||  userCon.Additional_Permission__c == 'Update payment details' ){
                    //  alert('test');
                    component.set("v.enablePaymentDetails", true);
                }
                if(userCon.Job_role__c == 'Head office administrator' || userCon.Job_role__c == 'Account administrator' || (userCon.Job_role__c != undefined && userCon.Job_role__c == 'Manage users' )){
                    component.set("v.showAdditionalUser", true);
                }
                if(userCon.Job_role__c == 'Head office administrator' || userCon.Job_role__c == 'Account administrator' || (userCon.Job_role__c != undefined && userCon.Job_role__c == 'Edit organization details' )){
                    component.set("v.editOrgDetails", true);
                    //    alert( component.get("v.editOrgDetails")+' job role '+userCon.Job_role__c);
                }  
                var valz =component.get("v.con.MailingStreet")+"\n"+component.get("v.con.MailingCity")+"\n"+component.get("v.con.MailingState")+"\n"+component.get("v.con.MailingPostalCode")+"\n"+component.get("v.con.MailingCountry");
                component.set("v.textareaval",valz);
                component.set("v.orgAcc.tradName", userCon.Trading_Name__c);
                component.set("v.orgAcc.accName", userCon.Account_Name__c);
                component.set(
                    "v.orgAcc.regCompName",
                    userCon.Registered_Company_Name__c
                );
                component.set(
                    "v.orgAcc.regCompNo",
                    userCon.Company_Registration_Number__c
                );
                component.set("v.orgAcc.phn", userCon.Telephone_Number__c);
                component.set("v.orgAcc.add", userCon.Address__c);
            } else if (state === "ERROR") {
                var errors = response.getError();
                //    console.log(`${errors}`);
                if (errors[0] && errors[0].message) {
                    //      console.log("Error message: " + errors[0].message);
                }
            } else {
                //    console.log("Unknown error");
            }
        });
        
        let profileaction = component.get("c.checkProfile");
        profileaction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.loggedinuser", result);
                //     console.log("loggedinuser", JSON.stringify(result));
                //     console.log(result.Contact.Account.IsPersonAccount);
                if (!result.Contact.Account.IsPersonAccount) {
                    component.set("v.showCorrespSection", true);
                }
                if (result.Profile.Name=="Landlord" || result.Profile.Name=="Agent") {
                    component.set("v.showAccounttype", true);
                }
                if (result.Contact.Account.IsPersonAccount || result.Profile.Name=="Head Office User") {
                    if(result.Profile.Name=="Head Office User" || result.Profile.Name=="Branch User"){
                        component.set("v.showAccounttype", false);  
                    }
                    component.set("v.showcloseaccount", true);   
                }
                if (result.Profile.Name=="Head Office User") {
                    if(branchid != null){
                        component.set("v.branchUser",true);
                        component.set("v.paymentdetails", trur); 
                    }else{
                        component.set("v.paymentdetails", false); 
                    }
                    component.set("v.headofficeuserlist", true); 
                    
                }else{
                    component.set("v.headofficeuserlist", false);  
                    component.set("v.paymentdetails", true);
                    component.set("v.branchUser",true);
                }
                //   console.log(`Line 53`);
                ///   console.log(component.get("showCorrespSection"));
                var HeadOfficeProfileId = $A.get("$Label.c.HeadOfficeProfileId");
                if (HeadOfficeProfileId == result.ProfileId) {
                    component.set("v.showChangeAccountType", false);
                } else {
                    component.set("v.showChangeAccountType", true);
                }
            }
        });
        
        $A.enqueueAction(action);
        $A.enqueueAction(profileaction);
    },
    
    changeAccountTypeuser: function(component, event,helper) {
        //  alert('line-->60');
        //   console.log("changeAccountType+++++++++++");
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.changeAccountTypeAgentLandlord");
        action.setCallback(this, function(response) {
            //   console.log("11111+++++++++++");
            var state = response.getState();
            //   console.log("11111+++++++++++" + response.getReturnValue());
            if (state === "SUCCESS") {
                var depositRecords = response.getReturnValue();
                component.set("v.openmodel", true);
            } else {
                var messageValue = response.getReturnValue();
                toastEvent.setParams({
                    message: messageValue
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchbankdetails: function(component, event,helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var action = component.get("c.getbankaccountdetails");
        action.setParams({
            branchId:branchId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errors = response.getError();
            //    console.log(`${errors}`);
            if (errors) {
                if (errors[0] && errors[0].message) {
                    //       console.log("Error message: " + errors[0].message);
                }
            } else {
                //    console.log("Unknown error");
            }
            //  console.log("getaccountdetails" + state);
            var bankdetails = response.getReturnValue();
            // console.log("getaccountdetails" + JSON.stringify(bankdetails));
            component.set("v.Bankaccount", bankdetails);
            component.set("v.bankName", bankdetails.Bank_Name__c);
            component.set(
                "v.bankAccountName",
                bankdetails.Bank_Account_Holder_Name__c
            );
            component.set("v.sortCode", bankdetails.Sort_Code__c);
            component.set("v.accountNumber", bankdetails.Account_Number__c);
        });
        $A.enqueueAction(action);
    },
    
    updateBankDetails: function(component, event,helper) {
        var isValidbankAccountName = true;
        var isValidsortCode = true;
        var isValidaccountNumber = true;
        
        var accountNumber = component.find("accountNumber").get("v.value");
        var sortCode = component.find("sortCode").get("v.value");
        var bankAccountName = component.find("bankAccountName").get("v.value");
        var bankName = component.find("bankName").get("v.value");
        //console.log('+++++accountNumber++++++++'+accountNumber);
        //    console.log('+++++sortCode++++++++'+sortCode);
        var specials = new RegExp('[-!$%^&*()_+|~=`{}\[\]:";\'<>?,.\/]');
        if (
            bankAccountName == undefined ||
            bankAccountName == "" ||
            bankAccountName == null
        ) {
            isValidbankAccountName = false;
            component.set("v.nameOnAccountBlankError", true);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankSuccessMessage", false);
        }else if(specials.test(bankAccountName)){
            isValidbankAccountName = false;
            component.set("v.nameOnAccountSpecialCharError", true);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankSuccessMessage", false);
            component.set("v.nameOnAccountBlankError", false);
        } else {
            component.set("v.nameOnAccountBlankError", false);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankSuccessMessage", false);
            component.set("v.nameOnAccountSpecialCharError", false);
        }
        
        if (sortCode == undefined || sortCode == "" || sortCode == null) {
            isValidsortCode = false;
            component.set("v.sortCodeBlankError", true);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankSuccessMessage", false);
        }else if(sortCode == '234079'){
            isValidsortCode = false;
            component.set("v.bankOfAmericaSortCode", true);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankSuccessMessage", false);
            component.set("v.sortCodeBlankError", false);
        } else {
            component.set("v.sortCodeBlankError", false);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankOfAmericaSortCode", false);
        }
        
        if (
            accountNumber == undefined ||
            accountNumber == "" ||
            accountNumber == null
        ) {
            isValidaccountNumber = true;
            component.set("v.accountNumberBlankError", true);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankSuccessMessage", false);
        } else {
            component.set("v.accountNumberBlankError", false);
            component.set("v.bankSuccessMessage", false);
            component.set("v.bankSuccessMessage", false);
        }
        if (isValidbankAccountName && isValidsortCode && isValidaccountNumber) {
            var action = component.get("c.updateBankDetailsOfContact");
            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
            const branchId = urlParams.get('branchId');
            // alert(branchId);
            action.setParams({
                accountNumber: accountNumber,
                sortCode: sortCode,
                bankAccountName: bankAccountName,
                bankName: bankName,
                branchId:branchId
            });
            //    console.log(`Line 165`);
            action.setCallback(this, function(response) {
                //     console.log(`Line 167`);
                var state = response.getState();
                //   console.log(`state : ${state}`);
                if (state == "SUCCESS") {
                    var messageValue = response.getReturnValue();
                    //    console.log("messageValue111111111 " + messageValue);
                    if (messageValue == "UnknownSortCode") {
                        component.set("v.invalidSortCodeError", true);
                        isValidsortCode = false;
                    } else if (messageValue == "InvalidAccountNumber") {
                        component.set("v.invalidAccountNumberError", true);
                        isValidaccountNumber = false;
                    } else if (messageValue != "UnknownSortCode" && messageValue != "InvalidAccountNumber") {
                        component.set("v.bankSuccessMessage", true);
                        component.set("v.bankErrorMessage", false);
                        component.set("v.nameOnAccountBlankError", false);
                        component.set("v.nameOnAccountSpecialCharError", false);
                        component.set("v.accountNumberBlankError", false);
                        component.set("v.invalidAccountNumberError", false);
                        component.set("v.sortCodeBlankError", false);
                        component.set("v.invalidSortCodeError", false);
                        component.set("v.bankOfAmericaSortCode", false);
                        component.set("v.bankName",messageValue);
                        var appEvent = $A.get("e.c:EI_Agentpercentagebarupdate"); 
                        appEvent.fire();
                        // setTimeout(function(){    location.reload();}, 500);
                        //  $A.get('e.force:refreshView').fire();
                    } else {
                        component.set("v.bankErrorMessage", true);
                    }
                } else if (state == "ERROR") {
                    var errors = action.getError();
                    component.set("v.bankSuccessMessage", false);
                    component.set("v.bankErrorMessage", true);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    hideCorrespondenceMessages: function(component, status,helper) {
        //  console.log("status", status);
        if (status === "SUCCESS") {
            component.set("v.grnlEmailPatternError", false);
            component.set("v.grnlEmailError", false);
            component.set("v.disputeEmailPatternError", false);
            component.set("v.disputeEmailError", false);
            component.set("v.financeEmailPatternError", false);
            component.set("v.financeEmailError", false);
            component.set("v.extraEmailErrorMessage", true);
        } else {
            component.set("v.grnlEmailPatternError", false);
            component.set("v.grnlEmailError", false);
            component.set("v.disputeEmailPatternError", false);
            component.set("v.disputeEmailError", false);
            component.set("v.financeEmailPatternError", false);
            component.set("v.financeEmailError", false);
            component.set("v.extraEmailSuccessMessage", true);
        }
    },
    
    contactdetails: function(component,event,helper) {
        //      console.log(" corres" );
        var action = component.get("c.getCorrespondenceEmail");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //       console.log(" corres state"+action );
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                //   console.log("result corres", JSON.stringify(result));
                component.set("v.acc", result);
                // $A.get('e.force:refreshView').fire();
            } else {
                
            }
        });
        $A.enqueueAction(action);
    },
    
    callUpdatePrescribed: function(component,event,helper) {
        var prescribedInfo = component.get(
            "v.con.Prescribed_Information_clauses__c"
        );
        
        var prescribedRefer = component.get(
            "v.con.Prescribed_Clause_Reference__c"
        );  
        console.log("prescribedInfo", prescribedInfo);
        console.log("prescribedRefere", prescribedRefer);  
        var action = component.get("c.updatePrescribedInfo");
        action.setParams({
            prescribedInfo: prescribedInfo,prescribedRefer : prescribedRefer
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state", state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log("result", JSON.stringify(result));
                component.set("v.prescribedError", false);
                component.set("v.prescribedLengthError", false);
                component.set("v.prescribedSuccessMessage", true);
                component.set("v.prescribedErrorMessage", false);
                var appEvent = $A.get("e.c:EI_Agentpercentagebarupdate"); 
                appEvent.fire();
                //    $A.get('e.force:refreshView').fire();
                //   setTimeout(function(){      location.reload();}, 500);
            } else {
                var errors = action.getError();
                console.log("result", JSON.stringify(result));
                component.set("v.prescribedError", false);
                component.set("v.prescribedLengthError", false);
                component.set("v.prescribedSuccessMessage", false);
                component.set("v.prescribedErrorMessage", true);
                $A.get('e.force:refreshView').fire();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    callUpdatePrescribedRefer: function(component,event,helper) {
        
        var prescribedRefer = component.get(
            "v.con.Prescribed_Clause_Reference__c"
        ); 
        var prescribedInfo = component.get(
            "v.con.Prescribed_Information_clauses__c"
        );
        console.log("prescribedRefer", prescribedRefer);
        console.log("prescribedInfo", prescribedInfo);
        var action = component.get("c.updatePrescribedInfo");
        action.setParams({
            prescribedRefer : prescribedRefer, prescribedInfo: prescribedInfo
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state", state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log("result", JSON.stringify(result));
                component.set("v.prescribedReferError", false);
                component.set("v.prescribedReferLengthError", false);
                component.set("v.prescribedReferSuccessMessage", true);
                component.set("v.prescribedReferErrorMessage", false);
                var appEvent = $A.get("e.c:EI_Agentpercentagebarupdate"); 
                appEvent.fire();
                //    $A.get('e.force:refreshView').fire();
                //   setTimeout(function(){      location.reload();}, 500);
            } else {
                var errors = action.getError();
                console.log("result", JSON.stringify(result));
                component.set("v.prescribedReferError", false);
                component.set("v.prescribedReferLengthError", false);
                component.set("v.prescribedReferSuccessMessage", false);
                component.set("v.prescribedReferErrorMessage", true);
                $A.get('e.force:refreshView').fire();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },     
    
    updateOrganizationDetails: function(component,event,helper) {
        
        
        console.log("updateOrganizationDetails working " + component.get("v.con.MailingStreet"));
        if( component.get("v.editAddress")){
            var objChild = component.find("compB");
            component.set("v.con.MailingCountry", objChild.get("v.Country"));
            component.set("v.con.MailingPostalCode", objChild.get("v.PostCode"));
            component.set("v.con.MailingCity", objChild.get("v.Town"));
            component.set("v.con.MailingState", objChild.get("v.County"));
            var StreetAddress =
                objChild.get("v.AddressLine1") + "\n" + objChild.get("v.Street");
            component.set("v.con.MailingStreet", StreetAddress);
            
            console.log("updateOrganizationDetails working " +   objChild.get("v.PostCode"));
            
        }
        
        var orgAcc = component.get("v.orgAcc");
        console.log("orgAcc -->> ", JSON.stringify(orgAcc));
        var act = component.get("c.updtOrgDetails");
        act.setParams({
            accName: orgAcc.accName,
            regCompName: orgAcc.regCompName,
            tradName: orgAcc.tradName,
            regCompNo: orgAcc.regCompNo,
            telNum: orgAcc.phn,
            add: orgAcc.add,
            con: component.get("v.con")
        });
        act.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                // alert("Record is Created Successfully");
                component.set("v.successMsg", true);
                //  console.log("Success Update");
                component.set("v.editAddress",false);
                var appEvent = $A.get("e.c:EI_Agentpercentagebarupdate"); 
                appEvent.fire();
                $A.get('e.force:refreshView').fire();
                
                var conList = a.getReturnValue();
                console.log('Line 470 weird -> '+conList.length);
                if(conList.length>0) {
                    //component.set("v.con",conList[0]);
                    var valz = conList[0].MailingStreet+conList[0].MailingCity+"\n"+conList[0].MailingState+"\n"+conList[0].MailingPostalCode+"\n"+conList[0].MailingCountry;
                    component.set("v.textareaval",valz);
                    console.log('Line 475 weird -> '+valz);
                }
                // setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 1000); 
                
            } else if (state === "ERROR") {
                component.set("v.errorMsg", true);
            } else if (status === "INCOMPLETE") {
                component.set("v.errorMsg", true);
            }
        });
        $A.enqueueAction(act);
    },
    
    fetchPhoneCodePicklist : function(component, event, helper){
        console.log("fetchPhoneCodePicklist");
        var action = component.get("c.getPhoneCodePiclistValues");
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log("State => " + state);
            if (state === "SUCCESS"){
                console.log("phoneCodePicklist => " + a.getReturnValue());
                component.set("v.phoneCodePicklist", a.getReturnValue());
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
                    console.log("line-->9  " +errorList[i].MasterLabel );
                    console.log("line-->9  " +errorList[i].Error_Message__c );
                    if(errorList[i].MasterLabel === 'Sort Code'){
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.SortCodeErrorNew",userErr);
                    }
                    else if(errorList[i].MasterLabel === 'Updated Bank Account'){
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.BankAccountErrorNew",userErr);
                        
                    }                   
                        else if(errorList[i].MasterLabel === 'Phone Number'){
                            userErr = errorList[i].Error_Message__c;
                            component.set("v.phonenumberErrorNew",userErr);
                            
                        } 
                            else if(errorList[i].MasterLabel === 'Landline Number'){
                                userErr = errorList[i].Error_Message__c;
                                component.set("v.landlinenumberErrorNew",userErr);
                                
                            }  
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }
    
});