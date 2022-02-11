({
    takesalutation : function(component, event) {
        var action = component.get("c.takesalutation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('line-->8' +JSON.stringify(result ));
                var salutationMap = [];
                for (var key in result[0]) {
                    salutationMap.push({ key: key, value: result[0][key] });
                }
                component.set("v.salutationMap", salutationMap);
            }
        });
        
        $A.enqueueAction(action);   
        // $A.get('e.force:refreshView').fire();    
    },
    
    checkEmailDuplicacy: function (component, accId) {
        //alert(email + firstname + surname + accId);
        
        var email = component.get("v.tenentdetails.PersonEmail");
        var firstname = component.get("v.tenentdetails.FirstName");
        var surname = component.get("v.tenentdetails.LastName");
        
        var action = component.get("c.checkDuplicateRecords");
        action.setParams({
            accId: accId,
            email: email,
            firstname: firstname,
            surname: surname
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('line 14 result - ',result);
                
                if (result === "Duplicate email" || result == "Duplicate Name") {
                    component.set("v.isDuplicateEmail", true);
                    component.set("v.duplicateEmailError", true);
                } else {
                    component.set("v.isDuplicateEmail", false);
                    component.set("v.duplicateEmailError", false);
                }
                console.log("Add Error to : " + component.get("v.duplicateEmailError"));
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Unknown error : " + errors);
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