({
	doInit : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var redirectURL = 'https://thedisputeservice--staging--c.visualforce.com/apex/EI_ZD_MergeEvidenceInZip?type=case&id='+recordId;
        window.open(redirectURL);

	}
})