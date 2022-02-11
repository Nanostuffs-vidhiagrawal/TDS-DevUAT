({
    init: function (cmp,event) {
     var currentTime = new Date();
     var year = currentTime.getFullYear();
     var lastyears = year-40;
     var items = [];
     /*   for (var i =lastyears; i < year+1; i++) {
            var item = {
                "label": i ,
                "value": i.toString()
            };
            items.push(item);
        }*/
         for (var i =year; i > lastyears-1; i--) {
            var item = {
                "label": i ,
                "value": i.toString()
            };
            items.push(item);
        }
        
        cmp.set("v.year", items);
    },
    
	selectmonth: function (cmp, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
      //  alert("Option selected with value: '" + selectedOptionValue + "'");
         cmp.set("v.selectedmonth" ,selectedOptionValue);
    },
    
        selectyear: function (cmp, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        //alert("Option selected with value: '" + selectedOptionValue + "'");
         cmp.set("v.selectedyear" ,selectedOptionValue);
    },
    
    showdeposit : function (component, event,helper) {
        var isValid;
        var dan = component.get("v.dan");
        var postcode = component.get("v.postcode");
        var selectedmonth = component.get("v.selectedmonth");
        var selectedyear = component.get("v.selectedyear");
        var depositamount = component.get("v.depositamount");
        var surname = component.get("v.surname");
        if(dan != undefined && dan != "" && dan != null){
            if(dan.startsWith('DAN')){
                console.log("starts with DAN => " + dan);
            }
            else{
                console.log("not starts with DAN => " + dan);
                dan = 'DAN'+dan;
                console.log("add DAN as prefix => " + dan);
                component.set("v.dan", dan);
            }
        }
        if (postcode == undefined || postcode == "" || postcode == null) {  
            component.set("v.postcodeError",true);    
            isValid = false;
        }
		else{
			component.set("v.postcodeError",false);
              isValid = true;
		}
        
        if (selectedmonth == undefined || selectedmonth == "" || selectedmonth == null || selectedmonth == "Month") {  
            component.set("v.selectedmonthError",true);    
            isValid = false;
        }
		else{
			component.set("v.selectedmonthError",false);
            isValid = true;
		}
        if (selectedyear == undefined || selectedyear == "" || selectedyear == null || selectedyear == "Year") {  
            component.set("v.selectedyearError",true);    
            isValid = false;
        }
		else{
			component.set("v.selectedyearError",false);
            isValid = true;
		}
        
       
        if (depositamount == undefined || depositamount == "" || depositamount == null) {  
            component.set("v.depositamountError",true);    
            isValid = false;
        }
		else{
			component.set("v.depositamountError",false);
            isValid = true;
		}
        
        if (surname == undefined || surname == "" || surname == null) {  
            component.set("v.surnameError",true);    
            isValid = false;
        }
		else{
			component.set("v.surnameError",false);
            isValid = true;
		}
   /*  var allValid = component.find("mandatory").reduce(function (validFields,inputCmp) {
        inputCmp.reportValidity();
        inputCmp.set('v.validity',{valid:false,badInput:true});    
        return validFields && inputCmp.checkValidity();
        }, true);*/
        
        if(isValid){
            
             var action = component.get("c.getdepositdetails");
            action.setParams({
                    DAN:component.get("v.dan"), 
                    postcode:component.get("v.postcode"),
                    month:parseInt(component.get("v.selectedmonth")),
                    year:parseInt(component.get("v.selectedyear")),
                    depositamount:parseInt(component.get("v.depositamount")),
                    surname:component.get("v.surname")
                    
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    
                    if (state === "SUCCESS") {
                       // alert('line-->58');
                    console.log('line-->58' + JSON.stringify(response.getReturnValue()));   
                      component.set("v.selecteddeposit",response.getReturnValue());
                    }
                    else if (state === "INCOMPLETE") {
                        alert('line-->63');
                    }
                        else if (state === "ERROR") {
                           alert('line-->66');
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    
                                    console.log("Error message: " + JSON.stringify(errors[0].message)
                                               );
                                }
                            } else {
                                alert('line-->75');
                                console.log("Unknown error");
                            }
                        }
                });
                
                $A.enqueueAction(action);
        } 
    },
    
    linkdeposit : function (component, event,helper) {
    var getselecteddeposit = component.get("v.selecteddeposit");
    var action = component.get("c.addtenanttodeposit");
        action.setParams({ 
         selecteddeposit : JSON.stringify(getselecteddeposit) 
        });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
               console.log("From server: " + response.getReturnValue());
               /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Deposit linked successfully."
                });
                toastEvent.fire();*/
               /* var address = "https://devuat-thedisputeservice.cs87.force.com/Sds";
                var domain = window.location.origin;
                var urlEvent = $A.get("e.force:navigateToURL");
                console.log(urlEvent);
                urlEvent.setParams({
                    url: address 
                });
                urlEvent.fire(); */
                
                component.find("navService").navigate({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "home"
                    },
                    state: {}
                });
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
 
        // optionally set storable, abortable, background flag here
 
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);       
    },
    goBack: function(component, event, helper) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "home"
            },
            state: {}
        });
    },
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
			case "postcode":
                component.set("v.postcodeError", false);
                break;
            case "year":
                component.set("v.selectedyearError", false);
                break;
            case "month":
                component.set("v.selectedmonthError", false);
                break;
            case "depositamount":
                component.set("v.depositamountError", false);
                break;
            case "surname":
                component.set("v.surnameError", false);
                break;
            
        }
    },

})