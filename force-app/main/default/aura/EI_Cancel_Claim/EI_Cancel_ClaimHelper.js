({
	getUrlParams : function(paramName) {
      //  debugger;
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const params = window.location.search.substring(1).split('&');
        
        var paramMap = [];
        for(let p of params){
            if(p){
                let pName = p.split("=")[0];
                let pval = p.split("=")[1];
                
                paramMap[pName] = pval;
            }
        }
        
        return decodeURIComponent(paramMap[paramName]);
    },
    redirectToEvidenceGatheringPage : function(component, event, helper) {
        let depositid = helper.getUrlParams('depositId');

        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "tenant-evidence-gathering"
            },
            state: {
                depositId : depositid,
                leadTenant : this.getUrlParams('leadTenant')
            }
        });
    },
	helperMethod : function() {
		
	}
})