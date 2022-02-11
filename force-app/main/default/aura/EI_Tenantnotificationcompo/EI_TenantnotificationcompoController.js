({
	init : function(component, event, helper) {
        var action = component.get("c.CaseStatus");
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(`state=> ${state}`);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
		console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
          component.set("v.totalRecordsCount",result);
          console.log('Size123='+result);
          
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
    $A.enqueueAction(action);
  }

	
})