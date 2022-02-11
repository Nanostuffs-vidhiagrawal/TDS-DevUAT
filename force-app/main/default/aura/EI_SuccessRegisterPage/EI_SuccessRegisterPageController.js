({
    doInit: function(component,event,helper){
        const queryString = window.location.search;
        
        const urlParams = new URLSearchParams(queryString);
        
        const page_type = urlParams.get('uid');
        if(page_type[0] == 'T')
        {
            component.set("v.showTenantBlock",true);
        }
        else
        {
            component.set("v.showTenantBlock",false);
        }
        
        
        component.set("v.MemberID",page_type);
        
    }
})