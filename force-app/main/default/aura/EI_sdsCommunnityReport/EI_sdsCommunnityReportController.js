({
	historicDeposite : function(component, event, helper) {
        // alert('line no 3');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "historicdepositrepayments"
            },
            state: {
               // depositId: depositId
            }
         });
    
     },
    
    
    
   closedDeposits : function(component, event, helper) {
        // alert('line no 3');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "closeddeposits"
            },
            state: {
               // depositId: depositId
            }
         });
    
     },
    
    
    depositInfoByStatus : function(component, event, helper) {
        // alert('line no 3');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositinfobystatus"
            },
            state: {
               // depositId: depositId
            }
         });
    
     },
    
    archivedDeposits:function(component, event, helper) {
         //alert('line no 3');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "archiveddeposits"
            },
            state: {
               // depositId: depositId
            }
         });
    
     },
    
     paymentsToYou:function(component, event, helper) {
        // alert('line no 3');
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "paymentstoyou"
            },
            state: {
               // depositId: depositId
            }
         });
    
     }
    
    
    
   
       
		
	
})