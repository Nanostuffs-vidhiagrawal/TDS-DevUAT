({
    doInit : function(component, event, helper) { 
         component.set("v.checkedCount",0);
        var action = component.get("c.returnInboundReports");

        var splitList = component.get("v.splitList");
        splitList.length =splitList.length+1;
        component.set("v.splitList",splitList);
        

      	action.setParams({
             amount : 0,
             isFilter : false,
             filterType : '',
             startCreatedDate : null,
             endCreatedDate : null
             
         });
        
        action.setCallback(this, function(response) {
            component.set("v.spinner",true);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                
                component.set("v.inboundReportsList" ,result);
                component.set("v.spinner",false);
                
            }
            else if (state === "INCOMPLETE") {
                component.set("v.spinner",false);
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                // alert('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    component.set("v.spinner",false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            // component.set("v.spinner",false);
                            
                            //  alert("Error message: " +  errors[0].message);
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        //  component.set("v.spinner",false);
                        
                        //  alert("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    unallocate : function(component, event, helper) { 
        
        var idx = event.target.id;
        
        component.set("v.spinner",true);
        var inboundReports = component.get("v.inboundReportsList");
        var showError = false;
        if(idx == undefined || idx == ''){
            for (var element of inboundReports) {
                if(element.isSelected && element.objInboundReport.Matched_Colour__c == 'Red'){
                    showError = true;   
                    break;
                }
                
            }
        }
        
        if(showError){
            component.set("v.spinner",false);
            helper.showToast('Error!','Red Payments are already unallocated','error');
            
            //  alert('Red Payments are already unallocated');
            return;
        }
        //alert(JSON.stringify(inboundReports));
        var action = component.get("c.moveToRed");
        action.setParams({
            wrapperList : inboundReports,
            Id : idx,
            amount : component.get("v.filterAmount"),
            isFilter : component.get("v.isFilter"),
            filterType : component.get("v.selectedFilter"),
            startCreatedDate : component.get("v.startDate"),
            endCreatedDate : component.get("v.endDate")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                component.set("v.spinner",false);
                component.set("v.inboundReportsList" ,result);
            }
            else if (state === "INCOMPLETE") {
                component.set("v.spinner",false);
                
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                //alert('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    component.set("v.spinner",false);
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            
                            //  alert("Error message: " +  errors[0].message);
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        //  alert("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    allocateInboundReportsJS : function(component, event, helper) { 
        component.set("v.spinner",true);
        
        var idx = event.target.id;
        
        var inboundReports = component.get("v.inboundReportsList");
        
        var showError = false;
        for (var element of inboundReports) {
            if(element.isSelected && (element.objInboundReport.Matched_Colour__c == 'Red' || element.matchedColour == 'Blue')){
                showError = true;   
                break;
            }
            
        }
        
        if(showError){
            component.set("v.spinner",false);
            
            helper.showToast('Error!','Payments in Red/Blue can not be allocated','error');
            //  alert('Payments in Red can not be allocated');
            return;
        }
        
        var action = component.get("c.allocateInboundReports");
        
        action.setParams({
            wrapperList : inboundReports,
            Id : idx,
            amount : component.get("v.filterAmount"),
            isFilter : component.get("v.isFilter"),
            filterType : component.get("v.selectedFilter"),
            startCreatedDate : component.get("v.startDate"),
            endCreatedDate : component.get("v.endDate")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner",false);
                var result =response.getReturnValue();
                component.set("v.inboundReportsList" ,result);
            }
            else if (state === "INCOMPLETE") {
                component.set("v.spinner",false);
                
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                // alert('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    component.set("v.spinner",false);
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            
                            // alert("Error message: " +  errors[0].message);
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                        //   alert("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        
        component.set("v.spinner", true); 
        
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner  
        component.set("v.spinner", false); 
    },
    onCheck: function(component,event,helper){
   // component.set("v.disable",false);
           var count = component.get("v.checkedCount");
        if(event.getSource().get("v.value") == true){
         component.set("v.checkedCount",count+1);

             component.set("v.disable",false);
        } else{
            var c = count-1;
             component.set("v.checkedCount",c);
            if(c==0){
                component.set("v.disable",true);
            }
        }
    },

    selectAllGreen : function(component, event, helper) { 
        
        var count = 0;
        var inboundReportsList = component.get("v.inboundReportsList");
        var isGreen = false;
        for (var element of inboundReportsList) {
            if(element.matchedColour == 'Green'){
                element.isSelected = true;
                isGreen = true;
                count++;
            }else{
                element.isSelected = false;
            }
            
        }
        if(!isGreen){
            helper.showToast('Error!',"Error message: " +  'No green payments found','error');
            return ;
        }
        component.set("v.inboundReportsList" ,inboundReportsList);
        component.set("v.disable",false);
        component.set("v.checkedCount",count);
        
        
    },

    selectAllAmber : function(component, event, helper) { 
        
        var count = 0;
        var inboundReportsList = component.get("v.inboundReportsList");
        var isAmber = false;
        for (var element of inboundReportsList) {
            if(element.matchedColour == 'Amber'){
                element.isSelected = true;
                isAmber = true;
                count++;
            }else{
                element.isSelected = false;
            }
            
        }
        if(!isAmber){
            helper.showToast('Error!',"Error message: " +  'No amber payments found','error');
            return ;
        }
        component.set("v.inboundReportsList" ,inboundReportsList);
        component.set("v.disable",false);
        component.set("v.checkedCount",count);
        
        
    },

    deselectAll : function(component, event, helper) { 
        
        var inboundReportsList = component.get("v.inboundReportsList");
        for (var element of inboundReportsList) {
            
            element.isSelected = false;
            
        }
        
        component.set("v.inboundReportsList" ,inboundReportsList);
        component.set("v.disable",true);
        component.set("v.checkedCount",0);
        
        
    },
    refund : function(component, event, helper) { 
        
        var idx = event.target.id;
        
        component.set("v.spinner",true);
        var inboundReports = component.get("v.inboundReportsList");

        var action = component.get("c.refundPayment");
        action.setParams({
            wrapperList : inboundReports,
            Id : idx,
            amount : component.get("v.filterAmount"),
            isFilter : component.get("v.isFilter"),
            filterType : component.get("v.selectedFilter"),
            startCreatedDate : component.get("v.startDate"),
            endCreatedDate : component.get("v.endDate")
        });

        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.spinner",true);
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                component.set("v.spinner",false);
                component.set("v.inboundReportsList" ,result);
            }
            else if (state === "INCOMPLETE") {
                component.set("v.spinner",false);
                
                helper.showToast('Warning!','Process incomplete','warning'); 
                
                //alert('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    component.set("v.spinner",false);
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            component.set("v.spinner",false);
                             //alert("Error message: " +  errors[0].message);
                            helper.showToast('Error!',errors[0].message,'error');
                        }
                    } else {
                        component.set("v.spinner",false);
                        helper.showToast('Error!','Unknown error','error');
                        //  alert("Unknown error");
                        
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },

    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        var mainReportInstance = component.get("v.mainReportInstance");
        var idx = event.target.id;
        var inboundReportsList = component.get("v.inboundReportsList");
        for (var element of inboundReportsList) {
            
            if(element.objInboundReport.Id == idx){
                
                mainReportInstance = element;
                break;
            }
            
        }
        
        component.set("v.reasonForFlag","");
        component.set("v.reasonForFlagSpecified","");
        component.set("v.isModalOpen", true);
        component.set("v.selectReason", true);
        component.set("v.installmentId", idx);

        
        var splitList = [];
        splitList.length =splitList.length+1;
        component.set("v.splitList",splitList);
        component.set("v.mainReportInstance",mainReportInstance);
        
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        var splitList = [];
        component.set("v.isModalOpen", false);
        component.set("v.spinner",false);
        component.set("v.splitList",splitList);
    },
    addSplit: function(component, event, helper) {
        
        var splitList = component.get("v.splitList");
        var item = {
                    'newAmount' :undefined,
                    'reference':''}
        splitList.push(item);

        component.set("v.splitList",splitList);

    },
    removeSplit: function(component, event, helper) {
        
        var index = event.getSource().get("v.value");
        
        var splitList = component.get("v.splitList");
        splitList.splice(index, 1);
        component.set("v.splitList",splitList);
    },

    splitReport: function(component, event, helper) {
        
        var mainReportInstance = component.get("v.mainReportInstance");

        var splitLists = component.get("v.splitList");

        var totalSplit = 0;
        
        //use validations 

        if(splitLists.length < 2){

            helper.showToast('Error!','Minimum two rows are required for split','error');
            return ;
        }

        for(var i = 0; i < splitLists.length; i++){

            var element = splitLists[i]
            if(element == undefined){
                helper.showToast('Error!','Please enter all values','error');
                return;
            }
            if(element.reference == undefined || element.reference == '' || element.newAmount == undefined ){
                helper.showToast('Error!','Please enter all values','error');
                return;
            }else if(element.newAmount <= 0){
                helper.showToast('Error!','Entered amount should be greater than 0','error');
                return;
            }
            totalSplit += element.newAmount;
        }

        if(mainReportInstance.objInboundReport.Amount__c !=  totalSplit){
            helper.showToast('Error!','Total split amount should be equal to actual amount','error');
            return;
        }

        

        //call backend

        var action = component.get("c.splitPayment");
        action.setParams({
            splitList : splitLists,
            wrap : mainReportInstance,
            amount : component.get("v.filterAmount"),
            isFilter : component.get("v.isFilter"),
            filterType : component.get("v.selectedFilter"),
            startCreatedDate : component.get("v.startDate"),
            endCreatedDate : component.get("v.endDate")
        });
        action.setCallback(this, function(response) {
            component.set("v.spinner",true);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result =response.getReturnValue();
                component.set("v.inboundReportsList" ,result);
                component.set("v.spinner",false);
                component.set("v.isModalOpen", false);
                helper.showToast('Success','Process completed','success'); 
                
            }
            else if (state === "INCOMPLETE") {
                component.set("v.spinner",false);
                helper.showToast('Warning!','Process incomplete','warning'); 
                component.set("v.isModalOpen", false);
                // alert('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    component.set("v.spinner",false);
                    helper.showToast('Error!','Something went wrong','error');
                }
        });
        
        $A.enqueueAction(action);

    },
    closeModelFilter: function(component, event, helper) {
        
        component.set("v.isModalFilter", false);
        component.set("v.isFilterSelected", false);
        component.set("v.isFilterConfirmed", false);
        
    },
    openFilter: function(component, event, helper) {
        
        component.set("v.isModalFilter", true);
        component.set("v.isFilterSelected", true);
        component.set("v.isFilterConfirmed", false);
        
        
    },
    
    selectFilterType: function(component, event, helper) {
        
        var selectedType = component.get("v.selectedFilter");
        
        if(selectedType == undefined || selectedType == ''){
            
            helper.showToast('Error!','Please select a filter type','error');
            
            return ;
        }
        
        component.set("v.isFilterSelected", false);
        component.set("v.isFilterConfirmed", true);
        
        
    },
    
    confirmFilterType: function(component, event, helper) {
        
        component.set("v.spinner",true);
        var selectedType = component.get("v.selectedFilter");
        component.set("v.isFilter",true);
        if(selectedType == 'date'){
            //date validations
            component.set("v.spinner",true);
            
            var startDate = component.get("v.startDate");
            var endDate = component.get("v.endDate");
            
            
            
            if(endDate == null || endDate == undefined || endDate == '' || startDate == null || startDate == undefined || startDate == ''){
                helper.showToast('Error!','Please enter start and end date','error');
                component.set("v.spinner",false);
                return ;
            }
            
            
            var action = component.get("c.returnInboundReports");
            action.setParams({
                amount : 0,
                isFilter : true,
                filterType : 'date',
                startCreatedDate : startDate,
                endCreatedDate : endDate
                
            });
            
            action.setCallback(this, function(response) {
                component.set("v.spinner",true);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result =response.getReturnValue();
                    
                    component.set("v.inboundReportsList" ,result);
                    component.set("v.spinner",false);
                    
                    
                    component.set("v.isModalFilter", false);
                    component.set("v.isFilterSelected", false);
                    component.set("v.isFilterConfirmed", false);
                    
                    
                }
                else if (state === "INCOMPLETE") {
                    component.set("v.spinner",false);
                    helper.showToast('Warning!','Process incomplete','warning'); 
                    
                    // alert('INCOMPLETE');
                }
                    else if (state === "ERROR") {
                        component.set("v.spinner",false);
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            }
                        } else {
                            helper.showToast('Error!','Unknown error','error');
                        }
                    }
            });
            
            $A.enqueueAction(action);
            
        }else{
            var amount = component.get("v.filterAmount");
            
            if(amount == undefined || amount <= 0){
                
                helper.showToast('Error!','Please enter a positive amount','error');
                component.set("v.spinner",false);
                return;
            }
            var action = component.get("c.returnInboundReports");
            action.setParams({
                amount : amount,
                isFilter : true,
                filterType : 'amount',
                startCreatedDate : null,
                endCreatedDate : null
                
            });
            
            action.setCallback(this, function(response) {
                component.set("v.spinner",true);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result =response.getReturnValue();
                    
                    component.set("v.inboundReportsList" ,result);
                    component.set("v.spinner",false);
                    
                    
                    component.set("v.isModalFilter", false);
                    component.set("v.isFilterSelected", false);
                    component.set("v.isFilterConfirmed", false);
                    
                    
                }
                else if (state === "INCOMPLETE") {
                    component.set("v.spinner",false);
                    helper.showToast('Warning!','Process incomplete','warning'); 
                    
                    // alert('INCOMPLETE');
                }
                    else if (state === "ERROR") {
                        component.set("v.spinner",false);
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                helper.showToast('Error!',"Error message: " +  errors[0].message,'error');
                            }
                        } else {
                            helper.showToast('Error!','Unknown error','error');
                        }
                    }
            });
            
            $A.enqueueAction(action);
            
            
        }
        
        
        
        
    },
})