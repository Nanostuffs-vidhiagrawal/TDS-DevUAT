({
    findAddress:function (component,event,helper,SecondFind) {
        var Text = document.getElementById("searchBox").value;
          var availableopts = [];
     console.log('Text '+Text);
        if (Text === "") {
            showError("Please enter an address");
            return;
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
        params += "&Access-Control-Allow-Origin=" + "https://uat-thedisputeservice.cs87.force.com";
        
        var http = new XMLHttpRequest();
        http.open('POST', url, true);
        http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
         http.setRequestHeader('Access-Control-Allow-Origin', 'https://uat-thedisputeservice.cs87.force.com');
        http.onreadystatechange = function() {
         //   alert('@@http.status '+http.status+url); 
            if (http.readyState == 4 && http.status == 200) {
                var response = JSON.parse(http.responseText);
              //  console.log('++response++++'+JSON.stringify(response));
                if (response.Items.length == 1 && typeof(response.Items[0].Error) != "undefined") {
                    showError(response.Items[0].Description);
                }
                else {
                    if (response.Items.length == 0)
                        showError("Sorry, there were no results");
                    
                    else {
                        var resultBox = document.getElementById("result");
                        
                        if (resultBox.childNodes.length > 0) {
                            var selectBox = document.getElementById("mySelect");
                            selectBox.parentNode.removeChild(selectBox)
                        }
                        
                        var resultArea = document.getElementById("result");
                     /*   var list = document.createElement("select");
                        list.id = "selectList";
                        list.setAttribute("id", "mySelect");
                        list.setAttribute("class", "selectin");
                        resultArea.appendChild(list);
                  //        alert('@@list '+list); 
                        var defaultOption = document.createElement("option");
                        defaultOption.text = "Select Address";
                        defaultOption.setAttribute("value", "");
                        defaultOption.setAttribute("selected", "selected");
                        list.appendChild(defaultOption);
                       */
                        for (var i = 0; i < response.Items.length; i++){
                            console.log('response 105 '+response);
                           availableopts.push(response.Items[i].Text + " " + response.Items[i].Description);
                             console.log('availableopts 105 '+availableopts);
                            var option = document.createElement("option"); 
                            option.setAttribute("value", response.Items[i].Id)
                            option.text = response.Items[i].Text + " " + response.Items[i].Description;
                            option.setAttribute("class", response.Items[i].Type)
                            
                          //  list.appendChild(option);
                        }
                        console.log('response listlist '+availableopts);
                       
                            console.log('inloos');
                            $( "#searchBox" ).autocomplete({
                              source: availableopts
                            });
                         
                       
                       // helper.selectAddress(component,event,helper,Key);
                        
                    }
                }
            }
        }
        http.send(params);
    },  
    
    selectAddress:function (component,event,helper,Key){
        var resultList = document.getElementById("result");
        
        if (resultList.childNodes.length > 0) {		
            var elem = document.getElementById("mySelect");
            //IE fix 
            elem.addEventListener('change', function() {
                var addressExist = false;
                var postcodeExist = false;
                
                var target = document.getElementById('mySelect').value; 
                var targetclassName =document.getElementsByClassName('Address');
                var targetclassName2 =document.getElementsByClassName('Postcode');   
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
                     //     console.log('line-->177 ' +JSON.stringify(res));
                          var resBox = document.getElementById("output");
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
                          
                          //   var i;
                          
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
                        //  console.log(response.Items[0].Line3+' --<addressline-->>'+addressline); 
                       //     console.log('BuildingNumber-->>'+response.Items[0].BuildingNumber); 
                       //     console.log('BuildingName-->>'+response.Items[0].BuildingName); 
                       //       console.log('SubBuilding-->>'+response.Items[0].SubBuilding); 
                      //    console.log('Test record-->>'+response.Items[0].AdminAreaName);
                          component.set("v.localAuthorityArea", response.Items[0].AdminAreaName);
                          /*   if(arr.length > 5){
                var addressline = arr[arr.length-6] + ' \n ' +arr[arr.length-5];
               
                component.set('v.AddressLine1',addressline);
            }
            else{
                 component.set('v.AddressLine1',arr[arr.length-5]);
            }
            
      */
             // alert( component.get('v.PostCode'));
              var vx = component.get("v.method");
              $A.enqueueAction(vx);   
              
              document.getElementById("output").style.display = "block";
              document.getElementById("seperator").style.display = "block";
            
              document.getElementById("manualAddress").style.display = "none";
              
             }
      }
  }
}
http.send(params); 
}
})