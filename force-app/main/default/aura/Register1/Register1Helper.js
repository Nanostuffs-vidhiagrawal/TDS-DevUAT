({
    findAddress:function (component,event,helper,SecondFind) {
        var Text = document.getElementById("searchBox2").value;
        
        if (Text === "") {
            showError("Please enter an address");
            return null;
        }
        
        var Container = "";			
        
        
        if (SecondFind !== undefined){
            Container = SecondFind;
        } 
        
        var Key = $A.get("$Label.c.Loqate_key"),
            IsMiddleware = false,
            Origin = "",
            Countries = "GBR",
            Limit = "10",
            Language = "en-gb",  
            url = 'https://services.postcodeanywhere.co.uk/Capture/Interactive/Find/v1.10/json3.ws';
        var params = '';
        params += "&Key=" + encodeURIComponent(Key);
        params += "&Text=" + encodeURIComponent(Text);
        params += "&IsMiddleware=" + encodeURIComponent(IsMiddleware);
        params += "&Container=" + encodeURIComponent(Container);
        params += "&Origin=" + encodeURIComponent(Origin);
        params += "&Countries=" + encodeURIComponent(Countries);
        params += "&Limit=" + encodeURIComponent(Limit);
        params += "&Language=" + encodeURIComponent(Language);
        
        var http = new XMLHttpRequest();
        http.open('POST', url, true);
        http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        http.onreadystatechange = function() {
            if (http.readyState == 4 && http.status == 200) {
                var response = JSON.parse(http.responseText);
                console.log('++response++++'+JSON.stringify(response));
                if (response.Items.length == 1 && typeof(response.Items[0].Error) != "undefined") {
                    showError(response.Items[0].Description);
                }
                else {
                    console.log('Error '+response.Items.length);
                    if (response.Items.length == 0){
                         console.log('no data');
                        component.set("v.noMatchFound",true);
                        showError("Sorry, there were no results");}
                       
                    else {
                        var resultBox = document.getElementById("result2");
                        
                        if (resultBox.childNodes.length > 0) {
                            var selectBox = document.getElementById("mySelect1");
                            selectBox.parentNode.removeChild(selectBox)
                        }
                        
                        var resultArea = document.getElementById("result2");
                        var list = document.createElement("select");
                        list.id = "selectList";
                        list.setAttribute("id", "mySelect1");
                        list.setAttribute("class", "selectin");
                        resultArea.appendChild(list);
                        
                        var defaultOption = document.createElement("option");
                        defaultOption.text = "Select Address";
                        defaultOption.setAttribute("value", "");
                        defaultOption.setAttribute("selected", "selected");
                        list.appendChild(defaultOption);
                       
                        for (var i = 0; i < response.Items.length; i++){
                            console.log('response 105 '+response);
                            var option = document.createElement("option"); 
                            option.setAttribute("value", response.Items[i].Id)
                            option.text = response.Items[i].Text + " " + response.Items[i].Description;
                            option.setAttribute("class", response.Items[i].Type)
                            
                            list.appendChild(option);
                        }
                        
                        helper.selectAddress(component,event,helper,Key);
                        
                    }
                }
            }
        }
        http.send(params);
    },  
    
    selectAddress:function (component,event,helper,Key){
        var resultList = document.getElementById("result2");
        
        if (resultList.childNodes.length > 0) {		
            var elem = document.getElementById("mySelect1");
              var elem2 = document.getElementById("result2");
            //IE fix 
            elem.addEventListener('change', function() {
                var addressExist = false;
                var postcodeExist = false;
                
                var target = document.getElementById('mySelect1').value; 
                var targetclassName =document.getElementsByClassName('Address');
                var targetclassName2 =document.getElementsByClassName('Postcode');   
              //   console.log('+++++ targetclassName2 '+targetclassName2);
                var i;
                for (i = 0; i < targetclassName.length; i++) {
                    
                    if(target  == targetclassName[i].value){
                        
                        addressExist = true;
                    }
                    
                }
                var j;
                for (j = 0; j < targetclassName2.length; j++) {
                    // console.log('+++++'+ targetclassName2[j].value);
                    if(target  == targetclassName2[j].value){
                        //   console.log('+++++ IN IF');
                        postcodeExist = true;
                    }
                    
                }
                
                if (addressExist === true){
                    helper.retrieveAddress(component,event,Key, target);
                    
                    
                }
                
                else {
                    helper.findAddress(component,event,helper,target)
                }	
                
            });	

            
        }
    },
    
    retrieveAddress:function (component,event,Key, Id){
        var Field1Format = "";
        var url = 'https://services.postcodeanywhere.co.uk/Capture/Interactive/Retrieve/v1.00/json3.ws';
        var params = '';
        params += "&Key=" + encodeURIComponent(Key);
        params += "&Id=" + encodeURIComponent(Id);
        params += "&Field1Format=" + encodeURIComponent(Field1Format);
        
        var http = new XMLHttpRequest();
        http.open('POST', url, true);
        http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
        http.onreadystatechange = function() {
            if (http.readyState == 4 && http.status == 200) {
                var response = JSON.parse(http.responseText);
               
                if (response.Items.length == 1 && typeof(response.Items[0].Error) != "undefined") {
                    showError(response.Items[0].Description);
                }
                else {
                    if (response.Items.length == 0)
                        showError("Sorry, there were no results");
                    else {  var addressline;   
                          if(response.Items[0].Line1 != '' && response.Items[0].Line2 != '' && response.Items[0].Line3 != '')
                          {  addressline = response.Items[0].Line1 + '\n' +response.Items[0].Line2 +'\n'+response.Items[0].Line3 ;}
                          else if(response.Items[0].Line1 != '' && response.Items[0].Line2 == '' && response.Items[0].Line3 == ''){
                              addressline = response.Items[0].Line1; }
                              else if(response.Items[0].Line1 == '' && response.Items[0].Line2 != '' && response.Items[0].Line3 == ''){
                                  addressline = response.Items[0].Line2;  
                              }
                                  else if(response.Items[0].Line1 == '' && response.Items[0].Line2 == '' && response.Items[0].Line3 != ''){
                                      addressline = response.Items[0].Line3;  
                                  }
                                      else if(response.Items[0].Line1 != '' && response.Items[0].Line2 != '' && response.Items[0].Line3 == ''){
                                          addressline = response.Items[0].Line1 + '\n' +response.Items[0].Line2;
                                      }
                                          else if(response.Items[0].Line1 != '' && response.Items[0].Line2 == '' && response.Items[0].Line3 != ''){
                                              addressline = response.Items[0].Line1 + '\n' +response.Items[0].Line3;
                                          }
                                              else if(response.Items[0].Line1 == '' && response.Items[0].Line2 != '' && response.Items[0].Line3 != ''){
                                                  addressline = response.Items[0].Line2 + '\n' +response.Items[0].Line3;
                                              }
                          
                          var res = response.Items[0];
                          console.log('line-->177 ' +JSON.stringify(res));
                          var resBox = document.getElementById("output2");
                          var fullAddress;
                          if(response.Items[0].Province == ''){
                              fullAddress = addressline +'\n'+response.Items[0].City+'\n'+response.Items[0].PostalCode+'\n'+response.Items[0].CountryName;
                          }else{
                              fullAddress = addressline +'\n'+response.Items[0].City+'\n'+response.Items[0].Province+'\n'+response.Items[0].PostalCode+'\n'+response.Items[0].CountryName;
                              
                          }
                          resBox.innerText = fullAddress;	
                          var addressvalue = res.Label;
                          var arr ;
                          arr = addressvalue.split("\n");
                          
                         var postCodeAcc = response.Items[0].PostalCode;
                          var res;
                           console.log('postCodeAcc '+postCodeAcc);
                          var allPostCodes = component.get("v.propList");
                          console.log(allPostCodes.length +' allPostCodes '+allPostCodes);
                          if(allPostCodes != '' || allPostCodes.length != 0){
                                for(let  i=0;i<allPostCodes.length;i++){
                            //   console.log(i+' ** '+allPostCodes[i]+' ^^ '+postCodeAcc);
                              if(postCodeAcc.startsWith(allPostCodes[i])){
                                   console.log('true');
                                  res = true;
                                  break;
                              }else{
                                   console.log('false');
                                  res=false;
                              }
                         	 }
                          }else{ res = true;}
                        
                    /*      var checkDuplicacy = component.get("c.contains");
                        checkDuplicacy.setParams({
                            postcode: postCodeAcc
                        });
                      console.log('checkDuplicacy '+checkDuplicacy);
                        checkDuplicacy.setCallback(this, function (response) {
                            var state = response.getState();
                             console.log('state '+state);
                            res =  response.getReturnValue();
                            console.log('resPostCodeFound '+res);
                        });
                          $A.enqueueAction(checkDuplicacy); 
                            setTimeout(function(){ */
                                  console.log('OUT '+res);
                          if(res == true){
                           
                           console.log('in IFres '+res);
                            component.set('v.wrongPostCode',false); 
                          
                          
                             component.set('v.Country',response.Items[0].CountryName);
                          component.set('v.PostCode',response.Items[0].PostalCode);
                          component.set('v.Town',response.Items[0].City);
                          component.set('v.AddressLine1',addressline);
                          component.set('v.Street',response.Items[0].Line3);
                          component.set('v.County',response.Items[0].Province);
                          if(response.Items[0].BuildingNumber == ''){
                                component.set('v.houseNo',response.Items[0].BuildingName);
                          }else{
                              component.set('v.houseNo',response.Items[0].BuildingNumber);}
                          
                          component.set("v.localAuthorityArea", response.Items[0].AdminAreaName);
                             
                   var vx = component.get("v.method");
                  $A.enqueueAction(vx);   
                  
                  document.getElementById("output2").style.display = "block";
                  document.getElementById("seperator2").style.display = "block";
                
                  document.getElementById("manualAddress2").style.display = "none";
                           
                          }
                          else if(res == false){
                                console.log('reselse '+res);
                                component.set('v.wrongPostCode',true); 
                             component.set('v.Country','');
                          component.set('v.PostCode','');
                          component.set('v.Town','');
                          component.set('v.AddressLine1','');
                          component.set('v.Street','');
                          component.set('v.County','');
                                 document.getElementById("output2").style.display = "none";
                  document.getElementById("seperator2").style.display = "none";
                
                  document.getElementById("manualAddress2").style.display = "none";
                          }
                         //  }, 1000);       
                          /*   if(arr.length > 5){
                var addressline = arr[arr.length-6] + ' \n ' +arr[arr.length-5];
               
                component.set('v.AddressLine1',addressline);
            }
            else{
                 component.set('v.AddressLine1',arr[arr.length-5]);
            }
            
      */
                         
              
              
             }
      }
  }
}
        
http.send(params); 
}
})