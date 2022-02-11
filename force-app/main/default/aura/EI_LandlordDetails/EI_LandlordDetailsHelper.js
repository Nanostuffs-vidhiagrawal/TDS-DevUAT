({
	getlandlordstatus : function(component, event) {
        var action = component.get("c.getstatus");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
              //  console.log("result :" + JSON.stringify(result));
                var statusMap = [];
                for(var key in result){
                    statusMap.push({label: result[key], value: key});
                }
                component.set("v.statusMap", statusMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    takesalutation : function(component, event) {
    var action = component.get("c.takesalutation");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log(result);
        var salutationMap = [];
        for (var key in result[0]) {
          salutationMap.push({ key: key, value: result[0][key] });
        }
        component.set("v.salutationMap", salutationMap);
      }
    });

    $A.enqueueAction(action);   
       
   },
    
    checkDuplicacy: function (component, landlorddata) {
        //alert(landlorddata.Id + landlorddata.Email + landlorddata.FirstName + landlorddata.LastName);
        var action = component.get("c.checkDuplicateRecord");
        action.setParams({
            conId: landlorddata.Id,
            email: landlorddata.Email,
            firstname: landlorddata.FirstName, 
            surname: landlorddata.LastName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //alert(state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                var duplicateValue = [];
                for ( var key in result ) {
                    duplicateValue.push({val:result[key], key:key});
                }
                var key = duplicateValue[0].key;
                var recValue = duplicateValue[0].val;
                //alert("key => " + key);
                if (key == "Duplicate Email") {
                    component.set("v.isDuplicateEmail",true);
                    component.set("v.duplicateEmailError",true);
                } 
                else if(key == "Duplicate Name"){
                    component.set("v.isDuplicateEmail",true);
                    component.set("v.duplicateNameError", true);
                    component.set("v.duplicateRecord", recValue);
                }
                else {
                    component.set("v.isDuplicateEmail",false);
                    component.set("v.duplicateEmailError",false);
                    component.set("v.duplicateNameError", false);
                }
            } else if (state == "ERROR") {
                var errors = response.getError();
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
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
})