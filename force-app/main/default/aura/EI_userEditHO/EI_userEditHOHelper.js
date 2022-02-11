({
  init: function (component, event) {
    let userId = component.get("v.userId");
    let action = component.get("c.getUserDetails");
    action.setParams({ userId: userId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        let result = response.getReturnValue();
        if (result) {
          component.set("v.con", result.usr.Contact);
          // console.log("result.ut.usr.IsActive:", result.usr.IsActive);
          let items = [];
          let selectedValues = [];
          for (let key in result.bum) {
            let item = {
              label: result.bum[key].Branch__r.Branch_Name__c,
              value: result.bum[key].Branch__r.Id
            };
            items.push(item);
            selectedValues.push(item.value);
          }
          component.set("v.isActive", result.usr.IsActive);
          component.set("v.options", items);
          component.set("v.selectedValues", selectedValues);
          component.set("v.values", selectedValues);
          component.set("v.oldselectedValues", selectedValues);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
          }
        }
      }
    });
    var action2 = component.get("c.getJobRoles");
    action2.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var jobRoleMap = [];
        for (var key in result[2]) {
               jobRoleMap.push({ key: 1, value: 'Head office administrator' });
          jobRoleMap.push({ key: key, value: result[2][key] });
        }
        component.set("v.jobRoleMap", jobRoleMap);
       
         var permissionmap = [];
        for (var key in result[3]) {
         
          permissionmap.push({ key: key, value: result[3][key] });
          
        }
        component.set("v.permissionmap", permissionmap);
          
          
        var salutationMap = [];
        for (var key in result[1]) {
          salutationMap.push({ key: key, value: result[1][key] });
        }
        component.set("v.salutationMap", salutationMap);
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
          }
        }
      }
    });
    let accountId = component.get("v.accountId");
    var action3 = component.get("c.getBranchesUnderAccount");
    action3.setParams({ accountId: accountId });
    action3.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        let items = [];
        for (var key in result.branchList) {
          items.push({
            label: result.branchList[key].Branch_Name__c,
            value: result.branchList[key].Id
          });
        }
        component.set("v.options", items);
      } else if (state === "ERROR") {
        var errors = response.getError();
        // If error then check error type
        if (errors) {
          if (errors[0] && errors[0].message) {
          }
        }
      }
    });

    $A.enqueueAction(action);
    $A.enqueueAction(action2);
    $A.enqueueAction(action3);
  }
});