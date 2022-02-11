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
    showClear:function (component,event,helper) {
        
        document.getElementById("clearButtonLL").style.display = "block";
    },
    clearSearch: function(component,event,helper){
        var input = document.getElementById("searchBox2LL");
        input.value = "";
        document.getElementById("clearButtonLL").style.display = "none";	
    },
    
    showError: function(component,event,helper,message){
        var error = document.getElementById("errorMessageLL");
        error.innerText = message;
        error.style.display = "block";
        
        setTimeout(function(){
            error.style.display = "none";
        }, 10000)
    },
    enterManually:function (component,event,helper) {
        document.getElementById("manualAddress2LL").style.display = "block";
        document.getElementById("output2LL").style.display = "none";
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