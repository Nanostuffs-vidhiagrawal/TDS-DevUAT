({
    DOM_Manupulation : function(component, depositRecievedDate, tenancyStartDate) {
         console.log("line 3 helper");
		 setTimeout(function(){
            document.getElementById("drd"+depositRecievedDate.substring(8, 10)).selected = true;
            document.getElementById("drm"+depositRecievedDate.substring(5, 7)).selected = true; 
            document.getElementById("dry"+depositRecievedDate.substring(0, 4)).selected = true;
            console.log("line 8 helper");
            document.getElementById("tsd"+tenancyStartDate.substring(8, 10)).selected = true;
            document.getElementById("tsm"+tenancyStartDate.substring(5, 7)).selected = true; 
            document.getElementById("tsy"+tenancyStartDate.substring(0, 4)).selected = true;
        }, 10);
        console.log("line 13 helper");
    }
    
})