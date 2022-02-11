({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){ 
        var action = component.get("c.getDepositInformationTransferred");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    component.set('v.listOfAllDeposits', oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllDeposits").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                
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
        component.set("v.PaginationList", Paginationlist);
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
        component.set("v.PaginationList", Paginationlist);
    },
    
    checkTenantName : function(component,event,getTenantValue){
        console.log('component.get("v.selectedDeposits")-- >> ' + component.get("v.selectedDepositIds"));
        var action = component.get('c.checkDepositAllocationTenantName');
        action.setParams({listDepositId : component.get("v.selectedDepositIds"),
                          tenantValue : getTenantValue});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            var state = response.getState();
            console.log('allValues display-- >> ' + allValues);
            if (state === "SUCCESS"){
                if(allValues=='Not Found'){                    
                    component.set("v.tenantValidationError",true);
                    component.set("v.acceptSingleDeposit",false);
                    component.set("v.errors", "We have been unable to verify this as a tenant’s surname. Please try again.");
                }
                else{
                    component.set("v.acceptSingleDeposit",true);
                }
            }
            else{
                component.set("v.tenantValidationError",true);
                component.set("v.errors", allValues);   
            }
        });        
        $A.enqueueAction(action);
    },
    
    checkMultipleTenantName : function(component, event,tenantValue,tenantId){
        console.log('component.get("v.selectedDeposits")Multiple-- >> ' + component.get("v.selectedDepositIds"));
        var action = component.get('c.checkDepositAllocationMultipleTenantName');
        action.setParams({listDepositId : tenantId,
                          tenantValue : tenantValue});
        action.setCallback(this, function(response){
            var allValues = response.getReturnValue();
            var state = response.getState();
            console.log('checkMultipleTenantName-- >> ' + allValues);
            if (state === "SUCCESS"){
                if(allValues=='Found'){
                    component.set("v.acceptSingleDeposit",true);
                }
                else{
                    component.set("v.tenantValidationError",true);
                    component.set("v.acceptSingleDeposit",false);
                    component.set("v.errors", "We have been unable to verify this as a tenant’s surname for "+allValues+". Please try again.");
                }
            }
            else{
                component.set("v.tenantValidationError",true);
                component.set("v.acceptSingleDeposit",false);
                component.set("v.errors", "We have been unable to verify this as a tenant’s surname. Please try again.");  
            }
        });        
        $A.enqueueAction(action);
    },
    
    acceptSingleDeposit : function(component,event){
        console.log('Selested deposit Id-- >> ' + component.get("v.selectedDepositIds"));
        var getDepositId = component.get("v.selectedDepositIds");
        var action = component.get('c.processAcceptDeposit');
        action.setParams({depositId : component.get("v.selectedDepositIds") });
        action.setCallback(this, function(response){
            var resMessage = response.getReturnValue();
            var state = response.getState();
            console.log('resMessage -- >> ' + resMessage);
            console.log('state -- >> ' + state);
            if (state === "SUCCESS"){
                console.log('inside success -- >> ');
                if(resMessage == null){                    
                    var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"depositsummarypage?id="+getDepositId;
                    //window.location.replace(urlRedirect);
                    //return false;
                }
                else{ 
                    component.set("v.caseObj",resMessage);
                    component.set("v.caseExist",true);
                }
            }else{
                component.set("v.tenantValidationError",true);
                component.set("v.errors", resMessage);   
            }
        });        
        $A.enqueueAction(action);
    },
    
    rejectDeposit : function(component,event){
        console.log('Selected deposit Id Rejection-- >> ' + component.get("v.selectedDepositIds"));
        var action = component.get('c.processRejectDeposit');
        action.setParams({depositIds : component.get("v.selectedDepositIds") });
        action.setCallback(this, function(response){
            var resMessage = response.getReturnValue();
            var state = response.getState();
            console.log('resMessage -- >> ' + resMessage);
            if (state === "SUCCESS"){
                if(resMessage == 'Deposit Successfully Rejected'){
                    component.set("v.rejectedThankSection",true);
                    component.set("v.displayDepositTable",false);
                    component.set("v.enterTenantNameMultiple",false);
                    /*alert('Deposit is Rejected');
                    var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"reviewtransfer";
                    window.location.replace(urlRedirect);
                    return false;*/
                }
                else{ 
                    component.set("v.tenantValidationError",true);
                    component.set("v.errors", resMessage);
                }
            }else{
                component.set("v.tenantValidationError",true);
                component.set("v.errors", resMessage);   
            }
        });        
        $A.enqueueAction(action);
    },
    
    handleAcceptMultipleDeposits : function(component,event){
        console.log('Selested deposit Id-- >> ' + component.get("v.selectedDepositIds"));
        var action = component.get('c.processMultipleAcceptDeposit');
        action.setParams({depositId : component.get("v.selectedDepositIds") });
        action.setCallback(this, function(response){
            var resMessage = response.getReturnValue();
            var state = response.getState();
            console.log('resMessage -- >> ' + resMessage);
            console.log('state -- >> ' + state);
            if (state === "SUCCESS"){
                console.log('inside success -- >> ');
                var deposits = [];
                var conts = response.getReturnValue();
                for ( var key in conts ) {
                    deposits.push({value:conts[key], key:key});
                }
                component.set("v.deposits", deposits);
                console.log('component.get("v.deposits")-- >> ' + component.get("v.deposits"));  
            }else{
                component.set("v.tenantValidationError",true);
                component.set("v.errors", resMessage);   
            }
        });      
        $A.enqueueAction(action);
    },
    
    processMultipleDepositData : function(component,event){
        console.log('Selested deposit Id-- >> ' + component.get("v.selectedDepositIds"));
        var getTenantValue = component.find("tenantMultipleId").get("v.value");
        if(getTenantValue== undefined || getTenantValue == null
           || getTenantValue==''){
            component.set("v.tenantValidationError",false);
            component.set("v.singleBlankValue", true);
        }
        else{
            component.set("v.singleBlankValue", false);
            var action = component.get('c.validateTenantNameAndAccept');
            action.setParams({listDepositId : component.get("v.selectedDepositIds"),
                              tenantValue : getTenantValue});
            action.setCallback(this, function(response){
                var resMessage = response.getReturnValue();
                var state = response.getState();
                console.log('resMessage -- >> ' + resMessage);
                console.log('state -- >> ' + state);
                if (state === "SUCCESS"){
                    console.log('inside success -- >> ');
                    if(resMessage == 'Deposit updated and no case exist'){
                        component.set("v.enterTenantNameMultiple",false);
                        component.set("v.displayDepositTable",false);
                        component.set("v.acceptedThankSection",true);
                        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"depositsummarypage?id="+component.get("v.depositRecordId");
                        //window.location.replace(urlRedirect);
                        //return false;
                    }
                    else if(resMessage == 'Deposit updated and case exist'){
                        component.set("v.acceptedThankSection",true);
                        component.set("v.enterTenantNameMultiple",false);
                        component.set("v.errors", "There are outstanding actions required against some of these deposits. Please see the ‘Outstanding actions’ section of your account to view these deposits and your deadlines to respond."); 
                    }else if(resMessage == 'Not Found'){ 
                        component.set("v.tenantValidationError",true);
                        component.set("v.errors", "We have been unable to verify this as a tenant’s surname. Please try again."); 
                    }
                }else{
                    component.set("v.tenantValidationError",true);
                    component.set("v.errors", resMessage);   
                }
            });        
            $A.enqueueAction(action);
        }
    },
    
    processMultipleData : function(component,event){
        console.log('Selested deposit Id-- >> ' + component.get("v.selectedDepositIds"));
        console.log('deposits ' + JSON.stringify(component.get("v.deposits")));
        console.log('depositInfo ' + JSON.stringify(component.get("v.depositInfo")));
        var action = component.get('c.checkDepositAllocationMultipleTenantName');
        action.setParams({listDepositId : component.get("v.selectedDepositIds"),
                         values : JSON.stringify(component.get("v.depositInfo")),
                          depositsList : JSON.stringify(component.get("v.deposits"))});
        action.setCallback(this, function(response){
            var resMessage = response.getReturnValue();
            var state = response.getState();
            console.log('resMessage -- >> ' + resMessage);
            console.log('state -- >> ' + state);
            if (state === "SUCCESS"){
                console.log('inside success -- >> ');
                if(resMessage == 'Deposit updated and no case exist'){
                    component.set("v.enterTenantNameMultiple",false);
                    component.set("v.displayDepositTable",false);
                    component.set("v.errors", "");
                    component.set("v.acceptedThankSection",true);
                    //var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"depositsummarypage?id="+component.get("v.depositRecordId");
                    //window.location.replace(urlRedirect);
                    //return false;
                }
                else if(resMessage == 'Deposit updated and case exist'){
                    component.set("v.acceptedThankSection",true);
                    component.set("v.displayDepositTable",false);
                    component.set("v.enterTenantNameMultiple",false);
                    component.set("v.errors", "There are outstanding actions required against some of these deposits. Please see the ‘Outstanding actions’ section of your account to view these deposits and your deadlines to respond."); 
                }
                else if(resMessage.includes("Please complete the required value for")){
                    component.set("v.tenantValidationError",true);
                    component.set("v.errors", resMessage); 
                }
                else if(resMessage == 'all blank'){
                    component.set("v.tenantValidationError",true);
                    component.set("v.errors", "Please enter the required value for all Deposits."); 
                }else{ 
                    component.set("v.tenantValidationError",true);
                	component.set("v.errors", "We have been unable to verify this as a tenant’s surname for "+resMessage+". Please try again."); 
                }
            }else{
                component.set("v.tenantValidationError",true);
                component.set("v.errors", resMessage);   
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
                  console.log("line-->9  " +errorList[i].MasterLabel );
                   console.log("line-->9  " +errorList[i].Error_Message__c );
                  if(errorList[i].MasterLabel === 'click on Accept Selected deposits'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.acceptDepositErrorNew",userErr);
                  }         
                     
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }

});