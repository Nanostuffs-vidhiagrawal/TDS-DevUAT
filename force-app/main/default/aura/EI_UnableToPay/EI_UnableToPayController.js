({
	doInit : function(component, event, helper) { 
        
        var action = component.get("c.getUnableInstallments");
        component.set("v.spinner",true);
       
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
                
                component.set("v.installmentList" ,result);
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
                        }
                    } else {
                        helper.showToast('Error!','Unknown error','error');
                    }
                }
        });
        
        $A.enqueueAction(action);
        
    },

	showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        
        component.set("v.spinner", true); 
        
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner  
        component.set("v.spinner", false); 
    },
    closeModel: function(component, event, helper) {
        
        component.set("v.isModalOpen", false);
        component.set("v.isFilterSelected", false);
        component.set("v.isFilterConfirmed", false);
        
    },
    openFilter: function(component, event, helper) {
        
        component.set("v.isModalOpen", true);
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
            var action = component.get("c.getUnableInstallments");
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
                    
                    component.set("v.installmentList" ,result);
                    component.set("v.spinner",false);
                    
                    
                    component.set("v.isModalOpen", false);
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
            var action = component.get("c.getUnableInstallments");
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
                    
                    component.set("v.installmentList" ,result);
                    component.set("v.spinner",false);
                    
                    
                    component.set("v.isModalOpen", false);
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