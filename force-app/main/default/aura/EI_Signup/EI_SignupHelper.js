({
    PassVariable : function(component, event, helper) {
        var objChild = component.find("compB");
       
        component.set("v.Country", objChild.get("v.Country"));
        component.set("v.PostCode", objChild.get("v.PostCode"));
        component.set("v.Town", objChild.get("v.Town"));
        component.set("v.County", objChild.get("v.County"));
        var StreetAddress;
        if (objChild.get("v.AddressLine1") != "undefined ") {
            StreetAddress =
                objChild.get("v.AddressLine1") + "\n " + objChild.get("v.Street");
        } else {
            StreetAddress = objChild.get("v.Street");
        }
        component.set("v.Street", StreetAddress);
      //  console.log('objChild.get("v.Country") '+objChild.get("v.Country"));
    },
    
    getDraftIdfromURL : function(url) {
        debugger;
		var querystring =  url.split('?');
        if(querystring && querystring.length > 1){
            querystring = querystring[1];
        }
        
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        
        return paramValue["draftId"];
	},
    
    calledFromCertificateBuilder: function() {
		var querystring = location.search.substr(1);
        return querystring.includes('draftId');
	},
    
    getUrlParams : function(paramName) {
        debugger;
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
    
    errorToast: function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Oops!",
            "message": message
        });
        toastEvent.fire();
	},
    
    fetchPhoneCodePicklist : function(component, event, helper){
        var action = component.get("c.getPhoneCodePiclistValues");
        action.setCallback(this, function(a) {
            console.log("phoneCodePicklist : " + a.getReturnValue());
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.phoneCodePicklist", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    
    getError:function (component, event, helper){
       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
        console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
            component.set("v.errorList",response.getReturnValue());
                  var   errorList= component.get("v.errorList");                 
                	var userErr;
                
              for(var i=0; i<errorList.length; i++){
                  //console.log("line-->9  " +errorList[i].MasterLabel );
                   //console.log("line-->9  " +errorList[i].Error_Message__c );
                  if(errorList[i].MasterLabel === 'Registration Page'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.regPageErrorNew",userErr);
                  }
                  else if(errorList[i].MasterLabel === 'Title'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.titleErrorNew",userErr);
                  }  
                  
                     else if(errorList[i].MasterLabel === 'First Name'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.firstNameErrorNew",userErr);
                  }            
                  
                  else if(errorList[i].MasterLabel === 'Surname'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.surNameErrorNew",userErr);
                  }
                  else if(errorList[i].MasterLabel === 'Email'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.emailErrorNew",userErr);
                  }    
                  else if(errorList[i].MasterLabel === 'Address'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.addressErrorNew",userErr);
                  }    
                  else if(errorList[i].MasterLabel === 'Phone Number'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.phoneErrorNew",userErr);
                  }    
                  else if(errorList[i].MasterLabel === 'Valid Email'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.validEmailErrorNew",userErr);
                  }          
                  
                }
            }
            else{
                console.log('something went wrong');
            }
        });
        $A.enqueueAction(action);
    }

    
})