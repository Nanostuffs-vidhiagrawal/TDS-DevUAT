({
    removeZero: function(component, event, helper) {
        
        var edValue = event.getSource().get("v.value");
        function trimNumber(s) {
            while (s.substring(0,1) == '0' && s.length>=1 && !s.includes(".")) { s = s.substring(1,9999); }
            return s;
        }
        var trimeVal = trimNumber(edValue);
        
        event.getSource().set("v.value",trimeVal);
        
    },
    
    parentPress: function(component, event, helper) {
        helper.PassVariable(component, event, helper);
        //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
    },
    
    goBack : function(component, event, helper) {
        window.history.back();
    },
    
    depositSummary: function(component, event) {
        
        var retdepositId= component.get("v.newDepositId");
        //     alert('clicked '+retdepositId);
        if(retdepositId != null){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "depositsummarypage"
                },
                state: {id: retdepositId}
            });
        }
        
    },
    
    clickCreate: function(component, event, helper) {
        var startDate = component.get("v.dateToday");
        var rentAmount = component.find("Rent").get("v.value");
        
        // var rentAmount = document.getElementById("Rent").value
        //   alert(rentAmount+" startDate "+startDate+rentAmount);
        var objChild = component.find("compB");
        // alert('objChild.get("v.PostCode") '+objChild.get("v.PostCode")+'county '+objChild.get("v.County")+' addressLine1 '+objChild.get("v.AddressLine1")+' Town ' +objChild.get("v.Town")+'country'+objChild.get("v.Country"));
        if (
            objChild.get("v.PostCode") == "" ||
            typeof objChild.get("v.PostCode") == "undefined" ||
            objChild.get("v.AddressLine1") == "" ||
            typeof objChild.get("v.AddressLine1") == "undefined" ||
            objChild.get("v.Town") == "" ||
            typeof objChild.get("v.Town") == "undefined" ||
            objChild.get("v.Country") == "" ||
            typeof objChild.get("v.Country") == "undefined" ||
            startDate == '' ||
            typeof startDate == "undefined" ||
            rentAmount == '' ||
            typeof rentAmount == "undefined" 
        ) {
            alert("Please fill Details");
        } else {
            
            var action = component.get("c.insertProperties");
            action.setParams({
                
                street: objChild.get("v.AddressLine1"),
                city: objChild.get("v.Town"),
                postcode: objChild.get("v.PostCode"),
                country: objChild.get("v.Country"),
                county: objChild.get("v.County")
                //   startDate : startDate,
                // rentAmount : rentAmount
            });
            
            action.setCallback(this, function (a) {
                
                var state = a.getState();
                var errors = a.getError();
                
                if (state == "SUCCESS") {
                    var returnResult = a.getReturnValue();
                    //    alert(returnResult);
                    if (returnResult.includes("Successfully Created")) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success",
                            message: "New tenancy address has been added successfully and now you can add the landlord",
                            duration: " 5000",
                            key: "info_alt",
                            type: "success",
                            mode: "pester"
                        });
                        toastEvent.fire();
                        const base = returnResult.split("=")
                        
                        var propertyId = base.slice(-2,-1);
                        //  alert(propertyId);
                        component.set("v.PropertyId",propertyId);
                        setTimeout(function(){   component.set("v.ShowLandlord",true);
                                              
                                             }, 1000);
                        
                    } else {
                        component.find("notifLib").showNotice({
                            variant: "Warning",
                            header: "Oops!",
                            message:
                            "We encountered a problem. For help,Please contact your administrator.",
                            closeCallback: function () {}
                        });
                    }
                }
                else{
                    component.find("notifLib").showNotice({
                        variant: "Warning",
                        header: "Oops!",
                        message:
                        "We encountered a problem. For help,Please contact your administrator.",
                        closeCallback: function () {}
                    });
                }
                
            });
            $A.enqueueAction(action);
            
        }
    },
    
    clickYes: function(component, event, helper) {
        var ys =  document.getElementById("property_yes");
        var no =   document.getElementById("property_no");      
        $A.util.addClass(ys, "clickButton");
        $A.util.removeClass(no, "clickButton");
        
        component.set("v.displayYesSection",true);
        component.set("v.displayNoSection",false);
        
        //component.set("v.flaguserInput", true);
        //component.set("v.defaultflag", true);
    },
    
    clickNo: function(component, event, helper) {
        var ys =  document.getElementById("property_yes");
        var no =   document.getElementById("property_no");      
        $A.util.addClass(no, "clickButton");
        $A.util.removeClass(ys, "clickButton");
        
        component.set("v.displayYesSection",false);
        component.set("v.displayNoSection",true);
        component.set("v.Properties", "");
        //component.set("v.defaultflag", true);
        //component.set("v.flaguserInput", false);
    },
    
    searchKeyChange: function(component, event) {
        console.log('++++++++searchKeyChange++++++');
        var searchField = component.find("searchField").get("v.value");
        console.log('++++++++searchField++++++ '+searchField);
        var action = component.get("c.getProperties");
        action.setParams({
            searchField: searchField
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state == "SUCCESS") {
                component.set("v.Properties", a.getReturnValue());
                var result = a.getReturnValue();
                if (a.getReturnValue() != null) {
                    component.set("v.Continuebtnflag", false);
                } else {
                    component.set("v.Continuebtnflag", true);
                }
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    
    selectedRecord: function(component, event, helper) {
        component.set("v.selectedPrimarylandlord", null);
        let selectRecord = event.target.id;
        let recordID = selectRecord.slice(0, 18);
        let prop = component.get("v.Properties");
        let selectedrec = [];
        for (let i = 0; i < prop.length; i++) {
            if (prop[i].recId == recordID) {
                component.set("v.Livedeposit", prop[i].livedeposit);
                component.set("v.selecedPrimeLandlord", prop[i].primaryLandlord);
                selectedrec.push(prop[i].proprtyrec);
            }
        }
        component.set("v.propertySelcted",true);
        component.set("v.selectedProperty", selectedrec);
        console.log('++++++selectedrec++++++'+JSON.stringify(selectedrec))
        component.set("v.Properties", "");
        component.find("propertyContinuetolandlordBtn").set("v.disabled", false);
        
    },
    
    goBack : function(component) {
        window.history.back();
    },
    
    showSection : function(cmp, evt) {
        const whichButton = evt.getSource().get("v.label");
        switch(whichButton) {
            case "Yes":
                console.log("yes");
                cmp.set("v.showNoSection",false);
                break;
            case "No":
                console.log("no");
                break;
            default:
                alert(`Something Unexpected Happened`);
        } 
    }, 
    
    SubmitwithoutLandlord: function(component, event, helper) {
        helper.SubmitDetailsWithoutLandlord(component, event,helper);
    }, 
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
		
        switch (button_Name) {
            case "StartDate":
                component.set("v.startDateError", false);
                break;
            case "Property":
                component.set("v.propertyError", false);
                break;
            case "RentAmount":
                component.set("v.rentError", false);
                break;
            case "finalError":
                component.set("v.finalError", false);
                break;
            case "amountCantBeLessThan1Error":
                component.set("v.amountCantBeLessThan1Error", false);
                break;       
        }
    },
    
})