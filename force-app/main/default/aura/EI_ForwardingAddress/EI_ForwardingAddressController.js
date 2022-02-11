({
    doInit : function(component, event, helper) { 
        
        //alert('I am in')
        var allocationList = component.get("v.allocationList" );
        if(allocationList != undefined && allocationList != ''){
            component.set("v.tenantName" ,allocationList[0].Deposit_Holder__r.Name); 
        }
        
        
        
    },
	selectEmailAddress : function(component, event, helper) {
		
        component.set("v.showEmailInput" ,'Yes');
        component.set("v.selectForwardingAddress" ,'');
        component.set("v.showAddInput" ,'');
	},
    
    noEmailAddress : function(component, event, helper) {
		
        component.set("v.showEmailInput" ,'No');
    	component.set("v.selectForwardingAddress" ,'Yes');
	},
    showAddInput: function(component, event, helper) {
		

        component.set("v.showEmailInput" ,'No');

    	component.set("v.showAddInput" ,'Yes');
    	
	},
    hideAddInput: function(component, event, helper) {
		
		component.set("v.showAddInput" ,'No');
    	
	},
    
    saveData: function(component, event, helper) {
		
		//create first data in Database
		//after if data creation was success then move to next parameter in List 
		//if no next parameter then fire event for parent component 
		

        var depositId = component.get("v.depositId" );
        var allocationList = component.get("v.allocationList" );
        
        var action = component.get("c.updateAddress");
        action.setParams({
            allocation :allocationList[0],
            showEmailInput :component.get("v.showEmailInput" ),
            showAddInput :component.get("v.showAddInput" ),
            emailAddress:component.get("v.emailAddress" ),
            houseName:component.get("v.houseName" ),
            streetName:component.get("v.streetName" ),
            cityName:component.get("v.cityName" ),
            countryName:component.get("v.countryName" ),
            postCode:component.get("v.postCode" )
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			
            if (state === "SUCCESS") {
                
                
                //write all logic here 
                if(allocationList.length == 1 || allocationList.length < 1){
                    

                    var cmpEvent = component.getEvent("cmpEvent");
                    cmpEvent.setParams({
                        "flag" :true });
                    cmpEvent.fire();
                    //call Event to redirect back 
                }else{
                    allocationList.shift();
                    
                    component.set("v.allocationList" ,allocationList);
                    component.set("v.tenantName" ,allocationList[0].Deposit_Holder__r.Name); 
                    component.set("v.houseName" ,'');
                    component.set("v.streetName" ,'');
                    component.set("v.cityName" ,'');
                    component.set("v.countryName" ,'');
                    component.set("v.postCode" ,'');
                    component.set("v.emailAddress" ,'');
                    component.set("v.showEmailInput" ,'');
                    component.set("v.selectForwardingAddress" ,'');
                    component.set("v.showAddInput" ,'');
                    
                }
                    
                
                
                
            }else if (state === "INCOMPLETE") {
                
            }else if (state === "ERROR") {
                
				
                    
            }
        });
        
        $A.enqueueAction(action);
    	
        
	},
    
})