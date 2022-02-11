({
    getPendingInstallment: function(component, event, depositId) {
        
          var action = component.get("c.getInstallment");
        action.setParams({ 
            depositId :depositId                   
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            console.log(res+' installmentrstate '+state);
            if(res.length>0){
                component.set("v.showAmmendMsg",true);
               component.set("v.Topupamount",res[0].Amount__c);
            }
            
        });
         $A.enqueueAction(action); 
    },
     deleteAttacRecord : function(component, event, helper) {
        var delAttachId =   component.get("v.data");
          var actionDel = component.get("c.deleteAttachment");
        actionDel.setParams({ 
            attachid :delAttachId                   
        });
        actionDel.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            console.log(res+' state '+state);
            
        });
         $A.enqueueAction(actionDel); 
    },
     getDPCHelper : function(component, event, helper) {
     	console.log('Testhelper');
      var depositId = component.get("v.depsumlist[0].objdeposit.Id");
        var action = component.get("c.getDPC2");
         action.setParams({ 
            depositId :depositId                   
        });
        action.setCallback(this, function(response) {
            console.log('action');
            var state = response.getState();
            var res = response.getReturnValue();
            console.log(res+' state '+state);
            if (state === "SUCCESS") {
                console.log('Testres '+res);
            component.set("v.data",res);
             window.open("/servlet/servlet.FileDownload?file="+res); 
                 setTimeout(function(){ 
                      console.log('123');
    		helper.deleteAttacRecord(component, event, helper);
               }, 1000);
            }
         
        });
        
        $A.enqueueAction(action);    
    },
      topUpHelper: function(component,event,helper,depositId,topUpVal,topUpAmnt) {
       console.log('topUpVal '+topUpVal);
            const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        var state;
        	if(branchId != null){
           		  state = {
         	 	  status: "held",
                id: depositId,
                branchId : branchId,
                      topUpVal:topUpVal,
                      topUpAmnt:topUpAmnt
        		};
            }else{
                  state = {
                    status: "held",
              	  id: depositId,
                 topUpVal:topUpVal,
                      topUpAmnt:topUpAmnt
                };
            }
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "paydeposit"
            },
            state: state
        });
    },
    getcurrentUserJobRole: function(component,event,helper) {
       //   setTimeout(function(){
        var currentUser = component.get("v.currentUser");
           // alert(currentUser.Contact.Job_role__c);
      if(currentUser.Contact.Job_role__c=='Dispute administrator' || currentUser.Contact.Job_role__c=='Deposit, property & dispute administrator' || currentUser.Contact.Job_role__c=='Head office administrator' || currentUser.Contact.Job_role__c=='Account administrator' || currentUser.Contact.Additional_Permission__c=='Submit evidence')
        {
       
            component.set("v.submitEvidence",true);
            //  alert('submit '+component.get("v.submitEvidence"));
            }
        if(currentUser.Contact.Job_role__c=='Deposit, property & dispute administrator' || currentUser.Contact.Job_role__c=='Deposit & property administrator'  || currentUser.Contact.Job_role__c=='Head office administrator' || currentUser.Contact.Job_role__c=='Account administrator' || currentUser.Contact.Additional_Permission__c=='Edit tenant details')
        {
            component.set("v.editTenant",true);
        }
         if(currentUser.Contact.Job_role__c=='Deposit, property & dispute administrator' || currentUser.Contact.Job_role__c=='Deposit & property administrator'  || currentUser.Contact.Job_role__c=='Head office administrator' || currentUser.Contact.Job_role__c=='Account administrator' || currentUser.Contact.Additional_Permission__c=='Edit landlord details')
        {
            component.set("v.editLandlord",true);
        }
       if(currentUser.Contact.Job_role__c=='Dispute administrator' || currentUser.Contact.Job_role__c=='Finance administrator' || currentUser.Contact.Job_role__c=='Deposit, property & dispute administrator' || currentUser.Contact.Job_role__c=='Deposit & property administrator'  || currentUser.Contact.Job_role__c=='Head office administrator' || currentUser.Contact.Job_role__c=='Account administrator' || currentUser.Contact.Additional_Permission__c=='Download PI')
        {
            component.set("v.downloadPI",true);
        }
           
       if(currentUser.Contact.Job_role__c.includes('Deposit') || currentUser.Contact.Job_role__c=='Head office administrator' || currentUser.Contact.Job_role__c=='Account administrator' || currentUser.Contact.Additional_Permission__c=='Respond to repayment request')
        {
        
            component.set("v.resRepayment",true);
        } 
        if(currentUser.Contact.Job_role__c.includes('Deposit') || currentUser.Contact.Job_role__c=='Head office administrator' || currentUser.Contact.Job_role__c=='Account administrator' || currentUser.Contact.Additional_Permission__c=='Request repayment')
        {
        
            component.set("v.reqRepayment",true);
        }       
     //       }, 800);
        
    },
	getAgentLandlordRepayRequest : function(component,event,depositId) {
		var action = component.get("c.getAgentLandlordRepaymentRequest");
        action.setParams({
            depositId :depositId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            var returnResult = a.getReturnValue();
            console.log('@@bank 2222222222'+returnResult+'5555555state'+state);
            if (state == "SUCCESS" ) {
                if(returnResult ==null || returnResult == ''){
                    component.set("v.repayRequestAgentLandlord",false);
                }
                else if(returnResult != '' || returnResult != null){
                   component.set("v.repayRequestAgentLandlord",true);
                   component.set("v.repayIdAgentLandlord",returnResult);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    getTenantRepayRequest : function(component,event,depositId) {
		var action = component.get("c.getTenantRepaymentRequest");
        action.setParams({
            depositId :depositId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            var returnResult = a.getReturnValue();
            console.log('@@bank 2222222222'+returnResult+'5555555state'+state);
            if (state == "SUCCESS" ) {
                if(returnResult ==null || returnResult == ''){
                    component.set("v.repayRequestTenant",false);
                }
                else if(returnResult != '' || returnResult != null){
                   component.set("v.repayRequestTenant",true);
                   component.set("v.repayIdTenant",returnResult);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    handleLeadTenant : function(component, event, depositId){
        
        let action = component.get('c.getLeadTenant');
        action.setParams({
            depositId : depositId
        });
        action.setCallback(this,result=>{
            let state = result.getState();
            if (state === "SUCCESS") {
            	component.set('v.isLeadTenant',result.getReturnValue());
            }else{
                let errors = result.getError();
                console.log('---Error--->>> '+JSON.stringify(errors));
                console.log("Error message>>>: " +JSON.stringify(errors[0].message));
            }
        });
        $A.enqueueAction(action);
    }
    
})