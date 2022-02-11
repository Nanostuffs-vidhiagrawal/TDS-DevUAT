({
    doInit: function(component,event,helper){
         var IsaddDeposit = window.location.pathname;
        console.log('IsaddDeposit '+IsaddDeposit);
        if(IsaddDeposit.includes("adddeposit") || IsaddDeposit.includes("addproperty")){
            component.set("v.showhouseNo",true);
        }
    },
   
    showMandatory: function(component,event,helper){
       let usertype = event.getParam("arguments");
        if(usertype) {
            component.set("v.flagMandatory", usertype.flagvalue);
        }
        
    },
     hideBootstrapErrors: function(component, event) {
        var button_Name = event.target.name;
        switch (button_Name) {
            case "wrongPostCode":
                component.set("v.wrongPostCode", false);
                break;  
            case "noMatchFound":
                component.set("v.noMatchFound", false);
                break;   
        }
     },
    showClear:function (component,event,helper) {
        
        document.getElementById("clearButton").style.display = "block";
    },
    clearSearch: function(component,event,helper){
        var input = document.getElementById("searchBox2");
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
        component.set("v.Country","United Kingdom");
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