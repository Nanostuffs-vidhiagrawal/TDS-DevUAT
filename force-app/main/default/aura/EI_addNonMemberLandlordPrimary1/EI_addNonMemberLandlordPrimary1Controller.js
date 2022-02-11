({
    OrgUsers: function (component, event, helper) {
        
        //alert('In orgusers');
        var selectedValue = event.getSource().get("v.checked");
        if (selectedValue) {
            component.set("v.OrgUser", true);
        } else {
            component.set("v.OrgUser", false);
        }
    },
    
    parentPress: function (component, event, helper) {
        helper.PassVariable(component, event, helper);
        
    },
    addFormat: function (component, event, helper) {
        var LandRegNumber =component.get("v.LandRegNumber");
        var keycode;
        window.addEventListener("keydown", function(event) {
            var keycode=event.code;
            if(keycode != 'backspace')
            {
                if(LandRegNumber.length==5 || LandRegNumber.length==9 )
                {
                    LandRegNumber = LandRegNumber+'/';
                    component.set("v.LandRegNumber",LandRegNumber);
                }
            }
            
            
        }, true);
    },
    
    addNewRecord: function (component, event, helper) {
        
    },
    
    
    clickCreate1: function (component, event, helper) {
        let propertyRecId = component.get("v.propertyRecId");
        let LandRegNumber = component.get("v.LandRegNumber");
        var validatelrn = true;
        if(LandRegNumber != '')
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
                alert('Please enter the valid landlord registration number');
            }
        }
        let OrgUser = component.get("v.OrgUser");
        let validinput = false;
        let validateAddress = false;
        let orgvalid = true; 
        var Email = component.get("v.Email");
        var Phone = component.get("v.Phone");
        let allValid = component
        .find("fieldId")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);
        if(OrgUser)
        {
            let orgvalidate = component
            .find("CompfieldId")
            .reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get("v.validity").valid;
            }, true);
            if(!orgvalidate)
            {
                orgvalid = false;
            }
        }
        var objChild = component.find("compB");
        if (
            objChild.get("v.PostCode") == "" ||
            typeof objChild.get("v.PostCode") == "undefined" ||
            objChild.get("v.AddressLine1") == "" ||
            typeof objChild.get("v.AddressLine1") == "undefined" ||
            objChild.get("v.Town") == "" ||
            typeof objChild.get("v.Town") == "undefined" ||
            objChild.get("v.Country") == "" ||
            typeof objChild.get("v.Country") == "undefined"
        ) {
            alert("Please fill Address");
            validateAddress = false
        }
        else
        {
            validateAddress = true;
        }
        if(orgvalid && allValid && validateAddress)
        {
            if (Email || Phone)
            {
                validinput = true;  
            }
            else
            {
                alert("Please specify atleast Email or Phone.");
                validinput = false;
            }
        }
        else
        {
           validinput = false; 
        }
        
        if (validinput && validatelrn) {
            var action = component.get("c.savelandlord");
            action.setParams({
                salutation: component.get("v.Title"),
                firstname: component.get("v.firstName"),
                lastname: component.get("v.lastName"),
                email: component.get("v.Email"),
                phone: component.get("v.Phone"),
                isOrguser: OrgUser,
                companyName: component.get("v.companyName"),
                companyPhone: component.get("v.companyPhone"),
                /* companyAddress: component.get("v.companyAddress"),
                companyEmail: component.get("v.companyEmail"),*/
                street: component.get("v.Street"),
                city: component.get("v.Town"),
                postcode: component.get("v.PostCode"),
                country: component.get("v.Country"),
                county: component.get("v.County"),
                propertyRecId : propertyRecId,
                LandRegNumber :LandRegNumber
            });
            action.setCallback(this, function (a) {
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Record has been created successfully."
                    });
                    toastEvent.fire();
                    component.find("overlayLib").notifyClose();
                    $A.get('e.force:refreshView').fire();
                }
            });
            
           $A.enqueueAction(action);
        }
    },
    
    clickCreate: function (component, event, helper) 
    {
        component.set("v.companyNameError",false);
        component.set("v.companyPhoneError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.telephoneNumError",false);
        component.set("v.registrationNumError",false);
        let propertyId= component.get("v.propertyRecId");
        var isValid = true;
        console.log('isValid',isValid);
        var companyNamecheck = component.find("compNameId").get("v.value");
        var companyPhonecheck = component.find("compPhoneId").get("v.value");
        var titleCheck = document.getElementById("titleId").value;
        var firstNameCheck = component.find("firstNameId").get("v.value");
        var surnameCheck = component.find("surNameId").get("v.value");
        var emailCheck = component.find("emailID").get("v.value");
        var telephoneCheck = component.find("telephoneNumberId").get("v.value");
        var regNumberCheck = component.find("regNumberId").get("v.value");
        
        console.log('companyNamecheck',companyNamecheck);
        console.log('companyPhonecheck',companyPhonecheck);
        console.log('titleCheck',titleCheck);
        console.log('firstnamecheck',firstNameCheck);
        console.log('surnamecheck',surnameCheck);
        console.log('emailcheck',emailCheck);
        console.log('telephonecheck',telephoneCheck);
        console.log('regnumbercheck',regNumberCheck);
        console.log('Working');
        console.log(component.get("v.OrgUser"));
        //var act = component.get("v.act");
        if(component.get("v.OrgUser"))
        {
            if (companyNamecheck == undefined || companyNamecheck == "" || companyNamecheck == null ) {  
                component.set("v.companyNameError",true);    
                isValid = false;
            }
            if (companyPhonecheck == undefined || companyPhonecheck == "" || companyPhonecheck == null ) {  
                component.set("v.companyPhoneError",true);    
                isValid = false;
            }
        }
        if (titleCheck == undefined || titleCheck == "" || titleCheck == null || titleCheck == "-- Please Select --") {  
            component.set("v.titleError",true);    
            isValid = false;
        }
        //console.log('Working1');
        if (firstNameCheck == undefined || firstNameCheck == "" || firstNameCheck == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
        //console.log('Working2');
        if (surnameCheck == undefined || surnameCheck == "" || surnameCheck == null) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
        //console.log('Working3');
        if (emailCheck == undefined || emailCheck == "" || emailCheck == null) {
            component.set("v.emailError",true);    
            isValid = false;
        }
        //console.log('Working4');
        if (telephoneCheck == undefined || telephoneCheck == "" || telephoneCheck == null) {
            component.set("v.telephoneNumError",true);    
            isValid = false;
        }
        //console.log('Working5');
        /*if (regNumberCheck == undefined || regNumberCheck == "" || regNumberCheck == null) {
            component.set("v.registrationNumError",true);    
            isValid = false;
        }*/
        
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
            }
        }
        
        var objChild = component.find("compB");
        if (
            objChild.get("v.AddressLine1") == "" ||
            typeof objChild.get("v.AddressLine1") == "undefined" ||
            objChild.get("v.Town") == "" ||
            typeof objChild.get("v.Town") == "undefined" ||
            objChild.get("v.County") == "" ||
            typeof objChild.get("v.County") == "undefined" ||
        	objChild.get("v.PostCode") == "" ||
            typeof objChild.get("v.PostCode") == "undefined" ||
            objChild.get("v.Country") == "" ||
            typeof objChild.get("v.Country") == "undefined"
		)
        {
        	component.set("v.isAddressValidError",true);
            isValid = false;
            //alert("Please fill Address");
            //validateAddress = false;
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
            
            var action = component.get("c.savelandlord");
                action.setParams({
                    salutation: component.get("v.Title"),
                    firstname: component.get("v.firstName"),
                    lastname: component.get("v.lastName"),
                    email: component.get("v.Email"),
                    phone: component.get("v.Phone"),
                    companyName: component.get("v.companyName"),
                    companyPhone: component.get("v.companyPhone"),
                    isOrguser:  component.get("v.OrgUser"),
                    street: objChild.get("v.AddressLine1"),
                    city: objChild.get("v.Town"),
                    postcode: objChild.get("v.PostCode"),
                    country: objChild.get("v.Country"),
                    county: objChild.get("v.County"),
                    propertyRecId : propertyRecId,
                    LandRegNumber :LandRegNumber
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
                    if (state == "SUCCESS") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success!",
                            message: "Record has been created successfully."
                        });
                        toastEvent.fire();
                        component.find("overlayLib").notifyClose();
                        
                        var cmpEvent = component.getEvent("refreshViewProperty"); 
                        cmpEvent.fire();
                        //$A.get('e.force:refreshView').fire();
                    }
                });    
            $A.enqueueAction(action);
            
            //alert('Stage 3');
            component.set("v.succeessmessage", true);
        }
    },
    handleCancel : function (component, event, helper)
    {
        //alert('Handle Cancel');
        console.log('Handle Cancel');
        component.set("v.companyNameError",false);
        component.set("v.companyPhoneError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.telephoneNumError",false);
        component.set("v.registrationNumError",false);
        component.set("v.isAddressValidError",false);
        component.set("v.succeessmessage",false);
        component.set("v.OrgUser",false);
        component.set("v.Title",'');
        component.set("v.firstName",'');
        component.set("v.lastName",'');
        component.set("v.Email",'');
        component.set("v.Phone",'');
        component.set("v.Address",'');
        component.set("v.companyName",'');
        component.set("v.companyPhone",'');
        component.set("v.propertyRecId",'');
        component.set("v.LandRegNumber",'');
        component.set("v.Street",'');
        component.set("v.Town",'');
        component.set("v.PostCode",'');
        component.set("v.Country",'');
        component.set("v.County",'');
        console.log('lastName ',component.get("v.lastName"));
        //$A.get('e.force:refreshView').fire();
        //$('#createUser').modal('dispose');
        //$('#createUser').modal('hide');
        console.log('425 ');
        component.destroy();
        //window.location.reload();
    },
    handleYes : function (component, event, helper)
    {
		component.set("v.companyNameError",false);
        component.set("v.companyPhoneError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.telephoneNumError",false);
        component.set("v.registrationNumError",false);
        component.set("v.isAddressValidError",false);
        component.set("v.OrgUser", true);
        console.log('In handleYes');
    },
    
    handleNo : function (component, event, helper)
    {
        component.set("v.companyNameError",false);
        component.set("v.companyPhoneError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.telephoneNumError",false);
        component.set("v.registrationNumError",false);
        component.set("v.isAddressValidError",false);
        component.set("v.OrgUser",false);
        console.log('In handleNo');
    },

    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "companyName":
                component.set("v.companyNameError", false);
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
            case "registrationNumber":
                component.set("v.registrationNumError", false);
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
    
});