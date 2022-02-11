({
    fetchUserData: function(component,event,helper){
        
        console.log('load2');
         var actions = [
      { label: "View User", name: "view_user" }
      // { label: 'Suspend User', name: 'suspend_user' }
    ];

    component.set("v.columns", [
      { label: "Full Name", fieldName: "fullName", type: "text" },
      { label: "Active", fieldName: "IsActive", type: "boolean" },
      { type: "action", typeAttributes: { rowActions: actions } }
    ]);

    var actionload = component.get("c.getHeadOfficeUsers");
         console.log('actionload '+actionload);
    actionload.setCallback(this, function (response) {
      var state = response.getState();
       console.log(`state=> ${state}`);
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
            console.log("result 123:" + JSON.stringify(result));
        if (result.length > 0) {
          component.set("v.listOfAllusers", result);
          var pageSize = component.get("v.pageSize");
          var totalRecordsList = result;
          var totalLength = totalRecordsList.length;
          component.set("v.totalRecordsCount", totalLength);
          component.set("v.startPage", 0);
          component.set("v.endPage", pageSize - 1);
          var PaginationLst = [];
          for (var i = 0; i < pageSize; i++) {
            if (component.get("v.listOfAllusers").length > i) {
              PaginationLst.push(result[i]);
            }
          }
          component.set("v.houserlist", PaginationLst);
          component.set("v.selectedCount", 0);
          //use Math.ceil() to Round a number upward to its nearest integer
          component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        }
		else {
          // if there is no records then display message
          component.set("v.bNoRecordsFound", true);
        }
         //component.set("v.houserlist", result);
        
       
        result.forEach(
          (row) =>
            (row.fullName =
              row.Contact.Salutation + " " + row.FirstName + " " + row.LastName)
        );
        // console.log("result :" + JSON.stringify(result));
        if (result == "" || result == [] || result.length == 0) {
          component.set("v.dataTableHasRecord", false);
        } else {
          component.set("v.dataTableHasRecord", true);
          component.set("v.data", result);
        }
      } else if (state === "ERROR") {
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
         $A.enqueueAction(actionload);
    let action2 = component.get("c.getAccountDetails");
    action2.setCallback(this, function (response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        let result = response.getReturnValue();
        if (result) {
          component.set("v.accName", result.Name);
          component.set("v.accId", result.Id);
        }
      } else if (state === "ERROR") {
        let errors = response.getError();
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
   
   // $A.enqueueAction(action2);
        
    },
    getAdditionalPerm: function(component,event,helper){
   var action = component.get("c.getJobRoles");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
         console.log(result);
        var permissionmap = [];

            var plValues = [];

        for (var key in result[3]) {
      
          permissionmap.push({ key: key, value: result[3][key] });
             plValues.push({
                        label: key,
                        value: key
                    });
        }
      
            component.set("v.permissionmap", permissionmap);
           component.set("v.permissionList", plValues);
      }
    });
    $A.enqueueAction(action);
},
  fetchData: function (cmp, fetchData, numberOfRecords) {
    var fakeDataCmp = cmp.find("datafaker"),
      dataPromise = this.mockdataLibrary.lightningMockDataFaker(
        fetchData,
        numberOfRecords
      );

    dataPromise.then(
      $A.getCallback(function (results) {
        cmp.set("v.data", results);
      })
    );
  },
  removeBook: function (cmp, row) {
    var rows = cmp.get("v.data");
    var rowIndex = rows.indexOf(row);

    rows.splice(rowIndex, 1);
    cmp.set("v.data", rows);
  },
    
 // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                    Paginationlist.push(sObjectList[i]);

                }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.houserlist', Paginationlist);
    },
   // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
              
                    Paginationlist.push(sObjectList[i]); 
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.houserlist', Paginationlist);
    },
    
     fetchPhoneCodePicklist : function(component, event, helper){
        var action = component.get("c.getPhoneCodePiclistValues");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.phoneCodePicklist", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    }
    
});