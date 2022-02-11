({
	doInit : function(component, event, helper) {
		var action = component.get("c.getInboundReport");
		action.setParams({
            reportId : component.get("v.recordId"),
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				if((result.Matched_Colour__c != '' && result.Matched_Colour__c != undefined) || result.Installment__c == ''){
					
					helper.showToast('Error!','This Payment is not allocated yet','error');
					$A.get("e.force:closeQuickAction").fire();
					
				}else if(result.Installment__c != '' && result.Installment__c != undefined &&  result.Installment__r.Installment_Type__c != 'Receivable'){
					helper.showToast('Error!','Only Receivable Payment can be Unallocated','error');
					$A.get("e.force:closeQuickAction").fire();
				}else{
					component.set("v.report", result);
					component.set("v.selectReason", true);
				}
            }else{
				helper.showToast('Error!','Something went wrong','error');
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

	closeWindow: function(component, event) {
		$A.get("e.force:closeQuickAction").fire();

    },


	unallocate : function(component, event, helper) {
		
		
		var report = component.get("v.report");
		if(report.Reason_For_Unallocation__c == '' || report.Reason_For_Unallocation__c == undefined ){
			helper.showToast('Error!','Please select unallocation reason','error');
			return;
		}else if(report.Reason_For_Unallocation__c == 'Other'){
			
			component.set("v.selectOtherReason", true);
			component.set("v.selectReason", false);
		}else{

			//Unallocate Payment updateReport

			var action = component.get("c.updateReport");
			action.setParams({
				report : report
				
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					$A.get("e.force:closeQuickAction").fire();
                	window.location.reload();
				}else{
					helper.showToast('Error!','Something went wrong','error');
				}
			});
			$A.enqueueAction(action); 
		}
		
        
	},

	unallocateOther : function(component, event, helper) {
		
		
		var report = component.get("v.report");
		if(report.Reason_For_Unallocation_Specified__c == '' || report.Reason_For_Unallocation_Specified__c == undefined){
			helper.showToast('Error!','Please specify other reason','error');
			return;
		}else{

			//Unallocate Payment
			var action = component.get("c.updateReport");
			action.setParams({
				report : report
				
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					$A.get("e.force:closeQuickAction").fire();
                	window.location.reload();
				}else{
					helper.showToast('Error!','Something went wrong','error');
				}
			});
			$A.enqueueAction(action); 
		}
		
        
	},
})