({
    doInit: function(component,event,helper){
          var IsaddDeposit = window.location.pathname;
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
        document.getElementById("manualAddress").style.display = "block";
        document.getElementById("output").style.display = "none";
         component.set("v.Country","United Kingdom");
    },
    enterSearch:function (component,event,helper) {
        if (event.keyCode == 13){
            helper.findAddress(component,event,helper);
            
        }
    },
    findAddress1:function (component,event,helper) {
//alert('@@');        
    
        var searchTxt =  document.getElementById("searchBox").value;
        console.log('searchTxt.length '+searchTxt.length);
    	if(searchTxt.length ==3)
             helper.findAddress(component,event,helper);
             
       

    },
    
})