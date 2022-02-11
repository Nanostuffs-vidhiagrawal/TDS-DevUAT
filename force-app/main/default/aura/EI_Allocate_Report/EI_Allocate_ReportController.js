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
				if((result.Matched_Colour__c == '' || result.Matched_Colour__c == undefined) && (result.Installment__c != '' && result.Installment__c != undefined)){
					
					helper.showToast('Error!','This Payment is already allocated','error');
					$A.get("e.force:closeQuickAction").fire();
					
				}else{
					component.set("v.report", result);
					component.set("v.selectDAN", true);
				}
            }else{
				helper.showToast('Error!','Something went wrong','error');
			}
        });
        $A.enqueueAction(action);

		
	},
    closeWindow: function(component, event) {
		$A.get("e.force:closeQuickAction").fire();

    },


	allocate : function(component, event, helper) {
		
		
		var report = component.get("v.report");
        var numberDAN = component.get("v.numberDAN");
		if(numberDAN == '' || numberDAN == undefined ){
            
            helper.showToast('Error!','Please enter a DAN number','error');
            return ;

		}else{


			var action = component.get("c.allocateReport");
			action.setParams({
				report : report,
                numberDAN : numberDAN
				
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result == 'SUCCESS'){
                        $A.get("e.force:closeQuickAction").fire();
                	    window.location.reload();
                    }else{
                        helper.showToast('Error!',result,'error');
                    }
					
				}else{
					helper.showToast('Error!','Something went wrong','error');
				}
			});
			$A.enqueueAction(action); 
		}
		
        
	},
})