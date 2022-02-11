({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
    },
    handleClick : function(component, event, helper) {
        // var rac = component.get("v.searchText");
        //alert(rac);
        helper.eventhelp(component, event);
    },
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllAccounts");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        //alert(selectedHeaderCheck);
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listOfAllAccounts");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllAccounts[i].isChecked = true;
                component.set("v.selectedCount", listOfAllAccounts.length);
            } else {
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfAllAccounts", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
            
        }
    },
    
    getSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.listOfAllAccounts");
        //alert(allRecords);
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objAccount.Id);
            }
        }
       
     //helper.deleteSelectedHelper(component, event, selectedRecords);
      //  deleteSelectedHelper: function(component, event, selectedRecords) { 
      // alert(selectedRecords);
        var action = component.get('c.delproperty');
        
        // pass the all selected record's Id's to apex method 
        action.setParams({
            dellist: selectedRecords
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Property has been Deleted successfully."
                });
                toastEvent.fire();
                window.location.reload();
                console.log(state);
                if (response.getReturnValue() != '') {
                    // if getting any error while delete the records , then display a alert msg/
                    //   alert('The following error has occurred. while Delete record-->' + response.getReturnValue());
                } else {
                    console.log('check it--> delete successful');
                }
                // call the onLoad function for refresh the List view    
                 //   this.doInitHelper(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    ViewProperty: function(component, event, helper) {
        var clickedBtn = event.getSource().get("v.value");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          url: '/'+'viewproperty' + "?id=" + clickedBtn
        });
        urlEvent.fire();
        
        /*
        var clickedBtn = event.getSource().get("v.value");
        //console.log('mila'+ clickedBtn);
        //alert(clickedBtn);
        $A.createComponent("c:viewproperty",
                           {'strRecordId'  : clickedBtn},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "View Property Details",
                                       body: modalBody, 
                       	                showCloseButton: true,
                                       
                                   })
                               }
                           }); */
    },
  
      CreateProperty : function(component, event, helper) {
        $A.createComponent("c:PropertyCreatecomp", 
                           {},
                           function(result, status) {
                               if (status === "SUCCESS") {
                                   component.find('overlayLibDemo').showCustomModal({
                                       header: "Create New Property",
                                       body: result, 
                                       showCloseButton: true,
                                       cssClass: "mymodal", 
                                       closeCallback: function() {
                                           helper.doInitHelper(component, event); 
                                       }
                                   })
                               } 
                                           
                           });

    },
    doSave : function(component, event, helper) {
        var objChild = component.find("compB");
        helper.PassVariable(component, event, helper);
        if (
            objChild.get("v.PostCode") == "" ||
            typeof objChild.get("v.PostCode") == "undefined" ||
            objChild.get("v.AddressLine1") == "" ||
            typeof objChild.get("v.AddressLine1") == "undefined" ||
            objChild.get("v.Town") == "" ||
            typeof objChild.get("v.Town") == "undefined" ||
            objChild.get("v.Country") == "" ||
            typeof objChild.get("v.Country") == "undefined" ||
            objChild.get("v.County") == "" ||
            typeof objChild.get("v.County") == "undefined"
        ) {
            alert("Please fill Address");
        }
        else{            
            
            var action = component.get("c.saveproperty");
            
            action.setParams({
                "prop": component.get("v.Propobj"),
                street: component.get("v.Street"),
                city: component.get("v.Town"),
                postcode: component.get("v.PostCode"),
                country: component.get("v.Country"),
                county: component.get("v.County")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Property has been created successfully."
                    });
                    toastEvent.fire();
                    component.find("overlayLibDemo1").notifyClose();
                    window.location.reload();
                }
                /*  else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Invalid details!",
                        "message": "Please fill correct values."
                    });
                    toastEvent.fire();
               component.find("overlayLibDemo1").notifyClose();
                }  */
                });
            
            $A.enqueueAction(action);
            
        }
    },
    
    parentPress: function (component, event, helper) {
        helper.PassVariable(component, event, helper);
        //   alert("Method Called from Child " + objChild.get('v.AddressLine1'));
    },
})