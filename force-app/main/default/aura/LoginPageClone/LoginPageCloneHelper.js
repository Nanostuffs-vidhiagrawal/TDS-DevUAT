({
    getCookies: function(component, event, helper){
        
        
        
        
                    //Load in cookie control
            var config = {
            apiKey: 'e96f43fb0a542d5ac3ce08623887465e1a0888bf',
            product: 'PRO_MULTISITE',
            initialState: "NOTIFY",
            layout: "slideout",
            acceptBehaviour: "recommended",
            statement: {
            description: 'For more information visit our',
            name: 'Privacy Statement',
            url: '/privacy-policy/',
            updated: '26/10/2018'
            },
            notifyDismissButton: false,
            rejectButton: false,
            logConsent: false,
            necessaryCookies: ['PHPSESSID', 'shopping_cart', 'popup_suppression', 'wordpress_logged_in_*', 'word_press_sec_*', 'wp-settings-*'],
            optionalCookies: [
            {
            name: 'analytics',
            lawfulBasis: 'legitimate interest',
            label: 'Analytical Cookies',
            description: 'Analytical cookies help us to improve our website by collecting and reporting information on its usage.',
            cookies: ['_ga', '_gid', '_gat', '__utma', '__utmt', '__utmb', '__utmc', '__utmz', '__utmv',
            '_hjClosedSurveyInvites', '_hjDonePolls', '_hjMinimizedPolls', '_hjDoneTestersWidgets',
            '_hjMinimizedTestersWidgets', '_hjIncludedInSample', '_hjShownFeedbackMessage'
            ],
            recommendedState: true,
            onAccept: function () {
            // Add Google tag manager
            $.getScript('https://www.googletagmanager.com/gtag/js?id='+google_tag_manager_id);
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', google_tag_manager_id, {'anonymize_ip': true});
            // End Google tag manager
            
            
            
            // Add Google Analytics
            (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
            
            
            
            ga('create', google_analytics_id, 'auto');
            ga('set', 'anonymizeIp', true);
            ga('send', 'pageview');
            // End Google Analytics
            
            
            
            //Hotjar Tracking Code
            (function(h,o,t,j,a,r){
            h.hj=h.hj||function(){(h.hj.q=h.hj.q||[]).push(arguments)};
            h._hjSettings={hjid:1705545,hjsv:6};
            a=o.getElementsByTagName('head')[0];
            r=o.createElement('script');r.async=1;
            r.src=t+h._hjSettings.hjid+j+h._hjSettings.hjsv;
            a.appendChild(r);
            })(window,document,'https://static.hotjar.com/c/hotjar-','.js?sv=');
            
            
            
            //Microsoft UET
            (function(w,d,t,r,u){
            var f,n,i;w[u]=w[u]||[],f=function(){var o={ti:microsoft_uet_id};
            o.q=w[u],w[u]=new UET(o),w[u].push("pageLoad")},
            n=d.createElement(t),n.src=r,n.async=1,n.
            onload=n.onreadystatechange=function(){
            var s=this.readyState;s&&s!=="loaded"&&s!=="complete"||(f(),
            n.onload=n.onreadystatechange=null)
            },
            i=d.getElementsByTagName(t)[0],
            i.parentNode.insertBefore(n,i)
            })(window,document,"script","//bat.bing.com/bat.js","uetq");
            
            
            
            },
            onRevoke: function () {
            // Disable Google Analytics
            window['ga-disable-'+google_analytics_id] = true;
            
            
            
            // Disable Microsoft UET
            window['_uetmsdns'] = true;
            
            
            
            },
            
            
            
            thirdPartyCookies: [{"name": "Hotjar", "optOutLink": "https://www.hotjar.com/legal/compliance/opt-out"}],
            
            
            
            }
            ],
            position: 'right',
            theme: 'dark',
            
            
            
            text: {
            notifyDescription: 'We use cookies to optimise site functionality. By continuing to use this website, you are consenting to the use of all cookies. You can manage your preferences within the settings, or your browser preferences.',
            notifyTitle: 'Your choice regarding cookies on this site'
            }
            };
            
            
           console.log('config '+JSON.stringify(config));
        var Cong = CookieControl.load(config);
         console.log('Cong '+Cong);
         //  console.log('config2 '+ window.CookieControl.load(config)); 
         //   window.CookieControl.load(config);
    },
    getUrlParams : function(paramName) {
        //debugger;
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
    
    gotoURL : function (url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    
    getInputHelper: function (component, event, helper){
       component.set("v.mylabel1","");
        var isValid = true;
        
        // Get the Username from Component
        var user = component.find('uname').getElement().value;
        var Pass = component.find('pass').getElement().value;
        
        console.log(user+Pass);
        if(typeof user == 'undefined' || user == '' || user == null){
            component.set("v.UserNameError",true);    
            isValid = false;
        }
        if(typeof Pass == 'undefined' || Pass == '' || Pass == null){
            component.set("v.PasswordError",true);    
            isValid = false;
        }
        console.log('@@ '+isValid); 
        if(isValid){
            component.set("v.UserNameError",false);
            component.set("v.PasswordError",false);                
            
            var redURL = helper.getUrlParams('startURL');
             console.log('@@ redURL '+redURL); 
            var action;
            if(redURL && redURL.includes('redirect-to-payment-page')){
                action = component.get("c.checkPortalRedirect");
                
                action.setParams({
                    username: user,
                    password: Pass,
                    isEncoded:false,
                    pageURL : redURL
                });
            }else{
                 console.log('@@ in else '); 
                action = component.get("c.checkPortal");
                
                action.setParams({
                    username: user,
                    password: Pass,
                    isEncoded:false,
                });
            }
            
            action.setCallback(this, function (response) {
              //  debugger;
                var state = response.getState();
                if(state == "SUCCESS"){
                    //alert(helper.getUrlParams('startURL'));
                    try{
                        var landingURL = response.getReturnValue();
                         console.log('@@ in landingURL '+landingURL); 
                     //   debugger;
                        if(landingURL.includes('failed')){// Your login attempt has failed. Make sure the username and password are correct.
                            if (landingURL !== null) {
                                       if(landingURL ==='Your login attempt has failed. Make sure the username and password are correct.'){
                                           //component.set("v.mylabel",rtnValue);
                                           component.set("v.message",'Your login attempt has failed. Make sure the username and password are correct.');
                                           component.set("v.errorMessage",true);    
                                           isValid = false;
                                       }else if(landingURL ==="UserNameError"){
                                           component.set("v.message",' Please fill the username');
                                           component.set("v.errorMessage",true);    
                                           isValid = false;
                                           //component.set("v.mylabel","Please fill the username");
                                       }else if(landingURL ==="PasswordError"){
                                           component.set("v.message",' Please fill the Password');
                                           component.set("v.errorMessage",true);    
                                           isValid = false;
                                           //component.set("v.mylabel","Please fill the Password");
                                       }
                                       //component.set("v.showError",true);
                                   }
                            
                            
                          //  window.open(redURL,"_self");
                        }else
                        /*if(!redURL)
                            helper.gotoURL(redURL);
                        else*/
                        	window.open(landingURL,"_self");
                        /**/
                    }catch(e){}
                    
                    
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            
                            if(errors[0].message ==='Your login attempt has failed. Make sure the username and password are correct.'){
                                component.set("v.message",' Your login attempt has failed. Make sure the username and password are correct.');
                                component.set("v.errorMessage",true);    
                                isValid = false;
                            }
                            
                        }
                    } 
                }                
            });
           // debugger;
            // Send action off to be executed
            $A.enqueueAction(action);        
        }
},
    
    getError:function (component, event, helper){
       
        var action = component.get("c.fetchErrorLabel");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){               
      //  console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
            component.set("v.errorList",response.getReturnValue());
                  var   errorList= component.get("v.errorList");  
                	var userErr;
                
              for(var i=0; i<errorList.length; i++){
              //    console.log("line-->9  " +errorList[i].MasterLabel );
              //     console.log("line-->9  " +errorList[i].Error_Message__c );
                  if(errorList[i].MasterLabel === 'User Error'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.UserNameErrorNew",userErr);
                  }
                     else if(errorList[i].MasterLabel === 'Password Error'){
                      userErr = errorList[i].Error_Message__c;
                  component.set("v.PasswordErrorNew",userErr);
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