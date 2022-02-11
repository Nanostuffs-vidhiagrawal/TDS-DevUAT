({
    fetchDataOnUpdate: function(component,event,helper){
          var action = component.get("c.showusers");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var datalist = response.getReturnValue();
                console.log("line-->09 " + JSON.stringify(datalist));
                if (datalist.length > 0) {
                    component.set("v.listOfAllrecords", datalist);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = datalist;
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);
                    
                    var PaginationLst = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.listOfAllrecords").length > i) {
                            PaginationLst.push(datalist[i]);
                        }
                    }
                    component.set("v.PaginationList", PaginationLst);
                    component.set("v.selectedCount", 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
                }
            } else if (state === "INCOMPLETE") {
                //  alert('incomplete');
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("line--14" + JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message663: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
        this.getSalutationofpopup(component, event);  
    },
     getSalutationofpopup: function (component, event, helper) {
          var fetchPicklist = component.get("c.getUserRole");
        var jobRoleTest = component.find("jobrole");
        var jobRoleTest1 = component.find("jobrole1"); 
        var opts=[];
        fetchPicklist.setCallback(this, function(a) {
              var state = a.getState();
            if(state === "SUCCESS"){
               // console.log('line-->9' + a.getReturnValue() );
              //  alert('Record is Created Successfully');
                opts.push({
                class: "optionClass",
                label: "-- Select Role --",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
              opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
              
            }
            jobRoleTest.set("v.options", opts);
            jobRoleTest1.set("v.options", opts);
            console.log('line-->21' + opts );
            } else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                //alert('No response from server or client is offline.');
            }
           
             
        });
           var fetchPicklist2 = component.get("c.getUserPermission");
        var userPerm = component.find("userpermission");
        var userPerm2 = component.find("addpermission");
        
        var opts2=[];
        fetchPicklist2.setCallback(this, function(a) {
           
            for(var i=0;i< a.getReturnValue().length;i++){
                console.log('return value '+a.getReturnValue());
                opts2.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
       //     userPerm.set("v.options", opts2);
        //    userPerm2.set("v.options", opts2);
             component.set("v.permissionList",opts2);
        });
        var action1 = component.get("c.takesalutation");
        action1.setCallback(this, function (response) {
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
       $A.enqueueAction(action1);
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
        component.set('v.PaginationList', Paginationlist);
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
        component.set('v.PaginationList', Paginationlist);
    },
    
       checkDuplicacyForADD: function (component, act) {
        console.log( act.Email + act.FirstName + act.LastName);
        var action = component.get("c.checkDuplicateEmailForADD");
        action.setParams({
            email: act.PersonEmail,
            firstname: act.FirstName, 
            surname: act.LastName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //alert(state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                //alert(result);
                console.log('line 14 result - ',result);
                if (result === "Duplicate Email" || result === "Duplicate Name") {
                    //alert("result : " + result);
                    component.set("v.isDuplicateEmail", true);
                    component.set("v.duplicateEmailError", true);
                }
                else {
                    component.set("v.isDuplicateEmail",false);
                    component.set("v.duplicateEmailError",false);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Unknown error"+error);
            }
            //alert("isDuplicate : " + component.get("v.isDuplicateEmail"));
            //alert("duplicateEmailError : " + component.get("v.duplicateEmailError"));
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
    },
    
    getError:function (component, event, helper){
       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
        console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
            component.set("v.errorList",response.getReturnValue());
                  var   errorList= component.get("v.errorList");                 
                	var userErr;
                
              for(var i=0; i<errorList.length; i++){
                  //console.log("line-->9  " +errorList[i].MasterLabel );
                   //console.log("line-->9  " +errorList[i].Error_Message__c );                  
                  
                  if(errorList[i].MasterLabel === 'First Name'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.firstNameErrorNew",userErr);
                  }       
                  
                  else if(errorList[i].MasterLabel === 'Surname'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.surNameErrorNew",userErr);
                  }
                  else if(errorList[i].MasterLabel === 'Email'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.emailErrorNew",userErr);
                  }    
                        
                  
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }

})