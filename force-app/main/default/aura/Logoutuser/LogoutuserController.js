({
	Logout : function(component, event, helper) {
	    let currentURL = window.location.origin;
        let redirectURL = currentURL +'/Landlord/secur/logout.jsp';
        window.location.replace(redirectURL);	
	}
})