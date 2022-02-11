({
    getAllPropPostCode : function(component,event,helper) {
        console.log('getPostCode');
        
        let action = component.get("c.getPostCode");
        action.setCallback(this, function (a) {
            var state = a.getState();
            console.log('seeestate '+state);
            if (state == "SUCCESS") {
                var result = a.getReturnValue();
                component.set("v.propList", a.getReturnValue());
                
                console.log('postCode '+result);
                
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    
    searchHelper : function(component,event,helper) {
        console.log('seee');
        component.set("v.landlordDetails", "");
        let searchField = '';
        let action = component.get("c.getlandlord");
        action.setParams({
            searchField: searchField
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            console.log('seeestate '+state);
            if (state == "SUCCESS") {
                component.set("v.PrimarylandlordDetails", a.getReturnValue());
                var result = a.getReturnValue();
                console.log(result);
                
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    
    chDate : function(component) {
        //   alert('recievedDateYMD');   
        let allDateValid = false; 
        
        let arraydate = [];
        //Grab Date Elements   
        let depositRecievedDate = document.getElementById("depositRecievedDate").value;
        let depositRecievedMonth = document.getElementById("depositRecievedMonth").value;
        let depositRecievedYear = document.getElementById("depositRecievedYear").value;
        let receivedDate = depositRecievedDate+'-'+depositRecievedMonth+'-'+depositRecievedYear;
        let recievedDateYMD = depositRecievedYear+'-'+depositRecievedMonth+'-'+depositRecievedDate;
        
        //    alert(recievedDateYMD);   
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
    
    navService : function(component) {
        console.log('Line 103');
        var IsaddDeposit = window.location.pathname;
        if(IsaddDeposit.includes("adddeposit")){
            console.log("Do not navigate");
            var cmpEvent = component.getEvent("EI_PopulateProperty"); 
            //Set event attribute value
            cmpEvent.setParams({"switchYes" : true,"depositCreated" : false,
                                newSelectedProperty: component.get("v.selectedProperty")
                               }); 
            cmpEvent.fire();
            component.set("v.addressError",false);
            component.set("v.primaryError",false);
            
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {}
            });
        }
    },
    
    navToLandlord : function(component) {
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "addlandlord"
            },
            state: {}
        });       
    },
    
    getError:function (component, event, helper) {        
        
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
                //console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
                component.set("v.errorList",response.getReturnValue());
                var   errorList= component.get("v.errorList");  
                var userErr;                
                for(var i=0; i<errorList.length; i++){
                    // console.log("line-->9  " +errorList[i].MasterLabel );
                    // console.log("line-->9  " +errorList[i].Error_Message__c );
                    if(errorList[i].MasterLabel === 'Add Primary Landlord'){
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.LandlordErrorNew",userErr);
                    }
                    else if(errorList[i].MasterLabel === 'Add Property Address'){
                        userErr = errorList[i].Error_Message__c;
                        component.set("v.PropertyErrorNew",userErr);
                    } 
                        else if(errorList[i].MasterLabel === 'Enter Postcode'){
                            userErr = errorList[i].Error_Message__c;
                            component.set("v.PostcodeErrorNew",userErr);
                        } 
                            else if(errorList[i].MasterLabel === 'Post Code Invalid'){
                                userErr = errorList[i].Error_Message__c;
                                
                                component.set("v.PostcodeErrorNew",userErr);
                            } 
                    
                }
            }
            else{
                //console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }
    
})