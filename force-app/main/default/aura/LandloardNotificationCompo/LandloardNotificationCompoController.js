({
  init: function (component, event, helper) {
  
       helper.doInitHelper(component, event,helper);
  /* console.log("##In Init...");
    var action = component.get("c.getLandLordStatus");
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(`state=> ${state}`);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
		console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
          component.set("v.totalRecordsCount",result);
          console.log('Size='+result);
          
     if (result.length > 0) {
          component.set("v.listOfNotification", result);
          var pageSize = component.get("v.pageSize");
          var totalRecordsList = result;
          var totalLength = totalRecordsList.length;
          component.set("v.totalRecordsCount", totalLength);
          component.set("v.startPage", 0);
          component.set("v.endPage", pageSize - 1);
          var PaginationLst = [];
          for (var i = 0; i < pageSize; i++) {
            if (component.get("v.listOfNotification").length > i) {
              PaginationLst.push(result[i]);
            }
          }
          component.set("v.depositeList", PaginationLst);
          component.set("v.selectedCount", 0);
          //use Math.ceil() to Round a number upward to its nearest integer
          component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        }
		else {
          // if there is no records then display message
          component.set("v.bNoRecordsFound", true);
        }
        }
        else if (state === "ERROR") {
        var errors = response.getError();
        console.log(`${errors}`);
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: 46789" + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);*/
  },
    
    onDepositePageController :function(component, event, helper){
         console.log('Line no 11--->',event.target.id);
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id: event.target.id
            }
        });
        
        
    },
    
     viewRevewTransferredDeposits : function(component, event, helper) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "reviewtransfer"
            },
            state: {
                id: event.target.id
            }
        });
        
        
    },
        
    
     reviewChangeOver : function(component, event, helper) {
      //  var depositId = event.getSource().get("v.name");  
           var depositId = event.target.id;
        if(typeof depositId != 'undefined'){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "tenantchangeoverresponsebyagll"
                },
                state: {
                    id : depositId,
                    tchange : true
                }
            });
        }
    },
    
     backController: function(component, event, helper) {
      window.history.back();
  	},
    
    navigation :  function(component, event, helper){
         var sObjectList = component.get("v.depositeList");
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
        
    }
     });