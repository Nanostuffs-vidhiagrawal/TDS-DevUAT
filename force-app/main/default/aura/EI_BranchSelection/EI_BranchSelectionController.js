({
	 init: function (component, event, helper) {
 component.set("v.enableNextButton", true);
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
  },
    select: function (component, event, helper) {
       var selectId = event.currentTarget.value;
       console.log('selectId '+selectId);
      component.set("v.branchId", selectId);
      component.set("v.enableNextButton", false);      
    },
   // branchId
    nextToHomePage: function (component, event, helper) {
        
        	var  branchId= event.getSource().get("v.value");
         console.log('branchId '+branchId);
         event.preventDefault();
 		
        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"viewdeposit?branchId="+branchId;
    	 console.log('urlRedirect '+urlRedirect);
        window.location.replace(urlRedirect);
        return false;
        
 	/*	var  branchId= event.getSource().get("v.value");
         console.log('branchId '+branchId);
        if(branchId != null){
            component.find("navService").navigate({
                type: "standard__namedPage",
                attributes: {
                    pageName: "viewdeposit"
                },
                state: {branchId: branchId,
                        branchUser: true}
            });
        }else{
            component.find("navService").navigate({
                type: "standard__namedPage",
                attributes: {
                    pageName: "home"
                },
                state: {}
            });
        }*/
        
    },
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
  }
})