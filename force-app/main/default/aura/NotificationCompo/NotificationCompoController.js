({
  init: function (component, event, helper) {
     helper.doInitHelper(component, event,helper);
  }, 
       onDepositSummaryPage :function(component, event, helper){
           
         console.log('Line no 11--->',event.target.id);
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "depositsummarypage"
            },
            state: {
                id: event.target.id
                
            }
        });
        
    },
    
    onDepositAmountAmend : function(component, event, helper) {
        
          var selectedId = event.target.id;  
          
          var action = component.get('c.updateDeposit');
                action.setParams({depositId : selectedId});
                action.setCallback(this,function(response){
                   var State= response.getState();
                    console.log(':::State='+State);
                if(State==='SUCCESS'){
                    if(response.getReturnValue()=='success'){
                       
                         component.find("navService").navigate({
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "depositsummarypage"
                            },
                            state: {
                                id: event.target.id
                            }
                        });
                    }
                }
                             
		  });
             $A.enqueueAction(action);	
   } , 
       
    
     reviewChangeOver : function(component, event, helper) {
        var depositId = event.getSource().get("v.name");        
        if(typeof depositId != 'undefined'){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "tenantchangeoverresponsebyagll"
                },
                state: {
                    id : depositId,
                    tchange : true
                }
            });
        }
    },
    
     backController: function(component, event, helper) {
      window.history.back();
  	},
    
     outstandingAction : function(component, event, helper) {
        
		//var depositId = event.getSource().get("v.name");   
         var depositId = event.target.id;
        if(typeof depositId != 'undefined'){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "outstandingactions"
                },
                state: {
                    id : depositId,
                    tchange : true
                }
            });
        }        
    },
	
	navigation :  function(component, event, helper){
         var sObjectList = component.get("v.depositeList");
    var end = component.get("v.endPage");
    var start = component.get("v.startPage");
    var pageSize = component.get("v.pageSize");
    //var whichBtn = event.getSource().get("v.name");
    //
    // check if whichBtn value is 'next' then call 'next' helper method
    if (event.target.id == "nextId") {
      component.set("v.currentPage", component.get("v.currentPage") + 1);
      helper.next(component, event, sObjectList, end, start, pageSize);
    }
    // check if whichBtn value is 'previous' then call 'previous' helper method
    else if (event.target.id == "previousId") {
      component.set("v.currentPage", component.get("v.currentPage") - 1);
      helper.previous(component, event, sObjectList, end, start, pageSize);
    }
        
    }    
     
});