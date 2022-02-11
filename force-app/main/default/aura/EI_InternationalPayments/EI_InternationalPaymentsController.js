({
	doInit : function(component, event, helper) { 
        component.set("v.spinner",true);
        component.set("v.checkedCount",0);
        var action = component.get("c.returnInternationalInstallments");
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

        var action2 = component.get("c.getReasons");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var reasonMap = [];
                for(var key in result){
                    reasonMap.push({label: result[key], value: key});
                }
                component.set("v.reasonMap", reasonMap);
            }else{
				helper.showToast('Error!','Something went wrong','error');
			}
        });
        $A.enqueueAction(action2);
        
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

    markAsPaid : function(component, event, helper) { 
        
        
        var idx = event.target.id;
        
        var installmentList = component.get("v.installmentList");
        component.set("v.spinner",true);
        var action = component.get("c.paySelected");
        
        action.setParams({
            wrapperList : installmentList,
            Id : idx,
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
                component.set("v.spinner",false);
                var result =response.getReturnValue();
                component.set("v.installmentList" ,result);
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
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        var idx = event.target.id;
        component.set("v.reasonForFlag","");
        component.set("v.reasonForFlagSpecified","");
        component.set("v.isModalOpen", true);
        component.set("v.selectReason", true);
        component.set("v.installmentId", idx);
        
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.selectOtherReason", false);
        component.set("v.spinner",false);
        
    },
    
    flag : function(component, event, helper) {
        
		component.set("v.spinner",true);
		var reasonForFlag = component.get("v.reasonForFlag");
		if(reasonForFlag == '' || reasonForFlag == undefined ){
			helper.showToast('Error!','Please select flag reason','error');
			return;
		}else if(reasonForFlag == 'Other'){
			
			component.set("v.selectOtherReason", true);
			component.set("v.selectReason", false);
		}else{


			var action = component.get("c.updateInstallments");
			action.setParams({
				recId : component.get("v.installmentId"),
                reason : reasonForFlag,
                reasonSpecified : '',
				paymentType : 'International',
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
                    component.set("v.reasonForFlag","");
                    component.set("v.isModalOpen", false);
                    var result = response.getReturnValue();
                    component.set("v.installmentList" ,result);
                    component.set("v.spinner",false);
					
				}else{
					helper.showToast('Error!','Something went wrong','error');
                    component.set("v.spinner",false);
				}
			});
			$A.enqueueAction(action); 
		}
		
        
	},

	flagSpecified : function(component, event, helper) {
        
        component.set("v.spinner",true);
		var reasonForFlag = component.get("v.reasonForFlag");
        var reasonForFlagSpecified = component.get("v.reasonForFlagSpecified");
		var report = component.get("v.report");
		if(reasonForFlagSpecified == '' || reasonForFlagSpecified == undefined){
			helper.showToast('Error!','Please specify other reason','error');
			return;
		}else{

			var action = component.get("c.updateInstallments");
			action.setParams({
				recId : component.get("v.installmentId"),
                reason : reasonForFlag,
                reasonSpecified : reasonForFlagSpecified,
                paymentType : 'International',
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
					component.set("v.reasonForFlag","");
                    component.set("v.reasonForFlagSpecified","");
                    component.set("v.isModalOpen", false);
                    var result = response.getReturnValue();
                    component.set("v.spinner",false);
                    
                    component.set("v.installmentList" ,result);
				}else{
                    component.set("v.spinner",false);
					helper.showToast('Error!','Something went wrong','error');
				}
			});
			$A.enqueueAction(action); 
		}
		
        
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
            
            var action = component.get("c.returnInternationalInstallments");
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
            var action = component.get("c.returnInternationalInstallments");
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