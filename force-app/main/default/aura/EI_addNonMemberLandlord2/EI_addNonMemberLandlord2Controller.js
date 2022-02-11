({
    doInit: function(component, event, helper) {
        
        // Get Picklist Value from Schema
        var action = component.get("c.landlordRegistrationStatusList");
        action.setCallback(this, function (response) {
            var state = response.getState();
            // Handle Success
            if (state === "SUCCESS") 
            {
                var result = response.getReturnValue();
                console.log(result);
                console.log(JSON.stringify(result));
                //alert(result);
                var lanRegStatuses = [];
                for (var key in result) {
                    lanRegStatuses.push({ key: key, value: result[key] });
                }
                component.set("v.LandRegStatuses", lanRegStatuses);
                console.log('lanRegStatuses --->>> ', lanRegStatuses);
            }
            // Handle Error
            else if (state === "ERROR") {
                var errors = response.getError();
                // If error then check error type
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // If duplicate username fire toast message
                        
                        // for other errors fire toast Message
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error!",
                            message: errors[0].message,
                            type: "error"
                        });
                    }
                } else {
                    //   console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  
    },
    
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
    
    clickCreate: function (component, event, helper) {

        component.set("v.companyNameError",false);
        component.set("v.companyPhoneError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.invalidEmailFormatError",false);
        component.set("v.telephoneNumError",false);
        component.set("v.registrationNumError",false);
        component.set("v.isAddressValidError",false);
        var propertyId= component.get("v.propertyRecId");
        var isValid = true;
        console.log('isValid',isValid);
        var companyNamecheck = component.find("compNameId").get("v.value");
        var companyPhonecheck = component.find("compPhoneId").get("v.value");
        var titleCheck = document.getElementById("titleId").value;
        var firstNameCheck = component.find("firstNameId").get("v.value");
        var surnameCheck = component.find("surNameId").get("v.value");
        var emailCheck = component.find("emailID").get("v.value");
        var telephoneCheck = component.find("telephoneNumberId").get("v.value");
        //var regNumberCheck = component.find("regNumberId").get("v.value");
        var regStatusCheck = document.getElementById("regStatusId").value;
        
        if(component.get("v.OrgUser") == undefined){
              component.set("v.yesNoError", true);
              isValid = false;
        }
        else if(component.get("v.OrgUser"))
        {
              component.set("v.yesNoError", false);
            if (companyNamecheck == undefined || companyNamecheck == "" || companyNamecheck == null ) {  
                component.set("v.companyNameError",true);    
                isValid = false;
            }
            if (companyPhonecheck == undefined || companyPhonecheck == "" || companyPhonecheck == null ) {  
                component.set("v.companyPhoneError",true);    
                isValid = false;
            }
        }else if(!component.get("v.OrgUser")){component.set("v.yesNoError", false);}
        
        if (titleCheck == undefined || titleCheck == "" || titleCheck == null || titleCheck == "-- Please Select --") {  
            component.set("v.titleError",true);    
            isValid = false;
        }
        if (firstNameCheck == undefined || firstNameCheck == "" || firstNameCheck == null) {  
            component.set("v.firstNameError",true);    
            isValid = false;
        }
        if (surnameCheck == undefined || surnameCheck == "" || surnameCheck == null) {
            component.set("v.surNameError",true);    
            isValid = false;
        }
        if (emailCheck == undefined || emailCheck == "" || emailCheck == null) {
            component.set("v.emailError",true);    
            isValid = false;
        }
        else
        {
			var isEmailPatterValid = helper.emailFormatChecker(component, emailCheck);
            //alert(`isEmailPatterValid ${isEmailPatterValid}`);
            if(!isEmailPatterValid)
            {
                component.set("v.invalidEmailFormatError",true);
                isValid = false;
            }
        }
        if (telephoneCheck == undefined || telephoneCheck == "" || telephoneCheck == null) {
            component.set("v.telephoneNumError",true);    
            isValid = false;
        }
        /*if (regNumberCheck == undefined || regNumberCheck == "" || regNumberCheck == null) {
            component.set("v.registrationNumError",true);    
            isValid = false;
        }*/
        
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
                    /*&& !isNaN(innervaluearray)
                    console.log(`innervaluearray -> ${innervaluearray[0]} isNaN -> ${isNaN(innervaluearray[0])}`);
                	console.log(`innervaluearray -> ${innervaluearray[1]} isNaN -> ${isNaN(innervaluearray[1])}`);
                	console.log(`innervaluearray -> ${innervaluearray[2]} isNaN -> ${isNaN(innervaluearray[2])}`); */
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
        
        if(isValid)
        {
            //alert('Landlord will be created successfully');
            
            //console.log('Landlord will be created successfully');
            
            var action = component.get("c.savelandlord");
                action.setParams({
                    salutation: titleCheck,
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
                    LandRegNumber : LandRegNumber, 
                    LandRegStatus : regStatusCheck
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
                       
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success!",
                            message: "Record has been created successfully."
                        });
                        toastEvent.fire();*/
                        component.find("overlayLib").notifyClose();
                         $('#maincon', window.parent.document).get(0).scrollIntoView();
                        var cmpEvent = component.getEvent("refreshViewProperty"); 
                        cmpEvent.fire();
                        //$A.get('e.force:refreshView').fire();
                        component.set("v.succeessmessage", true);
                       var btnSave = document.getElementById("saveBtn");
                       var jointLandlord = component.get("v.JointLandlord");
                       console.log('jointLandlord '+jointLandlord);
                        setTimeout(function(){
                             var result = a.getReturnValue();
                             console.log('result '+result);
                      //  var resultId = result.split("#")[1];
                        component.set("v.recordId",result);
                        console.log('resultId '+result);
                            if(!component.get("v.fromViewLandlord")){
                                var vx = component.get("v.method");
                            console.log('vx2 jointLandlord'+vx);
            					  $A.enqueueAction(vx);  
                                
                                 helper.helperCancel(component, event, helper);
                            console.log('resultId cancel');
                             $('#createUser2').modal('hide');
                                
                            }else{
                                 var vx = component.get("v.viewlandlordmethod");
                            console.log('vx2 viewlandlord'+vx);
            					  $A.enqueueAction(vx); 
                                
                                 helper.helperCancel(component, event, helper);
                            console.log('resultId cancel');
                             $('#createUser2').modal('hide');
                            }
                                
                            
                      
                            
                        
                                             }, 500);

                    
						
                    }
                });    
            $A.enqueueAction(action);
            
            /*component.set("v.companyNameError",false);
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
            console.log('lastName ',component.get("v.lastName")); */
        }
        else{
            
              $('#maincon', window.parent.document).get(0).scrollIntoView();
        }
    },
    
    /*clickCreate1: function (component, event, helper) { //Old create
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
                // companyAddress: component.get("v.companyAddress"),
                // companyEmail: component.get("v.companyEmail"),
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
    },*/
    
    handleCancel : function (component, event, helper) {
           console.log('in cancel;'); 
        helper.helperCancel(component, event, helper);
        //console.log('442');
        // Setting all the error message to false
   
        //document.getElementById("landlordForm").reset();
        //console.log('472');
        /*component.set("v.companyPhone",'');
        component.set("v.propertyRecId",'');
        component.set("v.LandRegNumber",'');
        console.log('lastName ',component.get("v.lastName"));
        //$A.get('e.force:refreshView').fire();
        //$('#createUser').modal('dispose');
        //$('#createUser').modal('hide');
        console.log('425 ');
        //component.destroy();
        //window.location.reload(); */
    },
    
    handleYes : function (component, event, helper) {
          var jointLandlord = component.get("v.JointLandlord");
                       console.log('initjointLandlord '+jointLandlord);
          var ys =  component.find("landlordCompYes");
   		 var no =   component.find("landlordCompNo");
 
 		  $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
		component.set("v.companyNameError",false);
        component.set("v.companyPhoneError",false);
        component.set("v.titleError",false);
        component.set("v.firstNameError",false);
        component.set("v.surNameError",false);
        component.set("v.emailError",false);
        component.set("v.telephoneNumError",false);
        component.set("v.registrationNumError",false);
        component.set("v.isAddressValidError",false);
           component.set("v.yesNoError", false);
        component.set("v.OrgUser", true);
        console.log('In handleYes');
    },
    
    handleNo : function (component, event, helper) {
          var jointLandlord = component.get("v.JointLandlord");
                       console.log('initjointLandlord '+jointLandlord);
         var ys =  component.find("landlordCompYes");
    var no =   component.find("landlordCompNo");
 
   $A.util.removeClass(ys, "clickButton");
        $A.util.addClass(no, "clickButton");   
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
         component.set("v.yesNoError", false);
        console.log('In handleNo');
    },
    
    regStatusChange : function (component, event, helper) {
        var regStatusCheck = document.getElementById("regStatusId").value;
        if(regStatusCheck!='' && regStatusCheck!=null && regStatusCheck!=undefined)
        {
            if(regStatusCheck == "Landlord is entered on the local authority register for the area where this property is located." || 
               regStatusCheck == "Landlord is appealing a decision to remove their entry from the local authority register.")
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

    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "yesNoMsg":
                component.set("v.yesNoError", false);
                break;     
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
            case "invalidFormatEmail":
                component.set("v.invalidEmailFormatError", false);
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