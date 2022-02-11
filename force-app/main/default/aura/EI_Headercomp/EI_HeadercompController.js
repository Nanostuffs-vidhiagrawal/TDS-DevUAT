({
    resource: function(component, event, helper) {
        var name = component.get("v.currentUser.Name");
      
        var hashCode = stringToHash(name);
        console.log('hashCode '+hashCode);
         function stringToHash(string) {
                  
                var hash = 0;
                  
                if (string.length == 0) return hash;
                  
                for (var i = 0; i < string.length; i++) {
                    var char = string.charCodeAt(i);
                    hash = ((hash << 5) - hash) + char;
                    hash = hash & hash;
                }
                  
                return hash;
            }
         let currentURL = window.location.origin;
        let redirectURL = "https://xab195c-yuwehs-uwx3yxqtds.azurewebsites.net/resource-centre/?retUN="+hashCode;
        window.location.replace(redirectURL);
        
    },
    doneWaiting: function(component, event, helper) {
       setTimeout(function(){  component.set("v.PageSpinner",false); 
                                var cookie ={

		// read cookie to see if it's been set
			getCookie: function (strName) {
				var name = strName + "=";
				var ca = document.cookie.split(';');
				for (var i = 0; i < ca.length; i++) {
					var c = ca[i];
					while (c.charAt(0) == ' ') {
						c = c.substring(1);
					}
					if (c.indexOf(name) == 0) {
						return c.substring(name.length, c.length);
					}
				}
				return false;
			},
			
			// set cookie based on variables provided
			// domain set dynamically
			setCookie: function (strName, strValue,cntdays) {
				var days = cntdays != undefined && cntdays !== "" ? cntdays : 60,
					date = new Date(),
					domain = document.location.hostname;
				date.setTime(date.getTime() + ( 24 * 60 * 60 * 20));
				var expires = date.toUTCString();
				// handle secure vs regular http differently for cookie purposes
				if (location.protocol == 'http:') {
					document.cookie = strName + "=" + strValue + ";Expires=" + expires + ";Domain=" + domain + ";Path=/";
				} else {
					document.cookie = strName + "=" + strValue + ";Expires=" + expires + ";Domain=" + domain + ";Path=/;Secure";
				}
			},
						
						}
 				var name = component.get("v.currentUser.Name");
                 
                cookie.getCookie(name);
                cookie.setCookie("UName",name,1);
                         }, 2200);
    },
    
    
    doInitcheck : function(component, event, helper) {
        
      helper.checkUserProfile(component); 
      helper.tenantCountHelper(component, event, helper);
      helper.agllCountHelper(component, event, helper);
      helper.checkdeposit(component, event);
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
         const branchUser = urlParams.get('branchUser');
       
        if(branchUser == 'true'){
         //   component.set("v.branchLoggedIn",true);
         //    alert('branchUser' +branchUser);
        }
        if(branchId != null){
            component.set("v.branchLoggedIn",true);
            component.set("v.logggedBranch",false);
                component.set("v.checkIfBranch",true);
        }else{
            component.set("v.branchLoggedIn",false);
            component.set("v.logggedBranch",true);
                component.set("v.checkIfBranch",false);
        }
        
    },
    
    
    doInit : function(component, event, helper) {

        if(component.get("v.UpdateHeader")){
            $A.get('e.force:refreshView').fire();
        }
        
          var queryString = window.location.href.split('/').pop();
           // var spinner = component.find("mySpinner");
         console.log('22 '+queryString);
         setTimeout(function(){  
              
             	if(queryString.includes('updatemydetails')){
                      console.log('222 ');
                   $("#sf-setting-tab").addClass("active");
                   }
                   if(queryString == 'manageyouraddresses'){
           			  $("#sf-Portfolio-tab").addClass("active");
                      }
                            if(queryString == ''){ 
            $("#sf-deposit-tab").addClass("active");  } 
                 
               }, 1000);
       /*   setTimeout(function(){   
                  if(queryString == ''){
            
           var element = document.getElementById('sf-deposit-tab');
            $("#sf-deposit-tab").addClass("active");
       
                         
                 }
                 if(queryString == 'updatemydetails'){
           var element = document.getElementById('sf-deposit-tab');
   
          $("#sf-setting-tab").addClass("active");
                         
                 }
 			if(queryString == 'manageyouraddresses'){
           var element = document.getElementById('sf-deposit-tab');
       
          $("#sf-Portfolio-tab").addClass("active");
                         
                 }*/

           
        //    }, 800);
          

  

       
			
     
    },
    homepage: function (component, event, helper) {   
     
       
        var urlfull = window.location.href;
       
         const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
          const redirect = urlParams.get('redirect');
         
        if(urlfull.includes('depositsummarypage') && redirect){
            console.log('test');
                if(branchId != null){
                component.find("navService").navigate({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "viewdeposit"
                    },
                    state: {branchId: branchId,redirect: true}
                });
            }else{
                component.find("navService").navigate({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "home"
                    },
                    state: {redirect:true}
                });
            }
        }else{
            if(branchId != null){
                component.find("navService").navigate({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "viewdeposit"
                    },
                    state: {branchId: branchId}
                });
            }else{
                component.find("navService").navigate({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "home"
                    },
                    state: {}
                });
            }
            
        }
       
    },
    
    AddDeposit: function (component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        
        if(branchId != null){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "adddeposit"
                },
                state: {branchId: branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "adddeposit"
                },
                state: {}
            });
        }
    },
    
    Viewdeposit: function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        //alert(event.getSource());
        
        // var title = event.getSource().get("v.label");
        //  alert(title);
        if(branchId != null){
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "viewdeposit"
                },
                state: {
                    branchId: branchId
                }
            });
        }
        else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "viewdeposit"
                },
                state: {
                    
                }
            });
        }
    },
    
    tenentdeposits: function(component, event, helper) {
    component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "home"
            },
            state: {}
        });    
        
    },
    
   tenentdetails: function(component, event, helper) {
    component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "my-details"
            },
            state: {}
        });    
        
    },
    
    recentlydeleted: function(component, event, helper) {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){   
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "recentlydeleteddeposit"
                },
                state: {branchId: branchId}
            });
        }
        else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "recentlydeleteddeposit"
                },
                state: {}
            });
        }
    },
    
    openBulkActions: function(component, event, helper) {
           const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
       
        if(branchId != null){    
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "bulkactions"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "bulkactions"
                },
                state: {}
            });
        }
    },
    
    openMyDetailsPage: function(component, event, helper) {
  
        
       /*  event.preventDefault();
        var urlRedirect = $A.get("$Label.c.Lightning_Component_URL")+"updatemydetails";
        window.location.replace(urlRedirect);
        return false;*/
          const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "updatemydetails"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "updatemydetails"
                },
                state: {}
            }); 
        }
    },
    
    manageyouraddresses: function(component, event, helper) {
        //   var title = event.getSource().get("v.label");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){ 
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageyouraddresses"
                },
                state: {}
            }); 
        }
    },
    
    updatemydetails: function(component, event, helper) {
        //  var title = event.getSource().get("v.label");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){    
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "updatemydetails"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "updatemydetails"
                },
                state: {}
            });
        }
    },
    
    reporting: function(component, event, helper) {
        //   var title = event.getSource().get("v.label");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
       
        if(branchId != null){    
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "reporting"
                },
                state: {branchId : branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "reporting"
                },
                state: {}
            });  
        }
    },
    
    manageusers: function(component, event, helper) {
        //  var title = event.getSource().get("v.label");
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
        if(branchId != null){    
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageusers"
                },
                state: {branchid : branchId}
            });
        }else{
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "manageusers"
                },
                state: {}
            });
        }
    },
    
    logout: function (component, event, helper) {

		var name = component.get("v.currentUser.Name");
	/*	let x = document.cookie;
        console.log('cook ' + x);
       document.cookie = "UName="+name+" ; Expires = 1980-02-02T18:06:21.466Z;path=/;";
		let x2 = document.cookie;
        console.log('cook2 ' + x2);*/
      var cookie ={
          setCookie: function (strName, strValue,cntdays) {
				var days = cntdays != undefined && cntdays !== "" ? cntdays : 60,
					date = new Date(),
					domain = document.location.hostname;
				date.setTime(date.getTime() - ( 24 * 60 * 60 * 1000));
				var expires = date.toUTCString();
				// handle secure vs regular http differently for cookie purposes
				if (location.protocol == 'http:') {
					document.cookie = strName + "=" + strValue + ";Expires=" + expires + ";Domain=" + domain + ";Path=/";
				} else {
					document.cookie = strName + "=" + strValue + ";Expires=" + expires + ";Domain=" + domain + ";Path=/;Secure";
				}
			}
      }
         cookie.setCookie("UName",name,1);
        let currentURL = window.location.origin;
        let redirectURL = $A.get("$Label.c.Lightning_CommunityLogout_URL")+"secur/logout.jsp?retUrl="+$A.get("$Label.c.Lightning_CommunityLogout_URL")+"login";
        window.location.replace(redirectURL);
    },
    
     tenantNotificationController : function (component, event, helper){
        
         var action = component.get("c.getLoggedInUserProfile");
         action.setCallback(this, function(response) {
             let state = response.getState();
             if (state === "SUCCESS") {
                 let result = response.getReturnValue();
                 component.set('v.profileName',result);
                 console.log('line--> 8' + JSON.stringify(result));
                 //  component.set('v.loggedInUser',true);
                const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
                  var retState;
              if(branchId != null){
           		  retState = {
                branchId : branchId
        		};
            }else{
                  retState = {
                 
                };
            }
                 if(result == 'Tenant'){
                     component.find("navService").navigate({
                         type: "comm__namedPage",
                         attributes: {
                             pageName: "tenentnotification"
                         },
                         state:retState
                     });
        
            }
                 else{
                   //  alert("result ?? " + result);
                     
                     component.find("navService").navigate({
                         type: "comm__namedPage",
                         attributes: {
                             pageName: "agllnotifications"
                         },
                         state:retState
                     });
                 }
                   
             }
         });
    $A.enqueueAction(action);
     },
    
    communityreport : function (component, event, helper){
        //alert('line no 366');
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
       
        if(branchId != null){    
            component.find("navService").navigate({
                type: "comm__namedPage",
                attributes: {
                    pageName: "sdscommunityreport"
                },
                state: {branchId : branchId}
            });
        }else{
            
        
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: "sdscommunityreport"
            },
            state: {
               // depositId: depositId
            }
         });
    		}
     }


})