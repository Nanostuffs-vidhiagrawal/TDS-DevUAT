({
    doInit: function(component,event,helper){
        
    },
    showClear:function (component,event,helper) {
        document.getElementById("clearButton").style.display = "block";
    },
    clearSearch: function(component,event,helper){
        var input = document.getElementById("searchBox");
        input.value = "";
        document.getElementById("clearButton").style.display = "none";	
    },
    
    showError: function(component,event,helper,message){
        var error = document.getElementById("errorMessage");
        error.innerText = message;
        error.style.display = "block";
        
        setTimeout(function(){
            error.style.display = "none";
        }, 10000)
    },
    enterManually:function (component,event,helper) {
        document.getElementById("manualAddress2").style.display = "block";
        document.getElementById("output2").style.display = "none";
        
    },
    enterSearch:function (component,event,helper) {
        if (event.keyCode == 13){
            helper.findAddress(component,event,helper);
            
        }
    },
    findAddress1:function (component,event,helper) {
        
        helper.findAddress(component,event,helper);
    },
    
})