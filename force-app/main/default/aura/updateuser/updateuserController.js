({
    doInit: function(component, event, helper) {
        var fetchPicklist = component.get("c.getUserRole");
        var jobRoleTest = component.find("jobrole");
        var opts=[];
        fetchPicklist.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            jobRoleTest.set("v.options", opts);
            
        });
        var fetchPicklist2 = component.get("c.getUserPermission");
        var userPerm = component.find("userpermission");
        var opts2=[];
        fetchPicklist2.setCallback(this, function(a) {
            opts2.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts2.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            userPerm.set("v.options", opts2);
            
        });
        
        var usid = component.get("v.strRecordId");
        console.log('@@ '+usid);
        var action = component.get("c.contactdetails");
        action.setParams({ conid: usid });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("line-->8" + response.getReturnValue());
                var con = response.getReturnValue();
                //alert(con.Job_role__c);
                component.set("v.conobj", response.getReturnValue());
            } else if (state === "INCOMPLETE") {
                // alert("incomplete");
            } else if (state === "ERROR") {
                // alert("error");
                var errors = response.getError();
                console.log("line--14" + JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    // alert("Unknown error");
                }
            }
        });
        
        var action2 = component.get("c.takesalutation");
        action2.setCallback(this, function(response) {
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
        
        $A.enqueueAction(fetchPicklist); 
        $A.enqueueAction(fetchPicklist2);
        
        $A.enqueueAction(action2);
        $A.enqueueAction(action);
    },
    
    updateuser: function(component, event, helper) {
        var jobrole = component.find("jobrole").get("v.value");
        var userpermission = component.find("userpermission").get("v.value");
        //alert(jobrole+userpermission);
        var conuse = component.get("v.conobj");
        console.log("line--54" + JSON.stringify(conuse));
        //console.log(JSON.stringify(con));
        var action = component.get("c.updatedetails");
        var allValid = component.find("mandate")
        .reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);   
        if (allValid){
            action.setParams({
                con: conuse,
                jobrole:jobrole,
                userpermission:userpermission
            });
            // alert("line-->53");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get("e.force:refreshView").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success!",
                        message: "User has been Updated successfully.",
                        type: "success"
                    });
                    toastEvent.fire();
                    
                    component.find("overlayLib").notifyClose();
                    window.location.reload();
                    console.log("line-->46" + response.getReturnValue());
                } else if (state === "INCOMPLETE") {
                    //alert("incomplete");
                } else if (state === "ERROR") {
                    //alert("error");
                    var errors = response.getError();
                    console.log("line--53" + JSON.stringify(errors));
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        //  alert("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(action);
        }
    }
});