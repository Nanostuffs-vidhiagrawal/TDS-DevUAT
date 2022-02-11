({
    getloggedInTenants : function(component, event, helper) {
      var action = component.get("c.getLoggedInUserAccountId");

        action.setCallback(this, function(result){
            component.set("v.loggedinTenant",result.getReturnValue());
         //   alert(result.getReturnValue());
        });
          $A.enqueueAction(action);
    },
	getChangeOverTenants : function() {
	/*	   var currentURL = window.location.href;
        var depositId;
         var tenantChangeOver;
          var queryString = window.location.search;
      var urlParams = new URLSearchParams(queryString);
       depositId = urlParams.get('id');
       tenantChangeOver = urlParams.get('tchange');
        var bankDetails = urlParams.get('bankDetails');
        //alert('34'+depositId +bankDetails+tenantChangeOver);
  
        var action = component.get("c.getdeposittenantdetails");
        action.setParams({
            depositId:depositId
        });
        action.setCallback(this, function(result){
            var state = result.getState();
             
            if (component.isValid() && state === "SUCCESS"){
                
                component.set("v.deptenantlist",result.getReturnValue());
                var resResult = result.getReturnValue();
                console.log('line-->13' + JSON.stringify(result.getReturnValue()));
              //   console.log('line-->26'+resResult.length + JSON.stringify(resResult[1].Depallobject));
                component.set("v.olddepositid",depositId);
            
                component.set("v.newtenancycomponent",false);
                
                  var House = new Array();
                console.log('31 '+House);
                var i;
                          for(i = 1;i<resResult.length;i++){
                             
                                
                          //  console.log('House[i] '+House[i]);
                             
                                  House[i-1] = resResult[i].Depallobject;  
                            
                              
                                console.log('line-->35'+ JSON.stringify(resResult[i].Depallobject));
                              
                              
                          }
                      if(tenantChangeOver == 'true'){
                   
             component.set("v.updatechangeovertenant",House); 
                          var alltenant = component.find('alltenant');
                         $A.util.addClass(alltenant, 'alltenantshow');
                        component.set("v.changeovertenants",true);
                           component.set("v.viewCorrectButton",true);
                        
                    }
                else if(bankDetails == 'true'){
                   
                    component.set("v.tenantChange",true);
         			    component.set("v.updatechangeovertenant",House); 
                      var alltenant = component.find('alltenant');
              		    $A.util.removeClass(alltenant, 'alltenantshow');
                   
                }
                else{
                 
                        var alltenant = component.find('alltenant');
              		    $A.util.removeClass(alltenant, 'alltenantshow');
                }
                
            }
        });
        $A.enqueueAction(action);
        */
	}
})