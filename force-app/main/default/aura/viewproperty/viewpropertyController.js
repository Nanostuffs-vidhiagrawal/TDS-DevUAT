({
    doInit : function(component, event, helper) {
        // Get Country codes Picklist Values
       helper.fetchPhoneCodePicklist(component); 
        
        setTimeout(function(){ 
            component.set("v.showButtons",true);
             var currentUser = component.get("v.currentUser");
       
        if(currentUser.Contact.Job_role__c=='Deposit, property & dispute administrator' || currentUser.Contact.Job_role__c=='Deposit & property administrator'  || currentUser.Contact.Job_role__c=='Head office administrator' || currentUser.Contact.Job_role__c=='Account administrator' || currentUser.Contact.Additional_Permission__c=='Manage properties')
        {
            component.set("v.manageProperties",true);
        }  
            
             }, 800);
            helper.getProperty(component, event, helper);
        helper.getPropertyAllocations(component, event, helper);
       //                      }, 800);
       
        
        
    },
    removePopup: function (component, event, helper) {
        component.set("v.showRemoveDialog",false);
    },
    refreshLandlordList: function (component, event, helper){
    helper.getPropertyAllocations(component, event, helper);
    },
    getJointLandlord: function (component, event, helper) {
        var landlordRec = event.target.id;
      console.log('landlordRec'+landlordRec);
        component.set("v.landlordRemoveId",landlordRec);
       
        let action = component.get("c.getJointLand");
        action.setParams({
            propRec : component.get("v.property")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
        
            if (state == "SUCCESS") {
                  
                var result = response.getReturnValue();
                
               component.set("v.jointLandlordDetails",result);
                setTimeout(function(){ 
            	 $("#myModalRemoveLandlord").modal();
                    }, 500);
            }
        });
          $A.enqueueAction(action);
        
    },
    removePrimLandlord: function (component, event, helper) {
         
    },
    
    removeLandlord: function (component, event, helper) {
        var relation =  event.target.name;
        var jointLandlordId;
        var landlordRec
        if(relation == 'Prime'){
            jointLandlordId = event.target.id;
            landlordRec = component.get("v.landlordRemoveId");
        }
        else if(relation == 'Joint'){
           jointLandlordId = null; 
            landlordRec = event.target.id;
        }
         
          
        console.log('@@data '+jointLandlordId+' 1 '+landlordRec+' 2 '+relation);
        let action = component.get("c.removeLand");
        action.setParams({
            propAllocationid : landlordRec,
            relation: relation,
            jointLandlordId: jointLandlordId
        });
        console.log('action'+action);
        action.setCallback(this, function (res) {
            var state = res.getState();
            console.log('state'+state+' result '+res.getReturnValue());
            if (state == "SUCCESS") {
                
                var result = res.getReturnValue();
                 $("#myModalRemoveLandlord").modal('hide');
                console.log(result);
                 helper.getPropertyAllocations(component, event, helper);
              
            }
        });
          $A.enqueueAction(action);
        
    },
    ClickedNo: function (component, event, helper) {
        console.log("click no");
        component.set("v.removePrimLandlord",true);
       
        component.set("v.replaceLandlord",true);
        
    },
        searchKeyChange1: function (component, event, helper) {
        component.set("v.landlordDetails", "");
        var removeprime = component.get("v.removePrimLandlord");
        let searchField = component.find("searchField1").get("v.value");
        let action = component.get("c.searchlandlord");
        action.setParams({
            searchField: searchField,
            propRec: component.get("v.property"),
            status: removeprime
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state == "SUCCESS") {
                component.set("v.PrimarylandlordDetails", a.getReturnValue());
                var result = a.getReturnValue();
                console.log(result);
                console.log(JSON.stringify(result));
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
      primaryLandlord: function (component, event, helper) {
        let selectRecord = event.target.id;
         console.log('landlord selectRecord ## '+ selectRecord);
        let primarylandlord = component.get("v.PrimarylandlordDetails");
         console.log('landlord primarylandlord ## '+ primarylandlord);
        let selectedrecId = component.get("v.selectedjointlandlordID");
        let selectedrec = [];
        let selectedPrimarylandlord = component.get("v.selectedPrimarylandlord");
        if (selectedPrimarylandlord.length > 0) {
            if (selectedrecId.includes(selectedPrimarylandlord[0].Id)) {
                let index = selectedrecId.indexOf(selectedPrimarylandlord[0].Id);
                console.log("line 24" + index);
                selectedrecId.splice(index, 1);
                console.log("line 27");
            }
        }
        
        for (let i = 0; i < primarylandlord.length; i++) {
            if (primarylandlord[i].Id == selectRecord) {
                if (!selectedrecId.includes(selectRecord)) {
                     console.log("line 93 "+primarylandlord[i].Id, primarylandlord[i].FirstName);
                    selectedrec.push(primarylandlord[i]);
                    selectedrecId.push(selectRecord);
                }
            }
        }
         console.log('landlord selectedrec ## '+ selectedrec);
        var fullName = selectedrec[0].FirstName + " " + selectedrec[0].LastName;
         console.log("fullName",fullName);
        component.set("v.PrimarylandlordDetails", "");
        component.set("v.selectedPrimarylandlord", selectedrec);
        component.set("v.selectedjointlandlordID", selectedrecId);
           console.log('selectedrec ## '+ JSON.stringify(selectedrec));
       // component.find("v.searchField1").set("v.value",selectedrec[0].LastName);
       component.set("v.selectedValue",fullName);
        
    },
    handleEditProp: function (component, event, helper){
             console.log('test'+JSON.stringify(component.get("v.property")));
        var action = component.get("c.updatePropDetails");
       
        action.setParams({
            updtProperty : component.get("v.property")
        });
        
        action.setCallback(this, function (resResult) {
            var state = resResult.getState();
          //  console.log('state'+state+' result '+resResult.getReturnValue());
            if (state == "SUCCESS") {
                
                var result = resResult.getReturnValue();
              component.set("v.succeessmessage", true);
                 helper.getProperty(component, event, helper);
                     component.set("v.editPage",false);
            }
        });
          $A.enqueueAction(action);
    },
    handleSave: function (component, event, helper) {
        var removeprime = component.get("v.removePrimLandlord");
        var conRec = component.get("v.selectedPrimarylandlord");
        console.log('conRec'+conRec[0].Id+' prop '+component.get("v.property"));
        let action = component.get("c.replacePrimeLandlord");
        action.setParams({
            propRec : component.get("v.property"),
            conRec : conRec[0],
            status : removeprime
        });
        console.log('action'+action);
        action.setCallback(this, function (res) {
            var state = res.getState();
            console.log('state'+state+' result '+res.getReturnValue());
            if (state == "SUCCESS") {
                
                var result = res.getReturnValue();
                console.log(result);
                 helper.getPropertyAllocations(component, event, helper);
                component.set("v.replaceLandlord",false);
                component.set("v.removePrimLandlord",false);
        component.set("v.selectedPrimarylandlord","");
          component.set("v.selectedValue","");   
            }
        });
          $A.enqueueAction(action);
        
    },
    handleCancle: function (component, event, helper) {
          component.set("v.replaceLandlord",false);
        component.set("v.replaceLandlord",false);
        component.set("v.selectedPrimarylandlord","");
          component.set("v.selectedValue","");    
          component.set("v.editPage",false);
    },
    replaceLandlord: function (component, event, helper) {
        component.set("v.replaceLandlord",true);
    },
        parentPress2: function (component, event, helper) {
    $A.get('e.force:refreshView').fire();
   
    }, 
    navigateLandlord : function(component, event, helper) {
      //    helper.getMyLandlords(component, event, helper);
       component.set("v.showViewPage",true);
        component.set("v.fromParentComp",true);
         component.set("v.showLandlord",true);
        console.log('nav');
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceMy").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navServiceMy").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {}
            }); 
        }
    },
    navigateMyProp: function(component, event, helper) {
   component.set("v.showLandlord",false);
        component.set("v.fromParentComp",false);
              const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceMy").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                }
          
            });
        }
        
    },
    handleSearch : function(component, event, helper) {
          if (event.keyCode === 13) {
             helper.getMyLandlords(component, event, helper);
         }
    },
     handleClick : function(component, event, helper) {
        helper.getMyLandlords(component, event, helper);
       
    },
    statusCheck: function(component, event, helper) {
         console.log('Data1 ');
            var sel = document.getElementById("SelectItem");
    var selPickListValue = sel.options[sel.selectedIndex].value;
       // var selPickListValue = event.getSource().get("v.value");
          console.log('Data2 '+selPickListValue);
         var filteredList=[];
 var sObjectList = component.get("v.LandlordListView");
        console.log('Data3 '+JSON.stringify(sObjectList));
         console.log('Data33 '+sObjectList[0].Account_Status__c);
        
for(var i=0;i<sObjectList.length;i++){
     console.log(selPickListValue+' Data4 '+sObjectList[i].Account_Status__c);
            if(sObjectList[i].Account_Status__c == selPickListValue)
            {
                 console.log(selPickListValue+' Data45 '+sObjectList[i].Account_Status__c);
                 filteredList.push(sObjectList[i]); 
            }
              
        }
         console.log('Data44 '+filteredList);
        console.log('Data4 '+JSON.stringify(filteredList));
        if(filteredList.length>0){
         //   component.set("v.PaginationLandlordList",filteredList);
         var PaginationLandlordList = [];
         var pageSize = component.get("v.pageSizeLandlord");
                    var totalRecordsList = filteredList;
                    console.log('+++++++++totalRecordsList++++'+totalRecordsList);
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCountLandlord", totalLength);
                    component.set("v.startPageLandlord", 0);
                    component.set("v.endPageLandlord", pageSize - 1);
                    var PaginationLandlordList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (filteredList.length > i) {
                            PaginationLandlordList.push(filteredList[i]);
                        }
                    }console.log('+++++++++PaginationLandlordList++++'+JSON.stringify(PaginationLandlordList));
                    component.set("v.PaginationLandlordList", PaginationLandlordList);
                  //  console.log('++++++PaginationLandlordList+++++++'+component.get("v.PaginationLandlordList"));
                    component.set("v.selectedCount", 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCountLandlord", Math.ceil(totalLength / pageSize));
                    var xyz = getElementsByClassName("dataTables_empty");
                    for(i = 0; i < xyz.length; i++) {
                        xyz.style.visibility = 'hidden';
                    }
                    document.getElementsByClassName("dataTables_empty").style.visibility = 'hidden';
            
        }
          
    },
       navLandlordPage: function(component, event, helper) {
    var sObjectList = component.get("v.LandlordListView");
    var end = component.get("v.endPageLandlord");
    var start = component.get("v.startPageLandlord");
    var pageSize = component.get("v.pageSizeLandlord");
    //var whichBtn = event.getSource().get("v.name");
    //
    // check if whichBtn value is 'next' then call 'next' helper method
    if (event.target.id == "nextId") {
      component.set("v.currentPageLandlord", component.get("v.currentPageLandlord") + 1);
      helper.nextLandlord(component, event, sObjectList, end, start, pageSize);
    }
    // check if whichBtn value is 'previous' then call 'previous' helper method
    else if (event.target.id == "previousId") {
      component.set("v.currentPageLandlord", component.get("v.currentPageLandlord") - 1);
      helper.previousLandlord(component, event, sObjectList, end, start, pageSize);
    }
  },
    cancelRefresh : function(component, event, helper) {
      // helper.getPropertyAllocations(component, event, helper);
    },
    
    handleConfirmDialog: function(component, event, helper) {
         component.set('v.showConfirmDialog', true);
    },
    
    deleteProperty: function(component, event, helper) {
         var status = event.target.id;
        console.log('status '+status);
        helper.deleteProperty(component, event, helper,status);
    },
     archiveStatus: function(component, event, helper) {
          var hrefId =  event.target.id;
         component.set("v.propStatus",hrefId);
    },
    handleArchived : function(component, event, helper) {
        var status = event.target.id;
         helper.deleteProperty(component, event, helper,status);
    },
    handleEditLandlord: function(component, event, helper) {
       component.set("v.editPage",true);  
    },
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
    },
    
    getLandlordData: function(component, event, helper) {
        helper.getStatusPicklist(component, event);
        helper.getLandlordData(component, event);
     

    },
      regStatusChange : function (component, event, helper) {
         
             var selPickListValue = document.getElementById("regStId");
           console.log('ss '+selPickListValue);
            var regStatusCheck = selPickListValue.options[selPickListValue.selectedIndex].innerHTML;
       regStatusCheck = selPickListValue.value;
           console.log(' regStatusCheck '+regStatusCheck);
      //  var regStatusCheck = selPickListValue.options[selPickListValue.selectedIndex].value;
       
         //  console.log(selectedValue+' regStatusCheck '+regStatusCheck);
        if(regStatusCheck!='' && regStatusCheck!=null && regStatusCheck!=undefined)
        {
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
    
    updateLandlordData: function(component, event, helper) {
        helper.updateLandlordData(component, event,helper);
    },
    
    hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
             case "sucessmsg":
                component.set("v.succeessmessage", false);
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
            case "phonelength":
                component.set("v.phonelengthError", false);
                break;
            case "mobileNumber":
                component.set("v.mobileError", false);
                break;
            case "successmsg":
                component.set("v.successmessage", false);
                break;
        }
    },
    
    /* javaScript function for pagination */
  navigation: function(component, event, helper) {
    var sObjectList = component.get("v.LandlordList");
    var end = component.get("v.endPage");
    var start = component.get("v.startPage");
    var pageSize = component.get("v.pageSize");
    //var whichBtn = event.getSource().get("v.name");
    //
    // check if whichBtn value is 'next' then call 'next' helper method
    if (event.target.id == "nextId") {
      component.set("v.currentPage", component.get("v.currentPage") + 1);
      helper.next(component, event, sObjectList, end, start, pageSize);
    }
    // check if whichBtn value is 'previous' then call 'previous' helper method
    else if (event.target.id == "previousId") {
      component.set("v.currentPage", component.get("v.currentPage") - 1);
      helper.previous(component, event, sObjectList, end, start, pageSize);
    }
  },
    
    handleLinkToViewLandlord : function(component, event, helper){
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navServiceMy").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {id: event.target.id,
                        branchId : branchId}
            });
        }else{
            component.find("navServiceMy").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "mylandlords"
                },
                state: {id: event.target.id,}
            }); 
        }
    }
})