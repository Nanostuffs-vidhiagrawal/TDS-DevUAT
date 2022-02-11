({
    chDate : function(component) {
        //    alert('recievedDateYMD');   
        let allDateValid = false; 
        
        let arraydate = [];
        //Grab Date Elements   
        let depositRecievedDate = document.getElementById("depositRecievedDate").value;
        let depositRecievedMonth = document.getElementById("depositRecievedMonth").value;
        let depositRecievedYear = document.getElementById("depositRecievedYear").value;
        let receivedDate = depositRecievedDate+'-'+depositRecievedMonth+'-'+depositRecievedYear;
        let recievedDateYMD =depositRecievedYear+'-'+depositRecievedMonth+'-'+depositRecievedDate;
        
        //     alert(recievedDateYMD);   
        arraydate.push(receivedDate);
        let isValidDate = validatedate(receivedDate);
        let loopCounter = 0;
        for(var i=0; i<arraydate.length; i++){
            allDateValid = validatedate(arraydate[i]);        
            if(allDateValid==false){
                if(loopCounter == 0){
                    component.set("v.showRecievedDateError",true);
                }else{
                    component.set("v.showRecievedDateError",false);
                    component.set("v.showTenancyDateError",true);
                } 
                
                break;
            }else{
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
        
        if (allDateValid) {
            component.set("v.depositRecievedDate",recievedDateYMD);
            console.log(component.get("v.depositRecievedDate"));
        }
        
    },
    
    PassVariable: function(component, event, helper) {
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
    
    SubmitDetails: function(component, event, helper) {
        var startDate = component.get("v.dateToday");
        // var rentAmount = document.getElementById("Rent").value
        var rentAmount = component.find("Rent").get("v.value");
        let OrgUser = component.get("v.OrgUser");
        let validinput = false;
        let validateAddress = false;
        let orgvalid = true; 
        var Email = component.get("v.Email");
        var Phone = component.get("v.Phone");
        //         alert('comp'); 
        //        alert('comp '+OrgUser);
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
            // alert('comp '+orgvalid);
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
        
        if (validinput) {
            //  alert(component.get("v.startDate") +' '+ component.get("v.rentAmount"));
            var companyname = component.get("v.companyName");
            var companyPhone = component.get("v.companyPhone");
            var companyEmail = component.get("v.companyEmail");
            if(typeof component.get("v.companyName") == "undefined"){
                companyname = '';
            }
            if(typeof component.get("v.companyPhone") == "undefined"){
                companyPhone = '';
            }
            if(typeof component.get("v.companyEmail") == "undefined"){
                companyEmail = '';
            }
            
            //-------
            
            var phone = component.get("v.Phone");
            var landregNumber = component.get("v.LandRegNumber");
            if(typeof component.get("v.Phone") == "undefined" || component.get("v.Phone") == ''){
                phone = '';
            }
            if(typeof component.get("v.LandRegNumber") == "undefined" || component.get("v.LandRegNumber") == ''){
                landregNumber = '';
            }
            
            // alert(companyname +' '+ companyPhone +' '+companyEmail);          
            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
            const depositId = urlParams.get('id');
            var action = component.get("c.savelandlord");
            
            action.setParams({
                landlordRegNumber : landregNumber,
                startDate : startDate,
                rentAmount : rentAmount,
                DepositId : depositId,
                salutation: component.get("v.Title"),
                firstname: component.get("v.firstName"),
                lastname: component.get("v.lastName"),
                email: component.get("v.Email"),
                phone: phone,
                isOrguser: OrgUser,
                companyName: companyname,
                companyPhone: companyPhone,
                companyEmail: companyEmail,               
                street: component.get("v.Street"),
                city: component.get("v.Town"),
                postcode: component.get("v.PostCode"),
                country: component.get("v.Country"),
                county: component.get("v.County") 
            });
            action.setCallback(this, function (a) {
                
                var returnResult = a.getReturnValue();
                //    alert('result '+returnResult);
                var state = a.getState();
                var errors = a.getError();
                //    alert('errors '+errors+' && '+state);
                if (state == "SUCCESS" || errors == '' ) {
                    console.log('SUCCESS');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success",
                        message: "Landlord has been created successfully.",
                        duration: " 500",
                        key: "info_alt",
                        type: "success",
                        mode: "pester"
                    });
                    
                    toastEvent.fire();
                    const Dbase = returnResult.split("=")
                    
                    var retdepositId = Dbase[1];
                    console.log('Deposit return '+retdepositId);
                    
                    
                    
                    if(retdepositId != null){
                        component.find("navService").navigate({
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "depositsummarypage"
                            },
                            state: {id: retdepositId}
                        });
                    }
                    
                }
                else {
                    component.find("notifLib").showNotice({
                        variant: "Warning",
                        header: "Oops!",
                        message:
                        "We encountered a problem. For help,Please contact your administrator."+errors,
                        closeCallback: function () {}
                    });
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    
    SubmitDetailsWithoutLandlord: function(component, event, helper) {
        console.log('Test');
        helper.chDate(component,event, helper);
        console.log('Test22');
        var allValid = true;
        var startDate = component.get("v.depositRecievedDate");
        
        //   var rentAmount = document.getElementById("Rent").value;
        var rentAmount = component.find("Rent").get("v.value");
        
        var propertyId;
        
        if(!component.get("v.propertySelcted")) {
            component.set("v.propertyError", true);
        }
        else {
            propertyId = component.get("v.selectedProperty")[0].Id;
            component.set("v.propertyError", false);
        }
        //  alert('propertyId '+propertyId+rentAmount+startDate);
        var flag = true;
        if(startDate == null || typeof startDate == "undefined" || startDate == '') {
            flag = false;
        }
        else {
            flag = true;
        }
        if(typeof rentAmount == "undefined" || rentAmount == '' || rentAmount == null) {
            // alert('rentAmount '+rentAmount);
            component.set("v.rentError", true);
            
        } else if(rentAmount<1) {
            allValid = false;
            component.set("v.amountCantBeLessThan1Error",true);
            
        } else {
            component.set("v.rentError", false);  
        }
        
        if(rentAmount != '' && flag == true &&  propertyId != '' && allValid) {
            console.log('in If');
            component.set("v.disableBtn",true);
            
            component.set("v.propertyError", false);
            component.set("v.startDateError", false);
            component.set("v.rentError", false);
            if( component.get("v.selectedProperty")[0].Town__c){
            component.set("v.propertyAddress", component.get("v.selectedProperty")[0].Street__c + ' ' + component.get("v.selectedProperty")[0].Town__c + ' ' + component.get("v.selectedProperty")[0].City__c + ' ' + component.get("v.selectedProperty")[0].County__c + ' ' + component.get("v.selectedProperty")[0].Postal_Code__c);
            }
            else{
             component.set("v.propertyAddress", component.get("v.selectedProperty")[0].Street__c + ' ' + component.get("v.selectedProperty")[0].City__c + ' ' + component.get("v.selectedProperty")[0].County__c + ' ' + component.get("v.selectedProperty")[0].Postal_Code__c);    
            }
            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
            const depositId = urlParams.get('id');
            var action = component.get("c.transferDeposit");
            
            action.setParams({
                startDate : startDate,
                rentAmount : rentAmount,
                DepositId : depositId,
                PropertyId : propertyId
            });
            action.setCallback(this, function (a) {
                
                var returnResult = a.getReturnValue();
                //       alert('result '+returnResult);
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS" || errors == '' ) {
                    console.log('SUCCESS');
                    
                    component.set("v.newDepositId",returnResult); 
                    component.set("v.displayThankyouMessage",true); 
                }
                else {
                    component.set("v.finalError", true);
                    component.set("v.disableBtn",false);
                }
            });
            
            $A.enqueueAction(action);
        }
    }
    
})