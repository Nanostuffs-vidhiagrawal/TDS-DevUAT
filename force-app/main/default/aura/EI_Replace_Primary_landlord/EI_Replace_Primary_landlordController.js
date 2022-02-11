({
   doInit: function(component, event, helper) {
      
       // Get Country codes Picklist Values
       helper.fetchPhoneCodePicklist(component); 
       
       var actionReplace = component.get("c.landlordRegistrationallstatusReplace");
       
       actionReplace.setCallback(this, function (response) {
           var state = response.getState();
           
           // Handle Success
           if (state === "SUCCESS") 
           {
               var result = response.getReturnValue();
               console.log(result);
               console.log(JSON.stringify(result));
               var lanRegStatuses = [];
               for (var key in result) {
                   lanRegStatuses.push({ key: key, value: result[key] });
               }
               component.set("v.LandRegStatuses", lanRegStatuses);
               //       console.log(component.get("v.LandRegStatuses")+' @@--<<lanRegStatuses --->>> '+ lanRegStatuses);
           }
           // Handle Error
           else if (state === "ERROR") {
               var errors = response.getError();
               // If error then check error type
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       // If duplicate username fire toast message
                       
                       
                   }
               } else {
                   //   console.log("Unknown error");
               }
           }
       });
       $A.enqueueAction(actionReplace);  
   }, 
    
    regStatusChange : function (component, event, helper) {
         console.log('regStatusCheck 1');
        var regStatusCheck = document.getElementById("regStatusIdnew").value;
         console.log('regStatusCheck '+regStatusCheck);
        if(regStatusCheck!='' && regStatusCheck!=null && regStatusCheck!=undefined)
        {
            console.log('regStatusCheck');
            if(regStatusCheck == "Landlord is entered on the local authority register for the area where this property is located" || 
               regStatusCheck == "Landlord is appealing a decision to remove their entry from the local authority register")
            {
                component.set("v.isRegStatus",true);
            }
            else {
                
                component.set("v.isRegStatus",false);
            }
        }
        else
        {
            component.set("v.isRegStatus",false);
        }
    },
    
    OrgUsers: function (component, event, helper) {
            component.set("v.OrgUser", true);
        var ys =  component.find("landlordCompYes");
        var no =   component.find("landlordCompNo");
        
        $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");

    },
    noOrgUsers: function (component, event, helper) {
            component.set("v.companyName","");
            component.set("v.companyPhone", "");
            component.set("v.OrgUser", false);
        var ys =  component.find("landlordCompYes");
        var no =   component.find("landlordCompNo");
        
        $A.util.removeClass(ys, "clickButton");
        $A.util.addClass(no, "clickButton"); 
    },
    
    
    parentPress: function (component, event, helper) {
        helper.PassVariable(component, event, helper);
        //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
    },
    
    /*parentPress: function (component, event, helper) {
        
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
        
        //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
    },*/
    
    clickCreate: function (component, event, helper) 
    {
        
        var propertiId = component.get("v.propertyRecId");
        component.set("v.companyNameError",false);
        component.set("v.companyPhonelengthError", false);
        component.set("v.companyPhoneError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.telephoneNumError",false);
        component.set("v.phonelengthError",false);
        component.set("v.registrationNumError",false);
        let propertyId= component.get("v.propertyRecId");
        var isValid = true;
        
        var companyNamecheck = component.find("compNameId").get("v.value");
        var companyPhoneCode = component.get("v.companyPhoneCode");
        var companyPhonecheck = component.find("compPhoneId").get("v.value");
        var titleCheck = document.getElementById("titleId").value;
        var firstNameCheck = component.find("firstNameId").get("v.value");
        var surnameCheck = component.find("surNameId").get("v.value");
        var emailCheck = component.find("emailID").get("v.value");
        var phoneCode = component.get("v.phoneCode");
        var telephoneCheck = component.find("telephoneNumberId").get("v.value");
       // var regNumberCheck = component.find("regNumberId").get("v.value");
        var regNumberCheck = component.get("v.LandRegNumber");
        var regStatusCheck = document.getElementById("regStatusIdnew").value;
        
       
        //var act = component.get("v.act");
        if(component.get("v.OrgUser"))
        {
            if (companyNamecheck == undefined || companyNamecheck == "" || companyNamecheck == null ) {  
                component.set("v.companyNameError",true);    
                isValid = false;
                $('#replacell', window.parent.document).get(0).scrollIntoView();
            }
            if (companyPhonecheck == undefined || companyPhonecheck == "" || companyPhonecheck == null ) {  
                component.set("v.companyPhoneError",true);    
                isValid = false;
                $('#replacell', window.parent.document).get(0).scrollIntoView();
            }else{
                if (companyPhoneCode == "+44" && (companyPhonecheck.length != 11 || !companyPhonecheck.startsWith("07"))) {
                    component.set("v.companyPhonelengthError",true);    
                    isValid = false;
                }
            }
        }
        if (titleCheck == undefined || titleCheck == "" || titleCheck == null || titleCheck == "-- Please Select --") {  
            component.set("v.titleError",true);    
            isValid = false;
            $('#replacell', window.parent.document).get(0).scrollIntoView();
        }
        if (regStatusCheck == undefined || regStatusCheck == "" || regStatusCheck == null || regStatusCheck == "-- Please Select --") {  
            component.set("v.regstatuserror",true);    
            isValid = false;
            $('#replacell', window.parent.document).get(0).scrollIntoView();
        }
        else{
         component.set("v.regstatuserror",false);    
        }
        
        if(component.get("v.isRegStatus")){
            
            if(regNumberCheck == '' || regNumberCheck == undefined || regNumberCheck == null) {
             component.set("v.registernumbernullerror",true);    
             isValid = false; 
             $('#replacell', window.parent.document).get(0).scrollIntoView();	
            } 
            else{
            component.set("v.registernumbernullerror",false);     
            }
            
        }
        
        
        //console.log('Working1');
        if (firstNameCheck == undefined || firstNameCheck == "" || firstNameCheck == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
            $('#replacell', window.parent.document).get(0).scrollIntoView();
        }
        //console.log('Working2');
        if (surnameCheck == undefined || surnameCheck == "" || surnameCheck == null) {
            component.set("v.surNameError",true);    
            isValid = false;
            $('#replacell', window.parent.document).get(0).scrollIntoView();
        }
        //console.log('Working3');
        if (emailCheck == undefined || emailCheck == "" || emailCheck == null) {
            component.set("v.emailError",true);    
            isValid = false;
            $('#replacell', window.parent.document).get(0).scrollIntoView();
        }
        //console.log('Working4');
        if (telephoneCheck == undefined || telephoneCheck == "" || telephoneCheck == null) {
            component.set("v.telephoneNumError",true);    
            isValid = false;
            $('#replacell', window.parent.document).get(0).scrollIntoView();
        }
        else{
            if (phoneCode == "+44" && (telephoneCheck.length != 11 || !telephoneCheck.startsWith("07"))) {
                component.set("v.phonelengthError",true);    
                isValid = false;
            }
        }
        
        //////////////////////////////////////////////////////////////////////////////////////
        
        //let validateAddress = false;
        let propertyRecId = component.get("v.propertyRecId");
        let LandRegNumber = component.get("v.LandRegNumber");
        let validatelrn = true;
        console.log('validatelrn',validatelrn);
        
        if(LandRegNumber != '' && LandRegNumber != undefined && LandRegNumber != null)
        {
        	let lrnArray = component.get("v.LandRegNumber").split(',');
            for(let i =0;i <lrnArray.length ; i++ )
            {
            	if(lrnArray[i].length >= 14  && lrnArray[i].length <= 16 )
                {
                        
                	let innervaluearray =lrnArray[i].split('/');
                    if(innervaluearray.length == 3)
                    {
                    	if(!(innervaluearray[0].length == 5 || innervaluearray[0].length == 6))
                        {
                        	validatelrn = false;
                        }
                        if(innervaluearray[1].length != 3)
                        {
                        	validatelrn = false;
                        }
                        if(!(innervaluearray[2].length == 4 || innervaluearray[2].length == 5))
                        {
                        	validatelrn = false;
                        }
                    }
                    else
                    {
                    	validatelrn = false; 
                    }
                }
                else
                {
                	validatelrn = false;
                }
            }
            if(!validatelrn)
            {
            	//alert('Please enter the valid landlord registration number');
                component.set('v.registrationNumError',true);
                isValid = false;
                $('#replacell', window.parent.document).get(0).scrollIntoView();
            }
        }
        
        var objChild = component.find("compB");
        if (
            objChild.get("v.AddressLine1") == "" ||
            typeof objChild.get("v.AddressLine1") == "undefined" ||
            objChild.get("v.Town") == "" ||
            typeof objChild.get("v.Town") == "undefined" ||
        	objChild.get("v.PostCode") == "" ||
            typeof objChild.get("v.PostCode") == "undefined" ||
            objChild.get("v.Country") == "" ||
            typeof objChild.get("v.Country") == "undefined"
		)
        {
        	component.set("v.isAddressValidError",true);
            isValid = false;
            $('#replacell', window.parent.document).get(0).scrollIntoView();
            //alert("Please fill Address");
            //validateAddress = false;
        }
        else{
            
         component.set("v.isAddressValidError",false);   
        }
            /*else
            {
                validateAddress = true;
            }*/
        console.log('AddressLine1',objChild.get("v.AddressLine1"));
        console.log('Town',objChild.get("v.Town"));
        console.log('County',objChild.get("v.County"));
        console.log('PostCode',objChild.get("v.PostCode"));
        console.log('Country',objChild.get("v.Country"));
        console.log('isValid',isValid);
        
        if(isValid)
        {
            //('Landlord will be created successfully');
            console.log('Landlord will be created successfully');
            //alert('Stage 1');
            //alert(LandRegNumber);
            //alert(propertyRecId);
            
            var action = component.get("c.createlandlord");
                action.setParams({
                    firstname: component.get("v.firstName"),
                    lastname: component.get("v.lastName"),
                    email: component.get("v.Email"),
                    salutation: component.get("v.Title"),
                    phoneCode: component.get("v.phoneCode"),
                    phone: component.get("v.Phone"),
                    landlordlegistrationstatus:regStatusCheck,
                    LandlordRegistrationNumber :LandRegNumber,
                    companyName: component.get("v.companyName"),
                    companyPhoneCode: component.get("v.companyPhoneCode"),
                    companyPhone: component.get("v.companyPhone"),
                    isOrguser:  component.get("v.OrgUser"),
                    propertyRecId : propertyRecId,
                    depositId:component.get("v.depositId"),
                    street: objChild.get("v.AddressLine1"),
                    city: objChild.get("v.Town"),
                    postcode: objChild.get("v.PostCode"),
                    country: objChild.get("v.Country"),
                    county: objChild.get("v.County")
                    /* companyAddress: component.get("v.companyAddress"),
                    companyEmail: component.get("v.companyEmail"),
                    street: component.get("v.Street"),
                    city: component.get("v.Town"),
                    postcode: component.get("v.PostCode"),
                    country: component.get("v.Country"),
                    county: component.get("v.County"),*/
                });
                action.setCallback(this, function (a) {
                    var state = a.getState();
                    var errors = a.getError();
                    var responsevalue = a.getReturnValue();
                /*if (state == "SUCCESS") {
                        component.set("v.succeessmessage", true);
                      $('#replacell', window.parent.document).get(0).scrollIntoView();
                        $A.get('e.force:refreshView').fire();
                    }
                    else if (state === "ERROR") {
                        component.set("v.noprimarylandlorderror", true);  
                        $('#replacell', window.parent.document).get(0).scrollIntoView();
                         $A.get('e.force:refreshView').fire();
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            alert(321);
                            console.log("Unknown error");
                           // alert("11ERROR11");
                        }
                    }*/
                    if (state == "SUCCESS") {
                        var result = a.getReturnValue();
                        console.log("add landlord result=> " + JSON.stringify(result));
                        var duplicateValue = [];
                        for ( var key in result ) {
                            duplicateValue.push({val:result[key], key:key});
                        }
                        var key = duplicateValue[0].key;
                        var recValue = duplicateValue[0].val;
                        
                        if(key == "Duplicate Email"){
                            component.set("v.duplicateEmailError", true);	
                        }
                        else if(key == "Duplicate Name"){
                            component.set("v.duplicateNameError", true);
                            component.set("v.duplicateRecord", recValue);
                        }
                            else{
                                component.set("v.succeessmessage", true);
                                $('#replacell', window.parent.document).get(0).scrollIntoView();
                                $A.get('e.force:refreshView').fire();
                            }
                    }
                    else if (state === "ERROR") {
                        component.set("v.noprimarylandlorderror", true);  
                        $('#replacell', window.parent.document).get(0).scrollIntoView();
                        $A.get('e.force:refreshView').fire();
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            alert(321);
                            console.log("Unknown error");
                            // alert("11ERROR11");
                        }
                    }
                    else{
                        alert(328);    
                    }
                }); 
            $A.enqueueAction(action);
            
        }
    },
    
    clickCreate1 :function (component, event, helper) {
        var propertyId = component.get("v.propertyRecId");
        alert(propertyId);
        let OrgUser =component.get("v.OrgUser"); 
        let validinput =false;
        let allValid = component
        .find("fieldId")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);
               
        if(OrgUser == false)
        {
            if(allValid )
            {
                validinput = true;
            }
            
        }
        else
        {
            let CompallValid = component
            .find("CompfieldId2")
            .reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get("v.validity").valid;
            }, true);
            
            if(allValid && CompallValid )
            {
                validinput = true;
            }
            
        }
        if(validinput)
        {
           //var myLabel = component.find("button1").get("v.label");
           alert(component.get("v.landlordlegistrationstatus"));
           var action = component.get("c.createlandlord");
            
            action.setParams({
                salutation: component.get("v.Title"),
                firstname: component.get("v.firstName"),
                lastname: component.get("v.lastName"),
                email: component.get("v.Email"),
                phone: component.get("v.Phone"),
              // landlordlegistrationstatus:component.find("lrdid").get("v.value"),
              //  LandlordRegistrationNumber : component.get("v.LandlordRegistrationNumber"),
                isOrguser: OrgUser,
                companyName: component.get("v.companyName"),
                companyPhone: component.get("v.companyPhone"),
                companyAddress: component.get("v.companyAddress"),
                companyEmail: component.get("v.companyEmail"),
                Property:component.get("v.propertyid"),
                
                    street: component.get("v.Street"),
                    city: component.get("v.Town"),
                    postcode: component.get("v.PostCode"),
                    country: component.get("v.Country"),
                    county: component.get("v.County") 
                });
            action.setCallback(this, function (a) {
                var state = a.getState();
                var errors = a.getError();
                alert(state);
                alert(errors);
                var responsevalue = a.getReturnValue();
                 alert(responsevalue);
                if (state == "SUCCESS") {
                    if(responsevalue){
                        component.set("v.succeessmessage", true);}
                        else{
                         component.set("v.noprimarylandlorderror", true);    
                        }
                    //alert(' landlord has been created successfully');
                       // var toastEvent = $A.get("e.force:showToast");
                      //  toastEvent.setParams({
                        //    "title": "Success!",
                       //     "message": "landlord has been created successfully."
                       // });
                      //  toastEvent.fire();
                    //component.find("overlayLib").notifyClose();
                } 
            });
            
            $A.enqueueAction(action);
        }
        
        
    },
    
    hideBootstrapErrors: function(component, event, helper) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "companyName":
                component.set("v.companyNameError", false);
                break;
            case "companyPhonelength":
                component.set("v.companyPhonelengthError", false);
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
            case "emailOfUser":
                component.set("v.emailError", false);
                break;
            case "telephoneNumber":
                component.set("v.telephoneNumError", false);
                break;
            case "phonelength":
                component.set("v.phonelengthError", false);
                break;
                 case "regstatuscheck":
                component.set("v.regstatuserror",false); 
                break;
            case "registrationNumber":
                component.set("v.registrationNumError", false);
                break;
            case "registrationNumbernullcheck":
                component.set("v.registernumbernullerror", false);
                break;
                
            case "validAddress":
                component.set("v.isAddressValidError", false);
                break;
            case "successmsg":
                component.set("v.succeessmessage", false);
                break;
             case "noprimarylandlord":
                component.set("v.noprimarylandlorderror", false);
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
    
      
    resetstate:function(component, event, helper){
                component.set("v.companyNameError", false);
        component.set("v.companyPhonelengthError", false);
                component.set("v.companyPhoneError", false);
                component.set("v.titleError", false);
                component.set("v.firstNameError", false);
                component.set("v.surNameError", false);
                component.set("v.emailError", false);
                component.set("v.regstatuserror",false); 
                component.set("v.telephoneNumError", false);
        component.set("v.phonelengthError", false);
                component.set("v.registrationNumError", false);
                component.set("v.isAddressValidError", false);
                component.set("v.succeessmessage", false);
        component.set("v.duplicateEmailError", false);
                component.set("v.noprimarylandlorderror", false);
               document.getElementById("myformfree").reset();
    },
    
    handlePhoneCode: function(component, event, helper) {
        var phoneCode = document.getElementById("selectPhoneCodeLL").value;
        component.set("v.phoneCode", phoneCode);
        component.set("v.Phone", '');
    },
    
    handleCompanyPhoneCode: function(component, event, helper){
        var compPhoneCode = document.getElementById("selectCompanyPhoneCode").value;
        component.set("v.companyPhoneCode", compPhoneCode);
        component.set("v.companyPhone", '');
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
    
});