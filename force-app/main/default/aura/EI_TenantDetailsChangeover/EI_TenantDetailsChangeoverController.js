({
    doInit: function (component, event, helper) {
        console.log(JSON.stringify(component.get("v.arrObj")));
        var item = component.get("v.item");
        var arrObj = component.get("v.arrObj");
        //alert(arrObj.length);
        if (arrObj.length > 0) {
            for (var i = 1; i <= arrObj.length; i++)
                component.set("v.title", arrObj[item - 1].title);
            component.set("v.FirstName", arrObj[item - 1].firstName);
            component.set("v.SurName", arrObj[item - 1].SurName);
            component.set("v.email", arrObj[item - 1].email);
            component.set("v.phone", arrObj[item - 1].phone);
            component.set("v.phone", arrObj[item - 1].phone);
        }
        
        // Get Country codes Picklist Values
        helper.fetchPhoneCodePicklist(component); 
    },

    doEnableOrg: function (component, event, helper) {
       // component.find("personBtn").set("v.variant", "brand-outline");
       // component.find("orgBtn").set("v.variant", "brand");
        var ys =  component.find("orgBtn");
        var no =   component.find("personBtn");
        
        $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
        component.set("v.IsOrg", true);
      //  component.set("v.FirstName", "");
      //  component.set("v.SurName", "");
        //component.set("v.email", "");
        //component.set("v.phone", "");
       // component.set("v.phoneCode", "+44");
        component.set("v.title", "");
    },
    
    doPerson: function (component, event, helper) {
        //component.find("personBtn").set("v.variant", "brand");
       // component.find("orgBtn").set("v.variant", "brand-outline");
        var ys =  component.find("orgBtn");
        var no =   component.find("personBtn");
        
        $A.util.addClass(no, "clickButton");
        $A.util.removeClass(ys, "clickButton");
        component.set("v.IsOrg", false);
        component.set("v.companyName", "");
        //component.set("v.email", "");
        //component.set("v.phone", "");
    },
    
    onChangeTitle: function (component, event, helper) {
        var title = document.getElementById("titleId").value;
        component.set("v.title",title);
        //alert(title);
    },
    
    handleEmailBlur: function (component, event, helper) {
        let email = component.get("v.email");
         helper.checkEmailDuplicacy(component, email);
    },
    
    handlePhoneBlur: function (component, event, helper) {
        let phone = component.get("v.phone");
        helper.checkPhoneDuplicacy(component, phone);
    },
    
    doSubmit: function (component, event, helper) {
        var emailCheck = component.find("emailID").get("v.value");
        var email = emailCheck;
        var isDuplicateEmail = component.get("v.duplicateEmailError");
        
        var isValid = true;
        var IsDuplicateEmail = true;
        component.set("v.yesNoError", false);
        component.set("v.companyNameError",false);  
        component.set("v.emailMobileError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.invalidEmailFormatError",false);
        component.set("v.invalidPhoneFormatError",false);
        component.set("v.duplicateEmailInDepositError",false);
        component.set("v.PhonelengthError",false);    
        component.set("v.duplicatePhoneInDepositError",false);
        
         if(component.get("v.IsOrg") == undefined ){
			 console.log('139');
              component.set("v.yesNoError", true);
              isValid = false;
             
        }
        else if(component.get("v.IsOrg"))
        {
            component.set("v.yesNoError", false);
            var companyNamecheck = component.find("compNameId").get("v.value");
            var emailCheck = component.find("emailID").get("v.value");
            var email = emailCheck;
            var phoneCode = document.getElementById("selectPhoneCode").value;
        	var mobileCheck = component.find("mobileId").get("v.value");
            var isValidEmailFormat = false;
            var isValidPhoneFormat = false;
            //var leadRec = component.get("v.leadTenantObj");
            var tenantRec= component.get("v.arrObj");

            if (companyNamecheck == undefined || companyNamecheck == "" || companyNamecheck == null) {
                component.set("v.companyNameError",true);    
                isValid = false;

            }
            if ((emailCheck == undefined || emailCheck == "" || emailCheck == null) && 
                (mobileCheck == undefined || mobileCheck == "" || mobileCheck == null)) {
                component.set("v.emailMobileError",true);    
                isValid = false;

            }
            else
            {
                if(emailCheck)
                {
                    
                    isValidEmailFormat = helper.emailFormatChecker(component, email);
                    console.log("isValidEmailFormat",isValidEmailFormat);
                    if(!isValidEmailFormat)
                    {
                        console.log("Line 129");
                        isValid = false;
                        
                        component.set("v.invalidEmailFormatError",true);
                    }
                    else
                    {
                        console.log("Line 136");
                        
                        /* var emailChecker = helper.checkEmailInSystem(component, email);
                        
                        console.log("emailChecker 136 ",emailChecker);
                        if(emailChecker){
                            isValid = false;
                            component.set("v.duplicateEmailError",true);
                        }*/
                        
                        
                        IsDuplicateEmail = component.get("v.IsDuplicateEmail");
                        
                        if(IsDuplicateEmail) {
                            
                            isValid = false;
                            
                            component.set("v.duplicateEmailError",true);
                        }
                        //Arrobject duplicates
                        // let leadRec = component.get("v.leadTenantObj");
                        // let tenantRec= component.get("v.arrObj");
                        //console.log("tenantRec 147",tenantRec);
                        /*if(leadRec != null)
                        {
                            if(component.get("v.email") && component.get("v.email") != null ){
                                console.log('Line 118');
                                if(leadRec.email == component.get("v.email") )
                                {
                                    isValid = false;
                                    component.set("v.duplicateEmailInDepositError",true);
                                    //alert("This email Id is already used for other tenant");
                                }
                            }
                            
                        }*/
                        
                        for(let k=0; k<tenantRec.length ;k++ )
                        {
                            if(component.get("v.email") && component.get("v.email") != null){
                                if(tenantRec[k].email ==component.get("v.email"))
                                {
                                    //validatearr = false;
                                    component.set("v.duplicateEmailInDepositError",true);
                                    isValid = false;
                                    // alert("This email Id is already used for other tenant in this deposit");
                                    break;
                                }
                            }
                        }
                    }
                }
                if(mobileCheck)
                {
                    isValidPhoneFormat = helper.phoneFormatChecker(component, phoneCode, mobileCheck);
                    
                    if(!isValidPhoneFormat)
                    {
                        if(phoneCode == "+44"){
                             isValid = false;
                             component.set("v.PhonelengthError",true);
                         }else{
                             isValid = false;
                             component.set("v.invalidPhoneFormatError",true);
                         }
                    }else{
                        /*if(leadRec != null)
                        {
                            if(component.get("v.phone").length>0){
                                if(leadRec.phone == component.get("v.phone") )
                                {
                                    isValid = false;
                                    component.set("v.duplicatePhoneInDepositError",true);
                                    //alert("This Phone is already used for other tenant");
                                }
                            }
                            
                        }*/
                        
                        for(let k=0; k<tenantRec.length ;k++ )
                        {
                            if(component.get("v.phone").length>0){
                                if(tenantRec[k].phone ==component.get("v.phone"))
                                {
                                    isValid = false;
                                    component.set("v.duplicatePhoneInDepositError",true);
                                    //alert("This Phone is already used for other tenant");
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            
        }
        else
        {
            var titleCheck = component.get("v.title");
            //var titleCheck = component.find("titleId").get("v.value");
            var firstNameCheck = component.find("firstNameId").get("v.value");
            var surnameCheck = component.find("surNameId").get("v.value");
            //var emailCheck = component.find("emailID").get("v.value");
            var phoneCode = document.getElementById("selectPhoneCode").value;
        	var mobileCheck = component.find("mobileId").get("v.value");
            
            var email = emailCheck;
            var emailChecker = helper.checkEmailInSystem(component, email);
            
            var isValidEmailFormat = false;
            var isValidPhoneFormat = false;
            
            //let leadRec = component.get("v.leadTenantObj");
            let tenantRec= component.get("v.arrObj");
            
			//alert("checkEmailInSystem",emailChecker);
            if (titleCheck == undefined || titleCheck == "" || titleCheck == null || titleCheck == "-- Please Select --") {
                component.set("v.titleError",true);    
                isValid = false;
            }
           // console.log('Working1');
            if (firstNameCheck == undefined || firstNameCheck == "" || firstNameCheck == null) {
                component.set("v.firstNameError",true);    
                isValid = false;
            }
           // console.log('Working2');
            if (surnameCheck == undefined || surnameCheck == "" || surnameCheck == null) {
                component.set("v.surNameError",true);    
                isValid = false;
            }
         //   console.log('Working3');
            if ((emailCheck == undefined || emailCheck == "" || emailCheck == null) && 
                (mobileCheck == undefined || mobileCheck == "" || mobileCheck == null)) {
                component.set("v.emailMobileError",true);    
                isValid = false;
            }else{
                if(emailCheck)
                {
                    isValidEmailFormat = helper.emailFormatChecker(component, email);
					console.log("isValidEmailFormat",isValidEmailFormat);
                    if(!isValidEmailFormat)
                    {
                 		console.log("Line 272");
                        isValid = false;

                        component.set("v.invalidEmailFormatError",true);
                    }
                    else
                    {
                        console.log("Line 136");
                        
						/* var emailChecker = helper.checkEmailInSystem(component, email);
                        
                        console.log("emailChecker 136 ",emailChecker);
                        if(emailChecker){
                            isValid = false;
                            component.set("v.duplicateEmailError",true);
                        }*/
                        
                        
                       IsDuplicateEmail = component.get("v.IsDuplicateEmail");
                        
                        if(IsDuplicateEmail) {
            
                           isValid = false;
                           
                            component.set("v.duplicateEmailError",true);
                        }
                        //Arrobject duplicates
                        	// let leadRec = component.get("v.leadTenantObj");
                           // let tenantRec= component.get("v.arrObj");
                        	//console.log("tenantRec 147",tenantRec);
                        /*if(leadRec != null)
                        {
                            if(component.get("v.email") && component.get("v.email") != null ){
                                console.log('Line 118');
                                if(leadRec.email == component.get("v.email") )
                                {
                                    isValid = false;
                                    component.set("v.duplicateEmailInDepositError",true);
                                    //alert("This email Id is already used for other tenant");
                                }
                            }
                          
                        } */
                        
                        for(let k=0; k<tenantRec.length ;k++ )
                        {
                            if(component.get("v.email") && component.get("v.email") != null){
                                if(tenantRec[k].email ==component.get("v.email"))
                                {
                                    //validatearr = false;
                                    component.set("v.duplicateEmailInDepositError",true);
                                    isValid = false;
                                    // alert("This email Id is already used for other tenant in this deposit");
                                    break;
                                }
                            }
                        }
                        console.log("161 isValid",isValid);
                            
 
                    }
                }
               if(mobileCheck)
                {
                    isValidPhoneFormat = helper.phoneFormatChecker(component, phoneCode, mobileCheck);

                    if(!isValidPhoneFormat)
                    {
                        if(phoneCode == "+44"){
                            isValid = false;
                            component.set("v.PhonelengthError",true);
                        }else{
                            isValid = false;
                            component.set("v.invalidPhoneFormatError",true);
                        }
                    }
                    else{
                        /*if(leadRec != null)
                        {
                            if(component.get("v.phone").length>0){
                                
                                if(leadRec.phone == component.get("v.phone") )
                                {
                                    isValid = false;
                                    component.set("v.duplicatePhoneInDepositError",true);
                                    //alert("This Phone is already used for other tenant");
                                }
                            }
                        }*/
                        for(let k=0; k<tenantRec.length ;k++ )
                        {
                            if(component.get("v.phone").length>0){
                                if(tenantRec[k].phone ==component.get("v.phone"))
                                {
                                    isValid = false;
                                    component.set("v.duplicatePhoneInDepositError",true);
                                    //alert("This Phone is already used for other tenant");
                                    break;
                                }
                            }
                        }
                    }
                    
                }
            }
             
          
        }

        var companyName = component.get("v.companyName");
		console.log("334");
        if (companyName) {
            if(isValid) {
                //alert('isValid Org');
                var person = new Object();
                person.email = component.get("v.email");
                person.phoneCode = component.get("v.phoneCode");
                person.phone = component.get("v.phone");
                person.companyName = component.get("v.companyName");
                person.LeadSummary = component.get("v.LeadSummary");
                person.IsOrg = component.get("v.IsOrg");
                person.item = component.get("v.item");
                person.IsformSubmitted = true;
                
                //   Disable button and the class
                //component.find("doSubmit").set("v.disabled", true);
                
                console.log(" Line 358");
                // Fire the Event
                var EI_Tenantchangeoverdetails = component.getEvent("EI_Tenantchangeoverdetails");
                EI_Tenantchangeoverdetails.setParams({
                    arrObj: person
                });
                EI_Tenantchangeoverdetails.fire();
                /*var EI_tenantDetailEvent = component.getEvent("EI_tenantDetailEvent");
                EI_tenantDetailEvent.setParams({
                    arrObj: person
                });
                EI_tenantDetailEvent.fire();*/
                console.log('Line 372 event fired');
                console.log(" Line 355 person : ",person);
                //   Disable button and the class
                var cmpTarget = component.find("changeIt");
                $A.util.addClass(cmpTarget, "changeMe");
            }
        } 
        else {
            //var leadRec = component.get("v.leadTenantObj");
            var tenantRec= component.get("v.arrObj");
            var inputCmp = component.find("emailfield");
            var validateEmail  = true;
            var validatePhone  = true;
            var validatearr = true;
            var validatePhonearr = true;
            
            /*if(leadRec != null)
            {
                
                if(component.get("v.email") && component.get("v.email") != null ){
                    console.log('Line 118');
                    if(leadRec.email == component.get("v.email") )
                    {
                        validateEmail = false;
                        component.set("v.duplicateEmailInDepositError",true);
                        //alert("This email Id is already used for other tenant");
                    }
                }
                
                if(component.get("v.phone").length>0){
                    
                    if(leadRec.phone == component.get("v.phone") )
                    {
                        validatePhone = false;
                        component.set("v.duplicatePhoneInDepositError",true);
                        //alert("This Phone is already used for other tenant");
                    }
                }
            } */
            
            for(let k=0; k<tenantRec.length ;k++ )
            {
                if(component.get("v.email") && component.get("v.email") != null) {
                    if(tenantRec[k].email ==component.get("v.email"))
                    {
                        validatearr = false;
                        component.set("v.duplicateEmailInDepositError",true);
                        //alert("This email Id is already used for other tenant");
                        break;
                    }
                }
                if(component.get("v.phone").length>0) {
                    if(tenantRec[k].phone ==component.get("v.phone"))
                    {
                        validatePhonearr = false;
                        component.set("v.duplicatePhoneInDepositError",true);
                        //alert("This Phone is already used for other tenant");
                        break;
                    }
                }
            }
            console.log('isValid',isValid);
            console.log('validatearr',validatearr);
            console.log('validateEmail',validateEmail);
            console.log('validatePhone',validatePhone);
            console.log('validatePhonearr',validatePhonearr);
            
            //   If fields are populated correctly
            if (isValid && validatearr && validateEmail &&  validatePhone && validatePhonearr) {
                //   Pass all attributes values as Object to parent with the component Event
                var person = new Object();
                person.firstName = component.get("v.FirstName");
                person.SurName = component.get("v.SurName");
                person.email = component.get("v.email");
                person.phoneCode = component.get("v.phoneCode");
                person.phone = component.get("v.phone");
                person.title = component.get("v.title");
                person.companyName = component.get("v.companyName");
                person.LeadSummary = component.get("v.LeadSummary");
                person.IsOrg = component.get("v.IsOrg");
                person.item = component.get("v.item");
                person.IsformSubmitted = true;
                
                console.log(`person -> ${JSON.stringify(person)}`);
                //   Disable button and the class
                
                var cmpTarget = component.find("changeIt");
                $A.util.addClass(cmpTarget, "changeMe");
            	console.log('Line 445');
                
                // Fire the Event
                var EI_Tenantchangeoverdetails = component.getEvent("EI_Tenantchangeoverdetails");
                EI_Tenantchangeoverdetails.setParams({
                    arrObj: person
                });
                EI_Tenantchangeoverdetails.fire();
                console.log('Line 466 event fired');
            }
            // Is fields are not populated correctly give warning
            else {
                if(validatearr && validateEmail)
                {
                    //alert("Please update the invalid form entries and try again.");
                }
            }
        }
    },
    
    doSubmit11: function (component, event, helper) {
        var companyName = component.get("v.companyName");
        if (companyName) {
            var person = new Object();
            person.email = component.get("v.email");
            person.phone = component.get("v.phone");
            person.companyName = component.get("v.companyName");
            person.LeadSummary = component.get("v.LeadSummary");
            person.IsOrg = component.get("v.IsOrg");
            //   Disable button and the class
            component.find("doSubmit").set("v.disabled", true);
            var cmpTarget = component.find("changeIt");
            $A.util.addClass(cmpTarget, "changeMe");
            
            // Fire the Event
            var EI_tenantDetailEvent = component.getEvent("EI_tenantDetailEvent");
            EI_tenantDetailEvent.setParams({
                arrObj: person
            });
            EI_tenantDetailEvent.fire();
        } else {
            //   Check Input Validity
            var fields = component.find("field");
            // console.log("typeof fields:", typeof fields);
            var phonefield = component.find("phonefield");
            var emailfield = component.find("emailfield");
            fields.push(phonefield);
            fields.push(emailfield);
            var allValid = fields.reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            let leadRec = component.get("v.leadTenantObj");
            let tenantRec= component.get("v.arrObj");
            var inputCmp = component.find("emailfield");
            let validateEmail  = true;
            if(leadRec != null)
            {
                if(leadRec.email == component.get("v.email") )
                {
                    validateEmail = false;
                    alert("This email Id is already used for other tenant");
                }
                
            }
            let validatearr = true;
            
            for(let k=0; k<tenantRec.length ;k++ )
            {
                if(tenantRec[k].email ==component.get("v.email"))
                {
                    validatearr = false;
                    alert("This email Id is already used for other tenant");
                }
            }
            
            
            //   If fields are populated correctly
            if (allValid && validatearr && validateEmail) {
                //   Pass all attributes values as Object to parent with the component Event
                var person = new Object();
                person.firstName = component.get("v.FirstName");
                person.SurName = component.get("v.SurName");
                person.email = component.get("v.email");
                person.phone = component.get("v.phone");
                person.title = component.get("v.title");
                person.companyName = component.get("v.companyName");
                person.LeadSummary = component.get("v.LeadSummary");
                person.IsOrg = component.get("v.IsOrg");
                person.item = component.get("v.item");
                
                console.log('line-->174' + JSON.stringify(person));
                //   Disable button and the class
                component.find("doSubmit").set("v.disabled", true);
                var cmpTarget = component.find("changeIt");
                $A.util.addClass(cmpTarget, "changeMe");
                
                // Fire the Event
                
                var EI_tenantchangeoverdetailsEvent = component.getEvent("EI_Tenantchangeoverdetails");
                EI_tenantchangeoverdetailsEvent.setParams({
                    arrObj: person
                });
                EI_tenantchangeoverdetailsEvent.fire();
               component.set("v.disablefields", true);
            }
            
            // Is fields are not populated correctly give warning
            else {
                if(validatearr && validateEmail)
                {
                    alert("Please update the invalid form entries and try again.");
                }
                
            }
        }
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
                
             case "phonelength":
                component.set("v.PhonelengthError", false);
                break;
             case "yesNoMsg":
                component.set("v.yesNoError", false);
                break;
            case "companyName":
                component.set("v.companyNameError", false);
                break;
            case "companyEmail":
                component.set("v.companyEmailError", false);
                break;
            case "companyPhone":
                component.set("v.companyPhoneError", false);
                break;
            case "title":
                component.set("v.titleError", false);
                break;
            case "firstName":
                component.set("v.firstNameError", false);
                break;
            case "surName":
                component.set("v.surNameError", false);
                break;
            case "emailMobile":
                component.set("v.emailMobileError", false);
                break;
            case "invalidEmailFormat":
                component.set("v.invalidEmailFormatError", false);
                break;
            case "invalidPhoneFormat":
                component.set("v.invalidPhoneFormatError", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;   
            case "duplicateEmailError":
                component.set("v.duplicateEmailError", false);
                break;
            case "duplicateEmailInDepositError":
                component.set("v.duplicateEmailInDepositError", false);
                break;
            case "Phonelength":
                component.set("v.PhonelengthError",false);    
                break;
            case "duplicatePhoneInDepositError":
                component.set("v.duplicatePhoneInDepositError", false);
                break;    
                
        }
    },
                  
    handlePhoneCode: function(component, event, helper) {
        var code = document.getElementById("selectPhoneCode").value;
        component.set("v.phoneCode", code);
        component.set("v.phone", '');
    }

});