({
    waiting: function(component, event, helper) {
        //    component.set("v.HideSpinner", true);
    },
    
    doneWaiting: function(component, event, helper) {
        setTimeout(function(){  component.set("v.PageSpinner",false); 
                              
                             }, 2200);
    },
    
    loginPage: function(component, event, helper) {
        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL") + "login";
        window.location.replace(urlRedirect);
        return false;
    },
    
    doInit: function(component, event, helper) {
      /*  debugger;
        if(helper.calledFromCertificateBuilder())
            alert('cert builder');
            */
        // fetch Phone Code Picklist
        // draftId
        helper.getError(component, event, helper);
        helper.fetchPhoneCodePicklist(component, event, helper);
    },
    
    userTitle: function(component, event, helper) {
        var sel = document.getElementById("SelectTitle");
        var selectedValue = sel.options[sel.selectedIndex].text;
        component.set("v.Title", selectedValue);
        component.set("v.flagTitle", false);
    },
    
    userTypeHadler: function(component, event, helper) {
        
        
        var sel = document.getElementById("selectIam");
        var selectedValue = sel.options[sel.selectedIndex].text;
        //alert("user type selected => " + selectedValue);
        var orguser = component.get("v.OrgUser");
        var finalvalue;
        let Childcomp = component.find("compB");
        if (selectedValue == "Tenant") {
            component.set("v.userType", selectedValue);
            component.set("v.flagRegAsOrg", false);
            component.set("v.tenantmobcheck", true);
            component.set("v.teleNumber", "Mobile Number");
            component.set("v.teleNumberPlaceholder", "Enter Mobile Number");
            component.set("v.Phone", '');
            
            Childcomp.mandatoryMethod(false);
        } else {
            if (selectedValue == "joint Landlord") {
                finalvalue = true;
            } else {
                finalvalue = false;
                if (selectedValue == "Agent" && orguser) {
                    component.set("v.HeadOfficeUser", true);
                } else {
                    component.set("v.HeadOfficeUser", false);
                }
            }
            component.set("v.userType", selectedValue);
            component.set("v.isModalOpenJointLandlord", finalvalue);
            component.set("v.aggrement", finalvalue);
            component.set("v.flagUserType", false);
            component.set("v.flagRegAsOrg", true);
            component.set("v.tenantmobcheck", false);
            component.set("v.teleNumber", "Telephone number");
            component.set("v.teleNumberPlaceholder", "Enter telephone number");

            Childcomp.mandatoryMethod(true);
        }
    },
    
    OrgUsers: function(component, event, helper) {
        //var selectedValue = event.getSource().get("v.checked");
        var selectedValue = document.getElementById("gridCheck1");
        var userType = component.get("v.userType");
        if (selectedValue.checked) {
            component.set("v.OrgUser", true);
            if (userType == "Agent") {
                component.set("v.HeadOfficeUser", true);
            } else {
                component.set("v.HeadOfficeUser", false);
            }
        } else {
            component.set("v.HeadOfficeUser", false);
            component.set("v.OrgUser", false);
        }
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
                
            case "phonelength":
                component.set("v.phonelengthError", false);
                break;
            case "telePhone":
                component.set("v.telePhoneError", false);
                break;
            case "mobileFormatError":
                component.set("v.mobileFormatError", false);
                break;
            case "selectIam":
                component.set("v.selectIamerrorMessage", false);
                break;
            case "title":
                component.set("v.titleErrorMessage",false);
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
            case "mobileNumber":
                component.set("v.mobileError", false);
                break;
            case "address":
                component.set("v.addressError", false);
                break;
            case "phoneNotValid":
                component.set("v.MessagePhone", false);
                break;
            case "companyName":
                component.set("v.companyNameError", false);
                break;
            case "companyEmail":
                component.set("v.companyEmailError", false);
                break;
            case "companyPhonelength":
                component.set("v.companyPhonelengthError", false);
                break;
            case "companyPhone":
                component.set("v.companyPhoneError", false);
                break;
            case "tradingname":
                component.set("v.tradingnameerror", false);
                break;
            case "companyregnumber":
                component.set("v.companyregnumbererror", false);
                break;
            case "DRMEmail":
                component.set("v.DRMEmailError", false);
                break;
            case "FinanceEmail":
                component.set("v.FinanceEmailError", false);
                break;
            case "LettingAgentNumber":
                component.set("v.LettingAgentNumberError", false);
                break;
            case "companyEmailMessage":
                component.set("v.companyEmailMessageError", false);
                break;
            case "DrmEmailMessage":
                component.set("v.companyDrmEmailMessageError", false);
                break;
            case "FinanceEmailMessage":
                component.set("v.companyFinanceEmailMessageError", false);
                break;
            case "emailMessage":
                component.set("v.emailMessageError", false);
                break;
        }
    },
    
    clickCreate: function(component, event, helper) {
     //   debugger;
        let userTyp = component.get("v.userType");
        var telephone = component.get("v.TelePhone");
        let salutation = component.get("v.Title");
        var inputCmp = component.find("UserTypeID");
        var firstName = component.get("v.firstName");
        var lastName = component.get("v.lastName");
        var phoneCode = component.get("v.phoneCode");
        var phone = component.get("v.Phone");
        var email = component.get("v.Email");
        var companyName= component.get("v.companyName");
        var companyPhoneCode = component.get("v.companyPhoneCode");
        var companyPhone= component.get("v.companyPhone");
        var companyregistration= component.get("v.companyregistration");
        var tradingname= component.get("v.tradingname");
        var companyAddress= component.get("v.companyAddress");
        var companyEmail=component.get("v.companyEmail");
        var companyDrmEmail= component.get("v.companyDrmEmail");
        var companyletAgntId= component.get("v.letAgntId");
        var companyFinanceEmail= component.get("v.companyFinanceEmail");
        var orguser	= component.get("v.OrgUser");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let validateextrafields = true;
        var isValid = true;
        var title = component.get("v.Title"); 

        if (!userTyp || userTyp=='-- Please select ---') {  
            component.set("v.selectIamerrorMessage",true);    
            isValid = false;
        }
        else{
            component.set("v.selectIamerrorMessage",false);
        }
        if (!salutation || salutation=='-- Please select ---') {  
            component.set("v.titleErrorMessage",true);    
            isValid = false;
        }
        else{
            component.set("v.titleErrorMessage",false);
        }
        if (!firstName) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.firstNameError",false);
        }
        if (!lastName) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
        else{
            component.set("v.surNameError",false);
        }
        if (!email) {
            component.set("v.emailError",true);    
            isValid = false;
        }
        else{
            component.set("v.emailError",false);
        }		
        
        if (!phone) {
           component.set("v.phonelengthError",true);   
            isValid = false;
        }
        else{
            //alert("phoneCode ==> " + phoneCode);
            if(phoneCode == '+44'){
                if (phone.length != 11 || !phone.startsWith("07")) {
                    console.log('less');
                    isValid = false;
                    component.set("v.phonelengthError",true);    
                }else{
                    component.set("v.MessagePhone",false);
                    component.set("v.phonelengthError",false);
                }      
            }else{
                component.set("v.MessagePhone",false);
                component.set("v.phonelengthError",false);
            }  
        }   
        
        helper.PassVariable(component, event, helper);
        var street = component.get("v.Street");
        var city = component.get("v.Town");
        var postcode = component.get("v.PostCode");
        var country = component.get("v.Country");
        var county = component.get("v.County");
        
        var objChild = component.find("compB");
        if ( (userTyp != 'Tenant') &&
            (objChild.get("v.PostCode") == "" ||
             typeof objChild.get("v.PostCode") == "undefined" ||
             objChild.get("v.AddressLine1") == "" ||
             typeof objChild.get("v.AddressLine1") == "undefined" ||
             objChild.get("v.Town") == "" ||
             typeof objChild.get("v.Town") == "undefined" ||
             objChild.get("v.Country") == "" ||
             typeof objChild.get("v.Country") == "undefined")
           ){
            
            component.set("v.addressError",true);  
            isValid = false;
            console.log('valid 238 '+isValid);
        }
        else{
            console.log('valid 244 '+isValid);
            component.set("v.addressError",false);
        }   
        
        if(email != undefined && email != "" && email != null){
            if(!email.match(regExpEmailformat)){
                component.set("v.emailMessageError",true);
                isValid = false;
            }
        }
        if ((userTyp != undefined && userTyp != "" && userTyp != null && userTyp!='-- Please select ---') && userTyp == "Agent" && orguser) {
            if (companyName == undefined || companyName == "" || companyName == null) {
                component.set("v.companyNameError",true);    
                isValid = false;
            }
            else{
                component.set("v.companyNameError",false);
            }
            if (companyEmail == undefined || companyEmail == "" || companyEmail == null) {
                component.set("v.companyEmailError",true);    
                isValid = false;
            }
            else{
                component.set("v.companyEmailError",false);
            }
            if (companyPhone == undefined || companyPhone == "" || companyPhone == null) {
                component.set("v.companyPhoneError",true);    
                isValid = false;
            }
            else if (companyPhoneCode == "+44" && (companyPhone.length != 11 || !companyPhone.startsWith("07"))) {   
                component.set("v.companyPhonelengthError",true);   
                isValid = false;
            }else{
                component.set("v.companyPhoneError",false);
                component.set("v.companyPhonelengthError",false);   
            }
            if (companyDrmEmail == undefined || companyDrmEmail == "" || companyDrmEmail == null) {
                component.set("v.DRMEmailError",true);    
                isValid = false;
            }
            else{
                component.set("v.DRMEmailError",false);
            }
            if (companyFinanceEmail == undefined || companyFinanceEmail == "" || companyFinanceEmail == null) {
                component.set("v.FinanceEmailError",true);    
                isValid = false;
            }
            else{
                component.set("v.FinanceEmailError",false);
            }
            if (companyletAgntId == undefined || companyletAgntId == "" || companyletAgntId == null) {
                component.set("v.LettingAgentNumberError",true);    
                isValid = false;
            }
            else{
                component.set("v.LettingAgentNumberError",false);
            }
            if(companyEmail != undefined && companyEmail != "" && companyEmail != null && !companyEmail.match(regExpEmailformat)){
                component.set("v.companyEmailMessageError",true);
                isValid = false;
            }
            if(companyDrmEmail != undefined && companyDrmEmail != "" && companyDrmEmail != null && !companyDrmEmail.match(regExpEmailformat)){
                component.set("v.companyDrmEmailMessageError",true);
                isValid = false;
            }
            if(companyFinanceEmail != undefined && companyFinanceEmail != "" && companyFinanceEmail != null && !companyFinanceEmail.match(regExpEmailformat)){
                component.set("v.companyFinanceEmailMessageError",true);
                isValid = false;
            }
        }
        console.log('valid 351 '+isValid);
        if ((userTyp != undefined && userTyp != "" && userTyp != null && userTyp!='-- Please select ---') && userTyp == "Landlord" && orguser) {
            if (companyName == undefined || companyName == "" || companyName == null) {
                component.set("v.companyNameError",true);    
                isValid = false;
            }
            else{
                component.set("v.companyNameError",false);
            }
            
            if (companyPhone == undefined || companyPhone == "" || companyPhone == null) {
                component.set("v.companyPhoneError",true);    
                isValid = false;
            }
            else if (companyPhoneCode == "+44" && (companyPhone.length != 11 || !companyPhone.startsWith("07"))) {
                component.set("v.companyPhonelengthError",true);    
                isValid = false;
            }else{
                component.set("v.companyPhoneError",false);
                component.set("v.companyPhonelengthError",false);  
            }  
            
            if (companyregistration == undefined || companyregistration == "" || companyregistration == null) {
                component.set("v.companyregnumbererror",true);    
                isValid = false;
            }
            else{
                component.set("v.companyregnumbererror",false);
            }
            
            if (tradingname == undefined || tradingname == "" || tradingname == null) {
                component.set("v.tradingnameerror",true);    
                isValid = false;
            }
            else{
                component.set("v.tradingnameerror",false);
            }
        }
     console.log(userTyp+' valid 389 '+isValid);
        if ((userTyp != undefined && userTyp != "" && userTyp != null && userTyp!='-- Please select ---') && userTyp == "Tenant") {
            var letters = /^[0-9]+$/;
            // console.log(telephone+' ##telephone');
            if(telephone == undefined || telephone == "" || telephone == null){
                component.set("v.TelePhone", "");
                //isValid = true;
            }
            else {
                if (telephone.match(letters) == null) {  
                    console.log('valid 391 '+telephone);
                    isValid = false;
                    component.set("v.telePhoneError",true); 
                }else{
                    component.set("v.telePhoneError",false);   
                }
            }
            
            
            if (phone != null || typeof phone != "undefined") {
              //  alert(phoneCode);
                if(phoneCode == '+44' && (phone.length != 11 || !phone.startsWith("07") || (phone.match(letters) == null))){
                    isValid = false;
                    component.set("v.phonelengthError",true);
                }
               
                    else{
                        component.set("v.MessagePhone",false);
                         component.set("v.phonelengthError",false);
                    }
                
            }
        }
             console.log('valid 419 '+isValid);
        if(isValid){
            console.log('isValid 420 '+isValid);
            var allValid = component
            				.find("fieldId")
            				.reduce(function(validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get("v.validity").valid;
            }, true);
            if (userTyp == "Tenant") {
                let validatePhone = true;
                let phone = component.get("v.Phone");
                if (phone != null || typeof phone != "undefined") {
                    
                    if(phoneCode == '+44' && (phone.length != 11 || !phone.startsWith("07"))){
                        validatePhone = false;
                    }
                    else{
                        validatePhone = true;
                    }
                }
                if (!validatePhone) {
                    component.set("v.phonelengthError", true);
                } else {
                    component.set("v.MessagePhone", false);
                     component.set("v.phonelengthError", false);
                }
                if (allValid && validateextrafields && validatePhone) {
                    $A.enqueueAction(component.get("c.submitDetails"));
                }
            }
            else{
                component.set("v.isModalOpen", true); 
            }
        }else{
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
            $('#maincon', window.parent.document).get(0).scrollIntoView();
        }
        
    },
    closeModel: function(component, event, helper) {
        document.getElementById("confirm").style.display = "none";
    },
    
    multiplebranches: function(component, event, helper) {
        var selectedValue = document.getElementById("gridCheck2");
        component.set("v.HeadoficeUsercheckbox", selectedValue.checked);
    },
    
    submitDetails: function(component, event, helper) {  
      //  debugger;
      //alert("user type => " + component.get("v.userType"));
        component.set("v.isModalOpen", false); 
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const draftId = urlParams.get('draftId');
        var action = component.get("c.selfRegister");
        
        var param = {
            salutation: component.get("v.Title"),
            firstname: component.get("v.firstName"),
            lastname: component.get("v.lastName"),
            email: component.get("v.Email"),
            Telephone: component.get("v.TelePhone"),
            phoneCode: component.get("v.phoneCode"),
            phone: component.get("v.Phone"),
            address: component.get("v.Address"),
            
            OrgUSer: component.get("v.OrgUser"),
            HoUser: component.get("v.HeadoficeUsercheckbox"),
            userType: component.get("v.userType"),
            
            companyName: component.get("v.companyName"),
            companyPhoneCode: component.get("v.companyPhoneCode"),
            companyPhone: component.get("v.companyPhone"),
            companyreg:component.get("v.companyregistration"),
            tradename:component.get("v.tradingname"),
            companyAddress: component.get("v.companyAddress"),
            
            companyEmail: component.get("v.companyEmail"),
            companyDrmEmail: component.get("v.companyDrmEmail"),
            companyFinanceEmail: component.get("v.companyFinanceEmail"),
            
            LAid: component.get("v.letAgntId"),
            street: component.get("v.Street"),
            city: component.get("v.Town"),
            postcode: component.get("v.PostCode"),
            country: component.get("v.Country"),
            county: component.get("v.County"),
            draftId:draftId
        };
        
        
     /*   if(helper.calledFromCertificateBuilder()){
            var startURL = helper.getUrlParams('startURL');
            param.draftId = helper.getDraftIdfromURL(startURL);
        }*/
        
        action.setParams(param);
        
        action.setCallback(this, function(a) {
            debugger;
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
               // alert('return val'+ JSON.stringify(a.getReturnValue()) );
                console.log('return val'+ JSON.stringify(a.getReturnValue()) );
                if (a.getReturnValue() == "User Create successfully") {
                    var toastEvent = $A.get("e.force:showToast");
                    console.log('user created');
                    if(component.get("v.userType") == 'Tenant'){
                        component.set("v.successfullCreateUser",false);
                        component.set("v.alreadyAccount",true);
                    }
                    
                } else {
                    if (a.getReturnValue() == "User already have an account") {
                        
                        setTimeout(function(){ 
                            var msgDiv =  document.getElementById("errorMsg");
                            console.log('msgDiv there'+msgDiv);
                            
                            $A.util.removeClass(msgDiv, "divMsg2");
                            $A.util.addClass(msgDiv, "divMsg");
                        }, 100);
                        
                        console.log('alreadyAccount '+component.get("v.alreadyAccount"));
                        component.set("v.successfullCreateUser",true);
                        component.set("v.alreadyAccount",false);
                        component.set("v.errorText","It looks like you already have an account with SafeDeposits Scotland. We have sent you an email that will allow you to access your account. Alternatively, please click ‘Login’ and enter your username and password.");
                    } else if (a.getReturnValue() == "Email is already registered") {
                        component.set("v.successfullCreateUser",true);
                        component.set("v.alreadyAccount",false);
                        component.set("v.errorText","This email is already registered in the system.");
                        
                    } else {
                        let errormessage = JSON.stringify(a.getReturnValue());
                        console.log('line 492' + errormessage);
                        if (errormessage.includes("<br>")) {
                            errormessage = errormessage.replaceAll("<br>", " ");
                        }              
                        component.set("v.successfullCreateUser",true);
                        component.set("v.alreadyAccount",false);
                        //component.set("v.errorText","We encountered a problem. For help,Please contact your administrator.");
                        component.set("v.errorText",'We have encountered a problem.For help,Please contact us on 03333213136 for further assistance.');
                    }
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.errorToast("Error message: " + errors[0].message);
                    }
                } else {
                    helper.errorToast("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    downloadDocument: function(component, event, helper) {
        window.location = "/apex/TermsAndConditionPdf";
    },
    
    parentPress: function(component, event, helper) {
        helper.PassVariable(component, event, helper);
        //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
    },
    
    ValidateEmail: function(component, event, helper) {
        var soucerec = event.getSource();
        var emailFieldValue = component.get("v.Email");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!$A.util.isEmpty(emailFieldValue)) {
            if (emailFieldValue.match(regExpEmailformat)) {
                component.set("v.vlidateEmail", true);
                soucerec.setCustomValidity("");
            } else {
                soucerec.setCustomValidity("Please enter a valid email");
                component.set("v.vlidateEmail", false);
            }
        }
    },
    ValidatePhone: function(component, event, helper) {
        var soucerec = event.getSource();
        var Phonenmbr = event.getSource().get("v.value");
        var regExpPhoneformat = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
        if (!$A.util.isEmpty(Phonenmbr)) {
            if (Phonenmbr.match(regExpPhoneformat)) {
                component.set("v.vlidateEmail", true);
                soucerec.setCustomValidity("");
            } else {
                soucerec.setCustomValidity("Please enter a valid Phone");
                component.set("v.vlidateEmail", false);
            }
        }
    },
    loadpdf: function(component, event, helper) {
        try {
            var pdfData = component.get("v.pdfData");
            var pdfjsframe = component.find("pdfFrame");
            if (typeof pdfData != "undefined") {
                pdfjsframe.getElement().contentWindow.postMessage(pdfData, "*");
            }
        } catch (e) {
           // alert("Error: " + e.message);
        }
    },
    
    handlePhoneCode: function(component, event, helper) {
        var phoneCode = document.getElementById("selectPhoneCode").value;
        component.set("v.phoneCode", phoneCode);
        component.set("v.Phone", '');
    },
    
    handleCompanyPhoneCode: function(component, event, helper) {
        var companyPhoneCode = document.getElementById("selectCompanyPhoneCode").value;
        component.set("v.companyPhoneCode", companyPhoneCode);
        component.set("v.companyPhone", '');
    },
    
});