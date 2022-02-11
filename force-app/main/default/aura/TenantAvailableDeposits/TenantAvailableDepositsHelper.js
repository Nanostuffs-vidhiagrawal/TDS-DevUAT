({
    helperFun : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
    getyear: function(component, event) {
    var currentTime = new Date();
     var year = currentTime.getFullYear();
     var lastyears = year-40;
     var items = [];
       /* for (var i =lastyears; i < year+1; i++) {
            var item = {
                "label": i ,
                "value": i.toString()
            };
            items.push(item);
        }*/
         for (var i =year; i > lastyears-1; i--) {
            var item = {
                "label": i ,
                "value": i.toString()
            };
            items.push(item);
        }
        component.set("v.year", items);
    },
   
    
    getPaymentsHeldSafeDeposits : function(component, event) {
        var depositHeldBySafedepositNumber = 0;
        var depositHeldBySafedepositAmount = 0.00;

        component.set('v.mycolumns', [
            {label: 'DAN', fieldName: 'DepositName', type: 'text'},
            {label: 'Tenancy address (with postcode)', fieldName: 'PropertyAddress', type: 'text'},
            {label: 'Tenancy start date', fieldName: 'TenancyStartDate', type: 'text'},
            {label: 'Tenancy deposit amount', fieldName: 'TenancyDepositAmount', type: 'text'},
            {label: 'Number of tenants', fieldName: 'Numberoftenants', type: 'number'},
            {type: "button", typeAttributes: {
                label: 'View Deposit',
                name: 'View Deposit',
                title: 'View Deposit',
                disabled: false,
                value: 'view',
                iconPosition: 'left'
            }}
        ]);
        console.log('allValues display--111111111 >> ');
        var action = component.get("c.getDepositsByStatus");
        action.setParams({status : $A.get("$Label.c.Deposits_held_by_SafeDeposits_Scotland")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("line 33" + JSON.stringify(allValues));
                if(allValues!=null){
                    console.log('allValues display-- >> ' + allValues);
                    for (var i = 0; i < allValues.length; i++) {
                        depositHeldBySafedepositNumber = depositHeldBySafedepositNumber + 1;
                        depositHeldBySafedepositAmount = allValues[i].Deposit__r.Protected_Amount__c +  depositHeldBySafedepositAmount;
                        component.set("v.heldBySafeDepositNumber", depositHeldBySafedepositNumber);
                        component.set("v.heldBySafeDepositAmount", depositHeldBySafedepositAmount.toFixed(2));
                        var row = allValues[i];
                        console.log('rowrowrow ' + JSON.stringify(row));
                        if (row.Deposit__c) {
                            row.DepositName = row.Deposit__r.Name;
                            row.PropertyAddress = row.Deposit__r.Property_Address__c;
                            row.TenancyStartDate = row.Deposit__r.Start_Date__c;
                            row.TenancyDepositAmount = row.Deposit__r.Deposit_Amount__c;
                            row.Numberoftenants = row.Deposit__r.Number_of_Tenants_Value__c;
                            console.log(' row.DepositName-- >> ' +  row.DepositName);
                            console.log('  row.PropertyAddress-- >> ' +   row.PropertyAddress);
                        }
                    }
                    console.log('allValues ' +JSON.stringify(allValues));
                    component.set("v.heldBySafeDepositRecords", allValues);
                    console.log('heldBySafeDepositRecords ' + JSON.stringify(component.get("v.heldBySafeDepositRecords")));
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
      getRepaymentsRequestedTenants : function(component, event) {
        var repaymentrequestbytenantNumber = 0;
        var repaymentrequestbytenantAmount = 0.00;

        console.log('allValues display--111111111 >> ');
        var action = component.get("c.getrepaymentbytenant");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("line 33" + JSON.stringify(allValues));
                if(allValues!=null){
                    console.log('allValues display-- >> ' + allValues);
                    for (var i = 0; i < allValues.length; i++) {
                        repaymentrequestbytenantNumber = repaymentrequestbytenantNumber + 1;
                        repaymentrequestbytenantAmount = allValues[i].Deposit__r.Protected_Amount__c +  repaymentrequestbytenantAmount;
                        component.set("v.repaymentRequestedTenantNumber", repaymentrequestbytenantNumber);
                        component.set("v.repaymentRequestedTenantAmount", repaymentrequestbytenantAmount.toFixed(2));
                        var row = allValues[i];
                        console.log('rowrowrow ' + JSON.stringify(row));
                        if (row.Deposit__c) {
                            row.DepositName = row.Deposit__r.Name;
                            row.PropertyAddress = row.Deposit__r.Property_Address__c;
                            row.TenancyStartDate = row.Deposit__r.Start_Date__c;
                            row.TenancyDepositAmount = row.Deposit__r.Deposit_Amount__c;
                            row.Numberoftenants = row.Deposit__r.Number_of_Tenants_Value__c;
                            console.log(' row.DepositName-- >> ' +  row.DepositName);
                            console.log('  row.PropertyAddress-- >> ' +   row.PropertyAddress);
                        }
                    }
                    console.log('allValues ' +JSON.stringify(allValues));
                    component.set("v.repaymentRequestedTenantRecords", allValues);
                    console.log('inDisputeResolution ' + JSON.stringify(component.get("v.repaymentRequestedTenantRecords")));
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
    getRepaymentsRequestedAgentLandlord : function(component, event) {
        var repaymentrequestbyagentlandlordNumber = 0;
        var repaymentrequestbytenantagentlandlordAmount = 0.00;

        console.log('allValues display--111111111 >> ');
        var action = component.get("c.getrepaymentbyagentlandlord");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("line 33" + JSON.stringify(allValues));
                if(allValues!=null){
                    console.log('allValues display-- >> ' + allValues);
                    for (var i = 0; i < allValues.length; i++) {
                        repaymentrequestbyagentlandlordNumber = repaymentrequestbyagentlandlordNumber + 1;
                        repaymentrequestbytenantagentlandlordAmount = allValues[i].Deposit__r.Protected_Amount__c +  repaymentrequestbytenantagentlandlordAmount;
                        component.set("v.repaymentRequestedAgentLandlordNumber", repaymentrequestbyagentlandlordNumber);
                        component.set("v.repaymentRequestedAgentLandlordAmount", repaymentrequestbytenantagentlandlordAmount.toFixed(2));
                        var row = allValues[i];
                        console.log('rowrowrow ' + JSON.stringify(row));
                        if (row.Deposit__c) {
                            row.DepositName = row.Deposit__r.Name;
                            row.PropertyAddress = row.Deposit__r.Property_Address__c;
                            row.TenancyStartDate = row.Deposit__r.Start_Date__c;
                            row.TenancyDepositAmount = row.Deposit__r.Deposit_Amount__c;
                            row.Numberoftenants = row.Deposit__r.Number_of_Tenants_Value__c;
                            console.log(' row.DepositName-- >> ' +  row.DepositName);
                            console.log('  row.PropertyAddress-- >> ' +   row.PropertyAddress);
                        }
                    }
                    console.log('allValues ' +JSON.stringify(allValues));
                    component.set("v.repaymentRequestedAgentLandlordRecords", allValues);
                    console.log('inDisputeResolution ' + JSON.stringify(component.get("v.repaymentRequestedAgentLandlordRecords")));
                }
            }
        });
        $A.enqueueAction(action); 
    },
     getSelfResolutionResolution : function(component, event) {
        var selfresolutionNumber = 0;
        var selfresolutionAmount = 0.00;

        console.log('allValues display--111111111 >> ');
        var action = component.get("c.getselfresolution");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("line 33" + JSON.stringify(allValues));
                if(allValues!=null){
                    console.log('allValues display-- >> ' + allValues);
                    for (var i = 0; i < allValues.length; i++) {
                        selfresolutionNumber = selfresolutionNumber + 1;
                        selfresolutionAmount = allValues[i].Deposit__r.Protected_Amount__c +  selfresolutionAmount;
                        component.set("v.selfResolutionNumber", selfresolutionNumber);
                        component.set("v.selfResolutionAmount", selfresolutionAmount.toFixed(2));
                        var row = allValues[i];
                        console.log('rowrowrow ' + JSON.stringify(row));
                        if (row.Deposit__c) {
                            row.DepositName = row.Deposit__r.Name;
                            row.PropertyAddress = row.Deposit__r.Property_Address__c;
                            row.TenancyStartDate = row.Deposit__r.Start_Date__c;
                            row.TenancyDepositAmount = row.Deposit__r.Deposit_Amount__c;
                            row.Numberoftenants = row.Deposit__r.Number_of_Tenants_Value__c;
                            console.log(' row.DepositName-- >> ' +  row.DepositName);
                            console.log('  row.PropertyAddress-- >> ' +   row.PropertyAddress);
                        }
                    }
                    console.log('allValues ' +JSON.stringify(allValues));
                    component.set("v.selfResolutionRecords", allValues);
                    console.log('inDisputeResolution ' + JSON.stringify(component.get("v.selfResolutionRecords")));
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
    
    getIndisputeresol : function(component, event) {
        var inDisputeResolutionNumber = 0;
        var inDisputeResolutionAmount = 0.00;

        component.set('v.mycolumns', [
            {label: 'DAN', fieldName: 'DepositName', type: 'text'},
            {label: 'Tenancy address (with postcode)', fieldName: 'PropertyAddress', type: 'text'},
            {label: 'Tenancy start date', fieldName: 'TenancyStartDate', type: 'text'},
            {label: 'Tenancy deposit amount', fieldName: 'TenancyDepositAmount', type: 'text'},
            {label: 'Number of tenants', fieldName: 'Numberoftenants', type: 'number'},
            {type: "button", typeAttributes: {
                label: 'View Deposit',
                name: 'View Deposit',
                title: 'View Deposit',
                disabled: false,
                value: 'view',
                iconPosition: 'left'
            }}
        ]);
        console.log('allValues display--111111111 >> ');
        var action = component.get("c.getIndisputeresolution");
       // action.setParams({status : $A.get("$Label.c.Deposits_held_by_SafeDeposits_Scotland")});
       action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("line 33" + JSON.stringify(allValues));
                if(allValues!=null){
                    console.log('allValues display-- >> ' + allValues);
                    for (var i = 0; i < allValues.length; i++) {
                        inDisputeResolutionNumber = inDisputeResolutionNumber + 1;
                        inDisputeResolutionAmount = allValues[i].Deposit__r.Protected_Amount__c +  inDisputeResolutionAmount;
                        component.set("v.inDisputeResolutionNumber", inDisputeResolutionNumber);
                        component.set("v.inDisputeResolutionAmount", inDisputeResolutionAmount.toFixed(2));
                        var row = allValues[i];
                        console.log('rowrowrow ' + JSON.stringify(row));
                        if (row.Deposit__c) {
                            row.DepositName = row.Deposit__r.Name;
                            row.PropertyAddress = row.Deposit__r.Property_Address__c;
                            row.TenancyStartDate = row.Deposit__r.Start_Date__c;
                            row.TenancyDepositAmount = row.Deposit__r.Deposit_Amount__c;
                            row.Numberoftenants = row.Deposit__r.Number_of_Tenants_Value__c;
                            console.log(' row.DepositName-- >> ' +  row.DepositName);
                            console.log('  row.PropertyAddress-- >> ' +   row.PropertyAddress);
                        }
                    }
                    console.log('allValues ' +JSON.stringify(allValues));
                    component.set("v.inDisputeResolRecords", allValues);
                    console.log('inDisputeResolution ' + JSON.stringify(component.get("v.inDisputeResolRecords")));
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
    getRepaymentprocess : function(component, event) {
        var RepaymentprocessNumber = 0;
        var RepaymentprocessAmount = 0.00;

        component.set('v.mycolumns', [
            {label: 'DAN', fieldName: 'DepositName', type: 'text'},
            {label: 'Tenancy address (with postcode)', fieldName: 'PropertyAddress', type: 'text'},
            {label: 'Tenancy start date', fieldName: 'TenancyStartDate', type: 'text'},
            {label: 'Tenancy deposit amount', fieldName: 'TenancyDepositAmount', type: 'text'},
            {label: 'Number of tenants', fieldName: 'Numberoftenants', type: 'number'},
            {type: "button", typeAttributes: {
                label: 'View Deposit',
                name: 'View Deposit',
                title: 'View Deposit',
                disabled: false,
                value: 'view',
                iconPosition: 'left'
            }}
        ]);
        console.log('allValues display--111111111 >> ');
        var action = component.get("c.getRepaymentprocess");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("line 33" + JSON.stringify(allValues));
                if(allValues!=null){
                    console.log('allValues display-- >> ' + allValues);
                    for (var i = 0; i < allValues.length; i++) {
                        RepaymentprocessNumber = RepaymentprocessNumber + 1;
                        RepaymentprocessAmount = allValues[i].Deposit__r.Protected_Amount__c +  RepaymentprocessAmount;
                        component.set("v.RepaymentprocessNumber", RepaymentprocessNumber);
                        component.set("v.RepaymentprocessAmount", RepaymentprocessAmount.toFixed(2));
                        var row = allValues[i];
                        console.log('rowrowrow ' + JSON.stringify(row));
                        if (row.Deposit__c) {
                            row.DepositName = row.Deposit__r.Name;
                            row.PropertyAddress = row.Deposit__r.Property_Address__c;
                            row.TenancyStartDate = row.Deposit__r.Start_Date__c;
                            row.TenancyDepositAmount = row.Deposit__r.Deposit_Amount__c;
                            row.Numberoftenants = row.Deposit__r.Number_of_Tenants_Value__c;
                            console.log(' row.DepositName-- >> ' +  row.DepositName);
                            console.log('  row.PropertyAddress-- >> ' +   row.PropertyAddress);
                        }
                    }
                    console.log('allValues ' +JSON.stringify(allValues));
                    component.set("v.RepaymentprocessRecords", allValues);
                    console.log('RepaymentprocessRecords ' + JSON.stringify(component.get("v.RepaymentprocessRecords")));
                }
            }
        });
        $A.enqueueAction(action); 
    },
    getDepositsrepaidinthelastyear : function(component, event) {
        var repaidinthelastyearNumber = 0;
        var repaidinthelastyearAmount = 0.00;

        component.set('v.mycolumns', [
            {label: 'DAN', fieldName: 'DepositName', type: 'text'},
            {label: 'Tenancy address (with postcode)', fieldName: 'PropertyAddress', type: 'text'},
            {label: 'Tenancy start date', fieldName: 'TenancyStartDate', type: 'text'},
            {label: 'Tenancy deposit amount', fieldName: 'TenancyDepositAmount', type: 'text'},
            {label: 'Number of tenants', fieldName: 'Numberoftenants', type: 'number'},
            {type: "button", typeAttributes: {
                label: 'View Deposit',
                name: 'View Deposit',
                title: 'View Deposit',
                disabled: false,
                value: 'view',
                iconPosition: 'left'
            }}
        ]);
        console.log('allValues display--111111111 >> ');
        var action = component.get("c.getDepositsrepaidinthelastyear");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log("line 33" + JSON.stringify(allValues));
                if(allValues!=null){
                    console.log('allValues display-- >> ' + allValues);
                    for (var i = 0; i < allValues.length; i++) {
                        repaidinthelastyearNumber = repaidinthelastyearNumber + 1;
                        repaidinthelastyearAmount = allValues[i].Deposit__r.Protected_Amount__c +  repaidinthelastyearAmount;
                        component.set("v.repaidinthelastyearNumber", repaidinthelastyearNumber);
                        component.set("v.repaidinthelastyearAmount", repaidinthelastyearAmount.toFixed(2));
                        var row = allValues[i];
                        console.log('rowrowrow ' + JSON.stringify(row));
                        if (row.Deposit__c) {
                            row.DepositName = row.Deposit__r.Name;
                            row.PropertyAddress = row.Deposit__r.Property_Address__c;
                            row.TenancyStartDate = row.Deposit__r.Start_Date__c;
                            row.TenancyDepositAmount = row.Deposit__r.Deposit_Amount__c;
                            row.Numberoftenants = row.Deposit__r.Number_of_Tenants_Value__c;
                            console.log(' row.DepositName-- >> ' +  row.DepositName);
                            console.log('  row.PropertyAddress-- >> ' +   row.PropertyAddress);
                        }
                    }
                    console.log('allValues ' +JSON.stringify(allValues));
                    component.set("v.repaidinthelastyearRecords", allValues);
                    console.log('repaidinthelastyearRecords ' + JSON.stringify(component.get("v.repaidinthelastyearRecords")));
                }
            }
        });
        $A.enqueueAction(action); 
    },
    getInDisputeResolution : function(component, event) {
        component.set('v.mycolumns1', [
            {label: 'DAN', fieldName: 'DepositName', type: 'text'},
            {label: 'Tenancy address (with postcode)', fieldName: 'PropertyAddress', type: 'text'},
            {label: 'Tenancy start date', fieldName: 'TenancyStartDate', type: 'text'},
            {label: 'Tenancy deposit amount', fieldName: 'TenancyDepositAmount', type: 'text'},
            {label: 'Number of tenants', fieldName: 'Numberoftenants', type: 'text'},
            {type: "button", typeAttributes: {
                label: 'View',
                name: 'View',
                title: 'View',
                disabled: false,
                value: 'view',
                iconPosition: 'left'
            }}
        ]);
        console.log('allValues display--111111111 >> ');
        var action = component.get("c.getDepositsByPaidOrInDispute");
        action.setCallback(this, function(response) {
            var allValues = response.getReturnValue();
            if(allValues!=null){
                for (var i = 0; i < allValues.length; i++) {
                    var row = allValues[i];
                    console.log('rowrowrow ' + JSON.stringify(row));
                    if (row.Deposit__c) {
                        row.DepositName = row.Deposit__r.Name;
                        row.PropertyAddress = row.Deposit__r.Property_Address__c;
                        row.TenancyStartDate = row.Deposit__r.Start_Date__c;
                        row.TenancyDepositAmount = row.Deposit__r.Deposit_Amount__c;
                        row.Numberoftenants = row.Deposit__r.Number_of_Tenants_Value__c;
                        console.log(' row.DepositName-- >> ' +  row.DepositName);
                        console.log('  row.PropertyAddress-- >> ' +   row.PropertyAddress);
                    }
                }
                component.set("v.inDisputeReolutionRecords", allValues);
            }
        });
        $A.enqueueAction(action); 
    },
    
    getUnvalidatedDeposits : function(component, event) {
        component.set('v.mycolumns2', [
            {label: 'DAN', fieldName: 'DepositName', type: 'text'},
            {label: 'Tenancy address (without postcode)', fieldName: 'PropertyAddress', type: 'text'},
            {type: "button", typeAttributes: {
                label: 'Confirm deposit',
                name: 'Confirm deposit',
                title: 'Confirm deposit',
                disabled: false,
                value: 'Confirm deposit',
                iconPosition: 'left'
            }}
        ]);
        console.log('getUnvalidatedDeposits>> ');
        var action = component.get("c.getLoggedInTenantDeposits");
        action.setCallback(this, function(response) {
            var allValues = response.getReturnValue();
            console.log('allValues>> '+allValues);
            if(allValues!=null){
                for (var i = 0; i < allValues.length; i++) {
                    var row = allValues[i];
                    console.log('rowrowrow ' + JSON.stringify(row));
                    if (row.Deposit__c) {
                        row.DepositName = row.Deposit__r.Name;
                        row.PropertyAddress = row.Deposit__r.Property_Address_Without_Postcode__c;
                    }
                }
                component.set("v.unvalidatedRecords", allValues);
                console.log('1111111---->> '+component.get("v.unvalidatedRecords", allValues));
            }
        });
        $A.enqueueAction(action); 
    },
    
    submitDetails : function(component, event) {
      //  alert('check');
        var postcode = component.find("postcode").get("v.value");
       // var tenancyStartDate = component.find("tenancyStartDate").get("v.value");
        var depositAmount = component.find("depositAmount").get("v.value");
        var month = component.get("v.selectedmonth"); 
        var year  = component.get("v.selectedyear");
       // alert(postcode);
        //alert(tenancyStartDate);
      //  alert(depositAmount);
      //  alert(month);
      //  alert(year);
        var toastEvent = $A.get("e.force:showToast");
        var isValid = true;
        if(postcode==undefined || postcode==null || postcode==''){
          /*  toastEvent.setParams({
                title : 'Error',
                message:'Please enter Postcode value',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();*/
             component.set("v.postcodeError", true);
            isValid = false;
        }
         else{
             component.set("v.postcodeError", false);   
            }
        if(month==undefined || month==null || month==''){
          /*  toastEvent.setParams({
                title : 'Error',
                message:'Please enter tenancy month',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();*/
            component.set("v.monthError", true);
            isValid = false;
        }
        else{
             component.set("v.monthError", false);   
            }
        if(year==undefined || year==null || year==''){
           /* toastEvent.setParams({
                title : 'Error',
                message:'Please enter tenancy year',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();*/
            component.set("v.yearError", true);
            isValid = false;
        }
        else{
            component.set("v.yearError", false);   
        }
        if(depositAmount==undefined || depositAmount==null || depositAmount==''){
          /*  toastEvent.setParams({
                title : 'Error',
                message:'Please enter Deposit amount',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();*/
            component.set("v.depositamountError", true);
            isValid = false;
        }
        else{
            component.set("v.depositamountError", false);   
        }
        if(isValid){
            var action = component.get("c.getTenantDepositDetails");
            action.setParams({depositid : component.get("v.depositId"),
                              postcode : postcode,
                              month : month,
                              year:year,
                              //tenancyStartDate : tenancyStartDate,
                              depositAmount : depositAmount});
            action.setCallback(this, function(response) {
                var resMessage = response.getReturnValue();
                var state = response.getState();
                console.log('resMessage>> '+JSON.stringify(resMessage));
                // console.log('answered correctly '+resMessage[0].Answered_Correctly__c);
                component.set("v.noofattampts",resMessage[0].Number_Of_Attempts__c);
                component.set("v.answer",resMessage[0].Answered_Correctly__c);
                var noofattampts = component.get("v.noofattampts");
                var answer = component.get("v.answer");
                if (state === "SUCCESS"){
                    if(answer=='No' && noofattampts == 3){  
                       // alert('395');
                        //component.set("v.tenantValidationError",true);
                        //component.set("v.errors", 'You have used your maximum number of attempts to confirm your deposit’s details. Please contact SafeDeposits Scotland to gain access to your account.');
                        window.location.reload();
                    }
                    else if(answer=='No' && (noofattampts == 1 || noofattampts == 2)){ 
                        var remainattempts = 3-noofattampts;
                        component.set("v.remainattempts",remainattempts);
                        component.set("v.tenantValidationError",true);
                        component.set("v.errors", 'The information provided does not match our records, Please try again.');
                    }
                    else{
                           // var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"tenantavailabledeposit";
                          // window.location.replace(urlRedirect);
                          window.location.reload();
                            return false;
                        }
                }else{
                    component.set("v.tenantValidationError",true);
                    component.set("v.errors", resMessage);   
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    findDepositBySearchText2 : function(component,event){
        var searchtext = document.getElementById("searchValue").value;
        if(searchtext){
        component.set("v.displaySearchDepositRecords", true);
        }
        else{
        component.set("v.displaySearchDepositRecords", false);    
        };
        var action = component.get("c.getDepositRecordsBySearchText");
        action.setParams({
            'searchText': searchtext
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var depositRecords = response.getReturnValue();
                console.log('++++++++++depositRecords' + depositRecords);
                if(depositRecords.length > 0){
                    component.set("v.listOfAllDeposits", depositRecords);
                }   
            }
            else{
                //alert('Error...');
            }
        });
        $A.enqueueAction(action);
    },
    
      findDepositBySearchText : function(component,event){
        var depositHeldBySafedepositNumber = 0, inDisputeResolutionNumber = 0, RepaymentprocessNumber = 0,repaidinthelastyearNumber = 0;
        var repaymentbyTenantNumber = 0, repaymentbyAgentLandlordNumber = 0,selfResolutionNumber = 0;
        var depositHeldBySafedepositAmount = 0.00,inDisputeResolutionAmount = 0.00,RepaymentprocessAmount =0.00, repaidinthelastyearAmount = 0.00;
        var repaymentbyTenantAmount = 0.00,repaymentbyAgentLandlordAmount = 0.00,selfResolutionAmount = 0.00;
        var heldByRecords =[] , disputeRecords =[] ,repaymentRecords =[] , lastYearRecords =[];
        var tenantRecords =[], agentLandlordRecords =[],selfResolutionRecords =[];
        component.set("v.displaySearchDepositRecords", true);
        var searchTextValue =$("#searchValue").val();
        //alert(searchTextValue);
        var action = component.get("c.getDepositRecordsBySearchText");
        action.setParams({
            'searchText': searchTextValue
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var allValues = response.getReturnValue();
                console.log('++++++++++allValues11111' + JSON.stringify(allValues));
                 console.log('++++++++++allValueslength' + allValues.length);
                if(allValues.length > 0){
                    //component.set("v.listOfAllDeposits", allValues);
                    for(var i = 0; i < allValues.length; i++){
                        if(allValues[i].Status__c==$A.get("$Label.c.Deposits_held_by_SafeDeposits_Scotland")){
                            depositHeldBySafedepositNumber = depositHeldBySafedepositNumber + 1 ;
                            depositHeldBySafedepositAmount = allValues[i].Protected_Amount__c +  depositHeldBySafedepositAmount;
                            component.set("v.heldBySafeDepositNumber", depositHeldBySafedepositNumber);
                            component.set("v.heldBySafeDepositAmount", depositHeldBySafedepositAmount.toFixed(2));
                            heldByRecords.push(allValues[i]);
                        }
                    }
                    console.log('depositheldnumbers' + component.get("v.heldBySafeDepositNumber"));
                    console.log('depositheldamounts' + component.get("v.heldBySafeDepositAmount"));
                    console.log('heldByRecords' + heldByRecords );
                    
                    for(var i = 0; i < allValues.length; i++){
                        if(allValues[i].Status__c==$A.get("$Label.c.Repayment_requested_by_tenant")){
                            repaymentbyTenantNumber = repaymentbyTenantNumber + 1;
                            repaymentbyTenantAmount = allValues[i].Protected_Amount__c +  repaymentbyTenantAmount;
                            component.set("v.repaymentRequestedTenantNumber", repaymentbyTenantNumber);
                            component.set("v.repaymentRequestedTenantAmount", repaymentbyTenantAmount.toFixed(2));
                            tenantRecords.push(allValues[i]);
                        }
                    }
                    for(var i = 0; i < allValues.length; i++){
                        if(allValues[i].Status__c==$A.get("$Label.c.Repayment_requested_by_agent_landlord")){
                            repaymentbyAgentLandlordNumber = repaymentbyAgentLandlordNumber + 1;
                            repaymentbyAgentLandlordAmount = allValues[i].Protected_Amount__c +  repaymentbyAgentLandlordAmount;
                            component.set("v.repaymentRequestedAgentLandlordNumber", repaymentbyAgentLandlordNumber);
                            component.set("v.repaymentRequestedAgentLandlordAmount", repaymentbyAgentLandlordAmount.toFixed(2));
                            agentLandlordRecords.push(allValues[i]);
                        }
                    }
                    for(var i = 0; i < allValues.length; i++){
                        if(allValues[i].Status__c==$A.get("$Label.c.Self_resolution")){
                            selfResolutionNumber = selfResolutionNumber + 1;
                            selfResolutionAmount = allValues[i].Protected_Amount__c +  selfResolutionAmount;
                            component.set("v.selfResolutionNumber", selfResolutionNumber);
                            component.set("v.selfResolutionAmount", selfResolutionAmount.toFixed(2));
                            selfResolutionRecords.push(allValues[i]);
                        }
                    }
                    
                    for(var i = 0; i < allValues.length; i++){
                        if(allValues[i].Status__c==$A.get("$Label.c.In_dispute_resolution")){
                            inDisputeResolutionNumber = inDisputeResolutionNumber + 1;
                            inDisputeResolutionAmount = allValues[i].Protected_Amount__c +  inDisputeResolutionAmount;
                            component.set("v.inDisputeResolutionNumber", inDisputeResolutionNumber);
                            component.set("v.inDisputeResolutionAmount", inDisputeResolutionAmount.toFixed(2));
                            disputeRecords.push(allValues[i]);
                        }
                    }
                    for(var i = 0; i < allValues.length; i++){
                        if(allValues[i].Status__c==$A.get("$Label.c.Repayment_process")){
                            RepaymentprocessNumber = RepaymentprocessNumber + 1;
                            depositHeldBySafedepositAmount = allValues[i].Protected_Amount__c +  depositHeldBySafedepositAmount;
                            component.set("v.RepaymentprocessNumber", RepaymentprocessNumber);
                            component.set("v.RepaymentprocessAmount", RepaymentprocessAmount.toFixed(2));
                            repaymentRecords.push(allValues[i]);
                        }console.log('++++++++++RepaymentprocessNumber' + component.get("v.RepaymentprocessNumber"));
                        console.log('++++++++++RepaymentprocessAmount' + component.get("v.RepaymentprocessAmount"));
                        console.log('++++++++++repaymentRecords' + repaymentRecords);
                    }
                    for(var i = 0; i < allValues.length; i++){
                        if(allValues[i].Status__c==$A.get("$Label.c.Deposits_repaid_in_the_last_year")){
                            repaidinthelastyearNumber = repaidinthelastyearNumber + 1;
                            repaymentbyTenantAmount = allValues[i].Protected_Amount__c +  repaymentbyTenantAmount;
                            component.set("v.repaidinthelastyearNumber", repaidinthelastyearNumber);
                            component.set("v.repaidinthelastyearAmount", repaidinthelastyearAmount.toFixed(2));
                            lastYearRecords.push(allValues[i]);
                        }
                    }              
                }
                if(heldByRecords==null || heldByRecords=='' || heldByRecords==undefined){
                    component.set("v.heldBySafeDepositNumber", 0);
                    component.set("v.heldBySafeDepositAmount", 0.00);
                }
                else{
                    /*document.getElementById("cardHeader3").style.backgroundColor = "#32669E";
                    document.getElementById("rowHeader31").style.color = "#fff";
                    document.getElementById("rowHeader32").style.color = "#fff";
                    document.getElementById("rowHeader33").style.color = "#fff";*/
                    
                    document.getElementById("cardHeader3").style.backgroundColor = "rgba(0,166,211,0.17)";
                    document.getElementById("rowHeader31");
                    document.getElementById("rowHeader32");
                    document.getElementById("rowHeader33");
                }
                if(disputeRecords==null || disputeRecords=='' || disputeRecords==undefined){
                    component.set("v.inDisputeResolutionNumber", 0);
                    component.set("v.inDisputeResolutionAmount", 0.00);
                }
                else{
                  /*  document.getElementById("cardHeader7").style.backgroundColor = "#32669E";
                    document.getElementById("rowHeader71").style.color = "#fff";
                    document.getElementById("rowHeader72").style.color = "#fff";
                    document.getElementById("rowHeader73").style.color = "#fff";*/
                    
                     document.getElementById("cardHeader7").style.backgroundColor = "rgba(0,166,211,0.17)";
                    document.getElementById("rowHeader71");
                    document.getElementById("rowHeader72");
                    document.getElementById("rowHeader73");
                }
                if(tenantRecords==null || tenantRecords=='' || tenantRecords==undefined){
                    component.set("v.repaymentRequestedTenantNumber", 0);
                    component.set("v.repaymentRequestedTenantAmount", 0.00);
                }
                else{
                  /*  document.getElementById("cardHeader4").style.backgroundColor = "#32669E";
                    document.getElementById("rowHeader41").style.color = "#fff";
                    document.getElementById("rowHeader42").style.color = "#fff";
                    document.getElementById("rowHeader43").style.color = "#fff";*/
                    
                     document.getElementById("cardHeader4").style.backgroundColor = "rgba(0,166,211,0.17)";
                    document.getElementById("rowHeader41");
                    document.getElementById("rowHeader42");
                    document.getElementById("rowHeader43");
                }
                if(agentLandlordRecords==null || agentLandlordRecords=='' || agentLandlordRecords==undefined){
                    component.set("v.repaymentRequestedAgentLandlordNumber", 0);
                    component.set("v.repaymentRequestedAgentLandlordAmount", 0.00);
                }
                else{
                   /* document.getElementById("cardHeader5").style.backgroundColor = "#32669E";
                    document.getElementById("rowHeader51").style.color = "#fff";
                    document.getElementById("rowHeader52").style.color = "#fff";
                    document.getElementById("rowHeader53").style.color = "#fff";*/
                    
                     document.getElementById("cardHeader5").style.backgroundColor = "rgba(0,166,211,0.17)";
                    document.getElementById("rowHeader51");
                    document.getElementById("rowHeader52");
                    document.getElementById("rowHeader53");
                }
                if(selfResolutionRecords==null || selfResolutionRecords=='' || selfResolutionRecords==undefined){
                    component.set("v.selfResolutionNumber", 0);
                    component.set("v.selfResolutionAmount", 0.00);
                }
                else{
                   /* document.getElementById("cardHeader6").style.backgroundColor = "#32669E";
                    document.getElementById("rowHeader61").style.color = "#fff";
                    document.getElementById("rowHeader62").style.color = "#fff";
                    document.getElementById("rowHeader63").style.color = "#fff";*/
                    
                    document.getElementById("cardHeader6").style.backgroundColor = "rgba(0,166,211,0.17)";
                    document.getElementById("rowHeader61");
                    document.getElementById("rowHeader62");
                    document.getElementById("rowHeader63");
                }
                if(repaymentRecords==null || repaymentRecords=='' || repaymentRecords==undefined){
                    component.set("v.RepaymentprocessNumber", 0);
                    component.set("v.RepaymentprocessAmount", 0.00);
                }
                else{
                   /* document.getElementById("cardHeader8").style.backgroundColor = "#32669E";
                    document.getElementById("rowHeader81").style.color = "#fff";
                    document.getElementById("rowHeader82").style.color = "#fff";
                    document.getElementById("rowHeader83").style.color = "#fff";*/
                    
                    document.getElementById("cardHeader8").style.backgroundColor = "rgba(0,166,211,0.17)";
                    document.getElementById("rowHeader81");
                    document.getElementById("rowHeader82");
                    document.getElementById("rowHeader83");
                }
                if(lastYearRecords==null || lastYearRecords=='' || lastYearRecords==undefined){
                    component.set("v.repaidinthelastyearNumber", 0);
                    component.set("v.repaidinthelastyearAmount", 0.00);
                }
                else{
                  /*  document.getElementById("cardHeader9").style.backgroundColor = "#32669E";
                    document.getElementById("rowHeader91").style.color = "#fff";
                    document.getElementById("rowHeader92").style.color = "#fff";
                    document.getElementById("rowHeader93").style.color = "#fff";*/
                    
                    document.getElementById("cardHeader9").style.backgroundColor = "rgba(0,166,211,0.17)";
                    document.getElementById("rowHeader91");
                    document.getElementById("rowHeader92");
                    document.getElementById("rowHeader93");
                }
                component.set("v.heldBySafeDepositRecords", heldByRecords);
                component.set("v.inDisputeResolRecords", disputeRecords);
                component.set("v.RepaymentprocessRecords", repaymentRecords);
                component.set("v.repaidinthelastyearRecords", lastYearRecords);
            }
            else{
                //alert('Error...');
            }
        });
        $A.enqueueAction(action);
    }
})