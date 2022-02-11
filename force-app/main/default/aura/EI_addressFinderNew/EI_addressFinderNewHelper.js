({
  findAddress: function (component, event, helper, SecondFind) {
    // console.log("@@ findaddress ");
    var Text = document.getElementById("searchBox").value;

    if (Text === "") {
      showError("Please enter an address");
      return;
    }

    var Container = "";

    if (SecondFind !== undefined) {
      Container = SecondFind;
    }

    var Key = "HY74-ZH36-YE14-BM91",
      IsMiddleware = false,
      Origin = "",
      Countries = "GBR",
      Limit = "10",
      Language = "en-gb",
      url =
        "https://services.postcodeanywhere.co.uk/Capture/Interactive/Find/v1.10/json3.ws";
    var params = "";
    params += "&Key=" + encodeURIComponent(Key);
    params += "&Text=" + encodeURIComponent(Text);
    params += "&IsMiddleware=" + encodeURIComponent(IsMiddleware);
    params += "&Container=" + encodeURIComponent(Container);
    params += "&Origin=" + encodeURIComponent(Origin);
    params += "&Countries=" + encodeURIComponent(Countries);
    params += "&Limit=" + encodeURIComponent(Limit);
    params += "&Language=" + encodeURIComponent(Language);

    // console.log("URL" + url);
    var http = new XMLHttpRequest();
    http.open("POST", url, true);
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    http.onreadystatechange = function () {
      if (http.readyState == 4 && http.status == 200) {
        var response = JSON.parse(http.responseText);
        if (
          response.Items.length == 1 &&
          typeof response.Items[0].Error != "undefined"
        ) {
          showError(response.Items[0].Description);
        } else {
          if (response.Items.length == 0)
            showError("Sorry, there were no results");
          else {
            var resultBox = document.getElementById("result");

            if (resultBox.childNodes.length > 0) {
              var selectBox = document.getElementById("mySelect");
              selectBox.parentNode.removeChild(selectBox);
            }

            var resultArea = document.getElementById("result");
            var list = document.createElement("select");
            list.id = "selectList";
            list.setAttribute("id", "mySelect");
            list.setAttribute("class", "selectin");
            resultArea.appendChild(list);

            var defaultOption = document.createElement("option");
            defaultOption.text = "Select Address";
            defaultOption.setAttribute("value", "");
            defaultOption.setAttribute("selected", "selected");
            list.appendChild(defaultOption);

            for (var i = 0; i < response.Items.length; i++) {
              // console.log("response 105 " + response);
              var option = document.createElement("option");
              option.setAttribute("value", response.Items[i].Id);
              option.text =
                response.Items[i].Text + " " + response.Items[i].Description;
              option.setAttribute("class", response.Items[i].Type);

              list.appendChild(option);
            }
            // console.log("@@BeforeSelectAddress ");
            helper.selectAddress(component, event, helper, Key);
          }
        }
      }
    };
    http.send(params);
  },

  selectAddress: function (component, event, helper, Key) {
    // console.log("@@ Select1");
    var resultList = document.getElementById("result");

    if (resultList.childNodes.length > 0) {
      var elem = document.getElementById("mySelect");
      // console.log("@@ Select2 elem" + elem);
      //IE fix
      elem.addEventListener("change", function () {
        var addressExist = false;
        var postcodeExist = false;

        // console.log("102 ");
        var target = document.getElementById("mySelect").value;
        var targetclassName = document.getElementsByClassName("Address");
        var targetclassName2 = document.getElementsByClassName("Postcode");
        // console.log("106 ");
        // console.log("107");
        // document.getElementById("output").style.display = "block";
        var i;
        for (i = 0; i < targetclassName.length; i++) {
          if (target == targetclassName[i].value) {
            addressExist = true;
          }
        }
        var j;
        for (j = 0; j < targetclassName2.length; j++) {
          // console.log('+++++'+ targetclassName2[j].value);
          if (target == targetclassName2[j].value) {
            //   console.log('+++++ IN IF');
            postcodeExist = true;
          }
        }

        if (addressExist === true) {
          // console.log("@@ target true");
          helper.retrieveAddress(component, event, Key, target);
        } else {
          // console.log("@@ target false");
          helper.findAddress(component, event, helper, target);
        }
      });
    }
  },

  retrieveAddress: function (component, event, Key, Id) {
    var Field1Format = "";
    var url =
      "https://services.postcodeanywhere.co.uk/Capture/Interactive/Retrieve/v1.00/json3.ws";
    var params = "";
    params += "&Key=" + encodeURIComponent(Key);
    params += "&Id=" + encodeURIComponent(Id);
    params += "&Field1Format=" + encodeURIComponent(Field1Format);

    var http = new XMLHttpRequest();
    http.open("POST", url, true);
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    http.onreadystatechange = function () {
      if (http.readyState == 4 && http.status == 200) {
        var response = JSON.parse(http.responseText);

        if (
          response.Items.length == 1 &&
          typeof response.Items[0].Error != "undefined"
        ) {
          showError(response.Items[0].Description);
        } else {
          if (response.Items.length == 0)
            showError("Sorry, there were no results");
          else {
            var addressline;

            if (
              response.Items[0].Line1 != "" &&
              response.Items[0].Line2 != "" &&
              response.Items[0].Line3 != ""
            ) {
              addressline =
                response.Items[0].Line1 +
                "\n" +
                response.Items[0].Line2 +
                "\n" +
                response.Items[0].Line3;
            } else if (
              response.Items[0].Line1 != "" &&
              response.Items[0].Line2 == "" &&
              response.Items[0].Line3 == ""
            ) {
              addressline = response.Items[0].Line1;
            } else if (
              response.Items[0].Line1 == "" &&
              response.Items[0].Line2 != "" &&
              response.Items[0].Line3 == ""
            ) {
              addressline = response.Items[0].Line2;
            } else if (
              response.Items[0].Line1 == "" &&
              response.Items[0].Line2 == "" &&
              response.Items[0].Line3 != ""
            ) {
              addressline = response.Items[0].Line3;
            } else if (
              response.Items[0].Line1 != "" &&
              response.Items[0].Line2 != "" &&
              response.Items[0].Line3 == ""
            ) {
              addressline =
                response.Items[0].Line1 + "\n" + response.Items[0].Line2;
            } else if (
              response.Items[0].Line1 != "" &&
              response.Items[0].Line2 == "" &&
              response.Items[0].Line3 != ""
            ) {
              addressline =
                response.Items[0].Line1 + "\n" + response.Items[0].Line3;
            } else if (
              response.Items[0].Line1 == "" &&
              response.Items[0].Line2 != "" &&
              response.Items[0].Line3 != ""
            ) {
              addressline =
                response.Items[0].Line2 + "\n" + response.Items[0].Line3;
            }
            console.log("addressline:", addressline);

            var res = response.Items[0];
            var resBox = document.getElementById("output");
            var fullAddress;
            if (response.Items[0].Province == "") {
              fullAddress =
                addressline +
                "\n" +
                response.Items[0].City +
                "\n" +
                response.Items[0].PostalCode +
                "\n" +
                response.Items[0].CountryName;
            } else {
              fullAddress =
                addressline +
                "\n" +
                response.Items[0].City +
                "\n" +
                response.Items[0].Province +
                "\n" +
                response.Items[0].PostalCode +
                "\n" +
                response.Items[0].CountryName;
            }
            resBox.innerText = fullAddress;
            var addressvalue = res.Label;
            // console.log("resbox" + resBox + " % " + res + " @ " + addressvalue);
            // console.log("fullAddress", fullAddress);
            var arr;
            arr = addressvalue.split("\n");

            //   var i;

            // component.set("v.Country", response.Items[0].CountryName);
            // component.set("v.PostCode", response.Items[0].PostalCode);
            // component.set("v.Town", response.Items[0].City);
            // component.set("v.AddressLine1", addressline);
            // component.set("v.AddressLine1", response.Items[0].Line3);
            // component.set("v.County", response.Items[0].Province);

            component.set("v.Country", response.Items[0].CountryName);
            component.set("v.PostCode", response.Items[0].PostalCode);
            component.set("v.Town", response.Items[0].City);
            component.set("v.AddressLine1", addressline);
            component.set("v.Street", response.Items[0].Line3);
            component.set("v.County", response.Items[0].Province);

            // alert(component.get("v.Country"));
            // alert(component.get("v.PostCode"));
            // alert(component.get("v.Town"));
            // alert(component.get("v.AddressLine1"));
            // // alert(component.get("v.County"));
            // alert(component.get("v.County"));

            /*   if(arr.length > 5){
                var addressline = arr[arr.length-6] + ' \n ' +arr[arr.length-5];

                component.set('v.AddressLine1',addressline);
            }
            else{
                 component.set('v.AddressLine1',arr[arr.length-5]);
            }

      */
            var vx = component.get("v.method");
            // document.getElementById("output").style.display = "block";
            document.getElementById("seperator").style.display = "block";
            document.getElementById("EnterButton").style.display = "none";
            document.getElementById("manualAddress").style.display = "none";
          }
        }
      }

      $A.enqueueAction(vx);
    };
    http.send(params);
  }
});