({
         doneWaiting: function(component, event, helper) {
        setTimeout(function(){  component.set("v.PageSpinner",false); 
                              
                             }, 1200);
    },
  init: function (component, event, helper) {
    var actions = [
      { label: "View/Edit Branch", name: "view_edit_branch" },
      { label: "Login As Branch", name: "login_as_branch" }
    ];
    component.set("v.columns", [
      { label: "Branch Name", fieldName: "Branch_Name__c", type: "text" },
      { label: "Address", fieldName: "completeAddress", type: "text" },
      { label: "Active", fieldName: "Is_Active__c", type: "boolean" },
      { type: "action", typeAttributes: { rowActions: actions } }
    ]);

    var action = component.get("c.getBranchList");
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(`state=> ${state}`);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
		console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
      if (result.length > 0) {
          component.set("v.listOfPropertyAlocations", result);
          var pageSize = component.get("v.pageSize");
          var totalRecordsList = result;
          var totalLength = totalRecordsList.length;
          component.set("v.totalRecordsCount", totalLength);
          component.set("v.startPage", 0);
          component.set("v.endPage", pageSize - 1);
          var PaginationLst = [];
          for (var i = 0; i < pageSize; i++) {
            if (component.get("v.listOfPropertyAlocations").length > i) {
              PaginationLst.push(result[i]);
            }
          }
          component.set("v.branchlist", PaginationLst);
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
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
       setTimeout(function(){
       var currentUser = component.get("v.currentUser");
    
      if( currentUser.Contact.Job_role__c=='Head office administrator' )
        {
            component.set("v.manageBranches",true);
        }
             }, 1000);
  },
      /* javaScript function for pagination */
  navigation: function(component, event, helper) {
    var sObjectList = component.get("v.listOfPropertyAlocations");
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
     	addNewUser:function (component, event, helper) {
        //  var branchid = currentURL.split("id=")[1]; 
        var branchid =component.get("v.branchId");
      //  alert(branchid);
   
           component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "createbranchuser"
                }
            });
        
        },
    updatebranch:function (component, event, helper) {
       var branchid = event.getSource().get("v.value"); 
           var address = "/branches/managebranch";
        var domain = window.location.origin;

        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
          url: address + "?id=" + branchid
        });
        urlEvent.fire();        
        
    },    

    logintobranch:function (component, event, helper) {
 
        var branchid = event.getSource().get("v.value"); 
        
        event.preventDefault();

        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"viewdeposit?branchId="+branchid;
        window.location.replace(urlRedirect);
        return false;
     /*      var address = "/viewdeposit";
        var domain = window.location.origin;

        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
          url: address + "?branchId=" + branchid
        });
        urlEvent.fire();        
          setTimeout(function(){ 
          window.location.reload();
          
          }, 500);*/
        // window.location.replace("http://www.w3schools.com");
    },
    
  handleRowAction: function (component, event, helper) {
    var action = event.getParam("action");
    var row = event.getParam("row");
console.log('action'+action);
    switch (action.name) {
      case "view_edit_branch":
        var address = "/branches/managebranch";
        var domain = window.location.origin;

        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
          url: address + "?id=" + row.Id
        });
        urlEvent.fire();

        break;
      case "login_as_branch":
        // alert("Showing Details: " + JSON.stringify(row));
        let navService = component.find("navService");
        let pageReference = {
          type: "standard__namedPage",
          attributes: {
            pageName: "home"
          },
          state: {
            branchId: row.Id
          }
        };
        navService.navigate(pageReference);
        break;
    }
  },

  addNewBranch: function (component, event, helper) {
     // alert('line-->84');
    //var selectedVal = component.find("branchType").get("v.value");

    var modalBody;
    $A.createComponent(
      "c:EI_createNewBranch",
      {
       // selectedVal: selectedVal
      },
      function (content, status) {
        if (status === "SUCCESS") {
          modalBody = content;
          component.find("overlayLib").showCustomModal({
            header: "Branch Details",
            body: modalBody,
            showCloseButton: true,
            cssClass: "mymodal",
            closeCallback: function () {
              console.log("You closed the alert!");
            }
          });
        }
      }
    );
  },
    
    addNewBranches: function (component, event, helper) {
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "createnewbranch"
            },
            state: {}
    });
    },

  refreshDatatable: function (component, event, helper) {
    helper.refreshDatatableHelper(component, event);
  },

/*  refreshPage: function (component, event, helper) {
    // alert("Event Fired");
  //  var selectedValue = event.getParam("selectedVal");
    // alert("selectedValue=>" + selectedValue);
    // component.find("branchType").set("v.value", "all");
    component.find("branchType").set("v.value", selectedValue);
    helper.refreshDatatableHelper(component, event);
  }*/
});