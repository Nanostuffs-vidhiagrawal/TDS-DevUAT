({
    refreshDatatableHelper: function (component, event) {
        let selectedValue = component.find("branchType").get("v.value");
       // let selectedValue = event.getParam("value");
        console.log(`line 4 ${selectedValue}`);
        var action = component.get("c.getfilteredBranch");
        action.setParams({
            "branchStatus": selectedValue
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(`state=> ${state}`);
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result == "") {

                    component.set("v.recordFound", false);
                } else {

                    component.set("v.recordFound", true);
                    console.log('result :' + JSON.stringify(result));
                    result.forEach(row => row.completeAddress = row.Address__c + ' ' + row.Address__c + ' ' + row.Postcode__c);
                    console.log('result :' + JSON.stringify(result));
                    component.set("v.data", result);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log(`${errors}`);
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
        $A.enqueueAction(action);

    },
    
    // navigate to next pagination record set
  next: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = end + 1; i < end + pageSize + 1; i++) {
      if (sObjectList.length > i) {
        {
          Paginationlist.push(sObjectList[i]);
        }
      }
      counter++;
    }
    start = start + counter;
    end = end + counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.branchlist", Paginationlist);
  },
  // navigate to previous pagination record set
  previous: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = start - pageSize; i < start; i++) {
      if (i > -1) {
        {
          Paginationlist.push(sObjectList[i]);
        }
        counter++;
      } else {
        start++;
      }
    }
    start = start - counter;
    end = end - counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.branchlist", Paginationlist);
  }
  
})