({
    
    doInit : function (component, event, helper) {
        let depositRecievedDate = component.get("v.depositRecievedDate");
        let tenancyStartDate = component.get("v.tenancyStartDate"); 
        //   component.set("v.editModeTimeId",window.performance.now()); 
        //  alert('component.get("v.editModeTimeId") '+component.get("v.editModeTimeId"));
        helper.DOM_Manupulation(component, depositRecievedDate, tenancyStartDate);  
    },
    
    handleBlur: function (cmp, event) {
        var validity = cmp.find("field").get("v.validity");
        console.log(validity.valid); //returns true
    },
    
    doContinue: function (component, event, helper) {
        
        component.set("v.genericError",false);
        component.set("v.amountCantBeLessThan1Error",false);
        component.set("v.tenantNumberError",false);
        component.set("v.rentAmountError",false);
        component.set("v.depositAmountError",false);
        component.set("v.amntToProtectError",false);
        //JS Variables  
        let allValid = false;
        let allValidAmount = true;
        let allDateValid = false;
        let isValidTenantNum = true;
        let arrayField = [];
        let arraydate = [];
        
        //Grab Component Attributes for Required Validation  
        let rentAmount = component.get("v.rentAmount");  
        let depositAmount = component.get("v.depositAmount");
        let amountToProtect = component.get("v.amountToProtect");
        let Number_of_tenants = component.get("v.noOfTenants");
        
        //Validating all the amounts
        //alert(`rentAmount ${rentAmount} depositAmount ${depositAmount} amountToProtect ${amountToProtect}`);
        if((rentAmount=="" || rentAmount==undefined || rentAmount==null || rentAmount <= 0))
        {
            component.set("v.rentAmountError",true);
            
        } else if(rentAmount<1) {
            allValidAmount = false;
            component.set("v.amountCantBeLessThan1Error",true);
        }
        if((depositAmount=="" || depositAmount==undefined || depositAmount==null || depositAmount <= 0))
        {
            component.set("v.depositAmountError",true);
            
        } else if(depositAmount<1) {
            allValidAmount = false;
            component.set("v.amountCantBeLessThan1Error",true);
        }
        if((amountToProtect=="" || amountToProtect==undefined || amountToProtect==null || amountToProtect <= 0))
        {
            component.set("v.amntToProtectError",true);
            
        } else if(amountToProtect<1) {
            allValidAmount = false;
            component.set("v.amountCantBeLessThan1Error",true);
        }
        if((rentAmount=="" || rentAmount==undefined || rentAmount==null || rentAmount <= 0) || 
           (depositAmount=="" || depositAmount==undefined || depositAmount==null || depositAmount <= 0)  || 
           (amountToProtect=="" || amountToProtect==undefined || amountToProtect==null || amountToProtect <= 0))
        {
            allValidAmount = false;
            //alert('notValid');
        }
        //Validating the number of tenants
        if(Number_of_tenants>99 || Number_of_tenants<1 || Number_of_tenants=="" || Number_of_tenants==null 
           || Number_of_tenants==undefined)
        {
            isValidTenantNum = false;
            component.set("v.tenantNumberError",true);
        }
        
        
        //Grab HTML Attributes for Required Validation    
        //let Number_of_tenants = document.getElementById("Number_of_tenants").value;
        
        //Array Formation for required validity check
        arrayField.push(rentAmount, depositAmount, amountToProtect, Number_of_tenants);
        
        //Grab Date Elements   
        let depositRecievedDate = document.getElementById("depositRecievedDate").value;
        let depositRecievedMonth = document.getElementById("depositRecievedMonth").value;
        let depositRecievedYear = document.getElementById("depositRecievedYear").value;
        let receivedDate = depositRecievedDate+'-'+depositRecievedMonth+'-'+depositRecievedYear;
        let recievedDateYMD =depositRecievedYear+'-'+depositRecievedMonth+'-'+depositRecievedDate;
        
        
        let tenancyStartDate = document.getElementById("tenancyStartDate").value;
        let tenancyStartMonth = document.getElementById("tenancyStartMonth").value;
        let tenancyStartYear = document.getElementById("tenancyStartYear").value;
        let tenancyDate = tenancyStartDate+'-'+tenancyStartMonth+'-'+tenancyStartYear;
        let tenancyDateYMD =tenancyStartYear+'-'+tenancyStartMonth+'-'+tenancyStartDate;
        
        
        //Array Formation for Date validity check
        arraydate.push(receivedDate, tenancyDate);
        
        let isValidDate = validatedate(receivedDate);
        //console.log("isValidDate",isValidDate);
        
        /**
        *	Required Field Validation starts Here
        */
        for(var i=0; i<arrayField.length; i++){
            allValid = requiredFieldValidation(arrayField[i]);        
            if(allValid==false){
                break;
            }
        }
        
        /**
        *	Date Validation starts Here
        */
        let loopCounter = 0;
        for(var i=0; i<arraydate.length; i++) {
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
        
        /*  var allValid = component
      .find("field")
      .reduce(function (validSoFar, inputCmp) {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true); */
        
        if (allValid && allDateValid) {
            component.set("v.depositRecievedDate",recievedDateYMD);
            component.set("v.tenancyStartDate",tenancyDateYMD);
            
            let itemList = [];
            
            let noOfTenants = parseInt(component.get("v.noOfTenants"));
            let emptylist = component.get("v.arrObj");
            
            if (!isNaN(noOfTenants)) {
                for (let i = 1; i < noOfTenants; i++) {
                    itemList.push(i);
                }
            }
            
            let listcount = emptylist.length;
            
            if (noOfTenants > 0 || listcount != noOfTenants) {
                if (listcount > noOfTenants - 1) {
                    for (let k = noOfTenants - 1; k < listcount; k++) {
                        emptylist.pop();
                    }
                } else {
                    for (let j = 1; j < noOfTenants - listcount; j++) {
                        var person = new Object();
                        person.firstName = "";
                        person.SurName = "";
                        person.email = "";
                        person.phoneCode = "+44";
                        person.phone = "";
                        person.title = "";
                        person.companyName = "";
                        person.IsOrg = false;
                        person.IsformSubmitted = false;
                        person.item = j + listcount;
                        emptylist.push(person);
                    }
                }
            }
            
            component.set("v.arrObj", emptylist);
            component.set("v.tenantItemList", itemList);
            component.set("v.itemListlength", itemList.length);
            //component.set("v.showAddTenant", true);
            //component.set("v.depositView", false);
            
            let leaddetails = component.get("v.leadTenantObj");
            console.log("line 200 leaddetails",JSON.stringify(leaddetails));
            
            /* if (leaddetails != null) {
            	var person = new Object();
				// component.set("v.leadTenantObj", person);
                console.log("line 204");
			}
            else {
            	var person = new Object();
                component.set("v.leadTenantObj", person);
                console.log("line 208");
            }*/
            
          if(isValidTenantNum && allValidAmount)
          {
              component.set("v.showAddTenant", true);
              component.set("v.depositView", false);
              var v1 = document.getElementsByClassName("state-indicator");
              v1[2].classList.add("active");
              //$('#maincon', window.parent.document).get(0).scrollIntoView();
              document.getElementById("sf-tabContent").scrollIntoView();
              
          }
          component.set("v.genericError",false);
      } else {
          //  alert("Please update the invalid form entries and try again.");
          // var v1 = document.getElementsByClassName("state-indicator");
          // v1[1].classList.remove("active");
          component.set("v.genericError",true);
      }
        
        
    },
    
    backToDepositComp: function (component, event, helper) {
        console.log("line 230");
        var v1 = document.getElementsByClassName("state-indicator");
        v1[2].classList.remove("active");
        let depositRecievedDate = component.get("v.depositRecievedDate");
        let tenancyStartDate = component.get("v.tenancyStartDate");
        
        let leadTenantObj = component.get("v.leadTenantObj");
        let arrObj = component.get("v.arrObj");
        console.log("line 240 leadTenantObj : ",JSON.stringify(leadTenantObj));
       
        
        var cmpEvent = component.getEvent("EI_tenantHome");
        console.log("line 243");
        helper.DOM_Manupulation(component, depositRecievedDate, tenancyStartDate);
      
        cmpEvent.setParams({ leadTenantObj: leadTenantObj });
        cmpEvent.setParams({ arrObj: arrObj });
         console.log("line 248");
        cmpEvent.fire();
         component.set("v.showAddTenant", false);
        component.set("v.depositView", true);
         console.log("line 250");
    },
    
    EI_tenantHome : function (component, event, helper) {
        console.log("handled start 248");
        let depositRecievedDate = component.get("v.depositRecievedDate");
        let tenancyStartDate = component.get("v.tenancyStartDate");    
        var v1 = document.getElementsByClassName("state-indicator");
        v1[3].classList.remove("active");
        v1[2].classList.remove("active");
        component.set("v.showAddTenant", false);
        component.set("v.showSummary", false); 
        component.set("v.depositView", true);
        console.log("line 255");    
        helper.DOM_Manupulation(component, depositRecievedDate, tenancyStartDate);
        console.log("handled ended 257");
    },
    
    EI_depositDetailFromSummary : function (component, event, helper) {
    console.log("handled start 269");
    let depositRecievedDate = component.get("v.depositRecievedDate");
    let tenancyStartDate = component.get("v.tenancyStartDate");    
    var v1 = document.getElementsByClassName("state-indicator");
    v1[3].classList.remove("active");
    component.set("v.showAddTenant", true);
    component.set("v.showSummary", false); 
    component.set("v.depositView", false);
    console.log("line 255");    
    helper.DOM_Manupulation(component, depositRecievedDate, tenancyStartDate);
        var arrObj = event.getParam("arrObj");
        var leadTenantObj = event.getParam("leadTenantObj");
        component.set("v.leadTenantObj",leadTenantObj);
        component.set("v.arrObj",arrObj);
        console.log("handled ended 257");
	},
    
    handleValueChange:function(component) {
        alert(`Aura Value Changed`);
    },
    
    moveToSummaryPage: function (component, event, helper) {
        var arrObj = component.get("v.arrObj");
        console.log("arrObj moveSum :",JSON.stringify(arrObj));
        var leadTenantObj = component.get("v.leadTenantObj");
        console.log("leadTenantObj moveSum :",JSON.stringify(leadTenantObj));
        if(leadTenantObj==undefined){
            
        }
        var arrValidate = Array.from(arrObj);
        arrValidate.push(leadTenantObj);
        var counter = 0;
        if (leadTenantObj != null) {
             component.set("v.fillForm", false);
            for (var k of arrValidate) {
                if (k.email != "") {
                    counter++;
                }else if(k.phone != ""){
                    counter++;
                }
            }
            
            if (arrValidate.length == counter) {
                component.set("v.showAddTenant", false);
                component.set("v.showSummary", true);
                 component.set("v.fillForm", false);
            } else {
                 component.set("v.fillForm", true);
                //alert("Please fill all the forms on the Page");
            }
        } else {
             component.set("v.fillForm", true);
           // alert("Please fill all the forms on the Page");
        }
    },
    
    EI_tenantDetailEvent: function (component, event, helper) {
        // Get and set the parameters recieved from component event to cmp attribute
        var arrObj = event.getParam("arrObj");
        // var FormNumber = event.getParam("PageNumber");
        // component.set("v.formNumber", FormNumber);
        // alert(arrObj.item);
        // console.log("arrObj item:", arrObj.item);
        let arr = [];
        arr = component.get("v.arrObj");
        // console.log("line 278 arrObj : ",arrObj);
        if (arrObj.LeadSummary) {
            component.set("v.leadTenantObj", arrObj);
            console.log("arrObj 282 : ",JSON.stringify(arrObj));
            
        } else if (!arrObj.LeadSummary) {
            // console.log("arrObj:", arr);
            console.log("arrObj 285 :", JSON.stringify(arrObj));
            if (arr.length > 0) {
                console.log("arr.length 288 : ",arr.length);   
                for (let i = 0; i < arr.length; i++) {
                    if (arr[i].item == arrObj.item) {
                        arr[i] = arrObj;
                        console.log("arrObj 291 : ",arrObj);                        
                        console.log("arrObj 293 : ",arr[i]);
                    }
                }
            } else {
                arr.push(arrObj);
                console.log("arrObj 297 : ",arrObj);    
            }
            
            component.set("v.arrObj", arr);
            console.log("line 296 arr : ",arr);
        }
        
        var validateLeadTenantForm = false;
        var validateAddTenantForm = false;
        var leadTenantCount = component.get("v.leadTenantObj");
        var addTenantCount = component.get("v.arrObj");
        var formCounter = 0;
        
        if(leadTenantCount){
			validateLeadTenantForm = leadTenantCount.IsformSubmitted;            
        }
        
        if(addTenantCount){
            for(var i=0; i<addTenantCount.length; i++){
                if(addTenantCount[i].IsformSubmitted){
                    // validateAddTenantForm = true;
                    formCounter++;
                }
            }
            if(addTenantCount.length==formCounter){
                validateAddTenantForm = true;
            }
        }
        
        if(validateAddTenantForm && validateLeadTenantForm) {
			// $A.enqueueAction(component.get("c.moveToSummaryPage"));
        }
        
        // console.log("v.arrObj 311", component.get("v.arrObj").IsformSubmitted);
        // console.log("v.lead 312", JSON.stringify(component.get("v.leadTenantObj").IsformSubmitted));
        
    },
    
    backToDepositHome: function (component, event, helper) {
        console.log("line 289");
        // Grab Date Elements   
        let depositRecievedD = document.getElementById("depositRecievedDate").value;
        let depositRecievedM = document.getElementById("depositRecievedMonth").value;
        let depositRecievedY = document.getElementById("depositRecievedYear").value;
        let recievedDateYMD = depositRecievedY+'-'+depositRecievedM+'-'+depositRecievedD;
        component.set("v.depositRecievedDate",recievedDateYMD);
        
        console.log("depositRecievedDate",component.get("v.depositRecievedDate"));
		 
        
        let tenancyStartD = document.getElementById("tenancyStartDate").value;
        let tenancyStartM = document.getElementById("tenancyStartMonth").value;
        let tenancyStartY = document.getElementById("tenancyStartYear").value;
        let tenancyDateYMD = tenancyStartY+'-'+tenancyStartM+'-'+tenancyStartD
        component.set("v.tenancyStartDate",tenancyDateYMD);
        console.log("tenancyStartDate",component.get("v.tenancyStartDate")); 
        
        var cmpEvent = component.getEvent("EI_backToDepositHome");
        cmpEvent.setParams({
            showpropertyComp: true,
            rentAmount: component.get("v.rentAmount"),
            depositAmount: component.get("v.depositAmount"),
            amountToProtect: component.get("v.amountToProtect"),
            depositRecievedDate: component.get("v.depositRecievedDate"),
            tenancyStartDate: component.get("v.tenancyStartDate"),
            noOfTenants: component.get("v.noOfTenants"),
            depositReference: component.get("v.depositReference")
        });
        
        cmpEvent.fire();
       
        var v1 = document.getElementsByClassName("state-indicator");
          v1[1].classList.remove("active");
    },
    
    EI_backToTenantComp: function (component, event, helper) {
        component.set("v.showAddTenant", true);
        component.set("v.showSummary", false);
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        
        switch (button_Name) {
            case "genericError":
                component.set("v.genericError", false);
                break;
            case "tenantNumberError":
                component.set("v.tenantNumberError", false);
                break;
            case "rentAmountError":
                component.set("v.rentAmountError", false);
                break;
            case "depositAmountError":
                component.set("v.depositAmountError", false);
                break;
            case "amntToProtectError":
                component.set("v.amntToProtectError", false);
                break;
            case "amountCantBeLessThan1Error":
                component.set("v.amountCantBeLessThan1Error", false);
                break;    
        }
    },
    
});