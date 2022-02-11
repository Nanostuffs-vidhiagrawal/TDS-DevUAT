({
	handleInit : function(component, event, helper) {
     //   debugger;
		//var pageReference = component.get("v.pageReference");
        //    component.set("v.draftId", pageReference.state.uid);
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const draftId = urlParams.get('draftId');
        if(draftId != undefined && draftId != ''){
             helper.transferToPay(component,event, draftId);
        }else{
            helper.getDraftId(component, event,helper);
        }
      //  component.set("v.draftId", draftId);
        
       // 
	}
})