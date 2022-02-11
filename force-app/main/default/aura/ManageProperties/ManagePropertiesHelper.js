({
  /* doInitHelper funcation to fetch all records, and set attributes value on component load */
  doInitHelper: function(component, event,selPickListValue) {
              const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
       console.log('@@ prop ');
    var action = component.get("c.fetchPropertylist");
        action.setParams({
             status : selPickListValue,
            branchId:branchId
        }); 
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var oRes = response.getReturnValue();
        console.log("line-->9  " + JSON.stringify(response.getReturnValue()));
        if (oRes.length > 0) {
            component.set("v.bNoRecordsFound", false);
          component.set("v.listOfPropertyAlocations", oRes);
          var pageSize = component.get("v.pageSize");
          var totalRecordsList = oRes;
          var totalLength = totalRecordsList.length;
          component.set("v.totalRecordsCount", totalLength);
          component.set("v.startPage", 0);
          component.set("v.endPage", pageSize - 1);
          var PaginationLst = [];
          for (var i = 0; i < pageSize; i++) {
            if (component.get("v.listOfPropertyAlocations").length > i) {
              PaginationLst.push(oRes[i]);
            }
          }
          component.set("v.PaginationList", PaginationLst);
          component.set("v.selectedCount", 0);
          //use Math.ceil() to Round a number upward to its nearest integer
          component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        } else {
             console.log("line-->9 ELSE" );
 			component.set("v.PaginationList", "");
            // if there is no records then display message
          component.set("v.bNoRecordsFound", true);
        }
      } else {
        //alert('Error...');
      }
    });
    $A.enqueueAction(action);
   // $A.get("e.force:refreshView").fire();
  },
  // navigate to next pagination record set
  next: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = end + 1; i < end + pageSize + 1; i++) {
      if (sObjectList.length > i) {
        {
          Paginationlist.push(sObjectList[i]);
        }
      }
      counter++;
    }
    start = start + counter;
    end = end + counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  },
    
  nextLandlord: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = end + 1; i < end + pageSize + 1; i++) {
      if (sObjectList.length > i) {
        {
          Paginationlist.push(sObjectList[i]);
        }
      }
      counter++;
    }
    start = start + counter;
    end = end + counter;
    component.set("v.startPageLandlord", start);
    component.set("v.endPageLandlord", end);
    component.set("v.PaginationLandlordList", Paginationlist);
  },
     previousLandlord: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = start - pageSize; i < start; i++) {
      if (i > -1) {
        {
          Paginationlist.push(sObjectList[i]);
        }
        counter++;
      } else {
        start++;
      }
    }
    start = start - counter;
    end = end - counter;
    component.set("v.startPageLandlord", start);
    component.set("v.endPageLandlord", end);
    component.set("v.PaginationLandlordList", Paginationlist);
  }, 
  // navigate to previous pagination record set
  previous: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = start - pageSize; i < start; i++) {
      if (i > -1) {
        {
          Paginationlist.push(sObjectList[i]);
        }
        counter++;
      } else {
        start++;
      }
    }
    start = start - counter;
    end = end - counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  },
  searchpropertylist: function(component, event) {
    // var vt= component.find("someId").get("v.value");
    // var searchInput = component.find("someId");
     var sel = document.getElementById("SelectItem");
    var selPickListValue = sel.options[sel.selectedIndex].value;
      
    var searchInput = document.getElementById("searchtext").value;
    //alert(searchInput);
      console.log('searchInput '+searchInput);
    var action = component.get("c.searchpropertylist");
    action.setParams({
      searchtext: searchInput,
        status : selPickListValue
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var oRes = response.getReturnValue();
        console.log("mila " + oRes.length);
        if (oRes.length > 0) {
            component.set("v.bNoRecordsFound", false);
          component.set("v.listOfPropertyAlocations", oRes);
          var pageSize = component.get("v.pageSize");
          var totalRecordsList = oRes;
          var totalLength = totalRecordsList.length;
          component.set("v.totalRecordsCount", totalLength);
          component.set("v.startPage", 0);
          component.set("v.endPage", pageSize - 1);
          var PaginationLst = [];
          for (var i = 0; i < pageSize; i++) {
            if (component.get("v.listOfPropertyAlocations").length > i) {
              PaginationLst.push(oRes[i]);
            }
          }
          component.set("v.PaginationList", PaginationLst);
          component.set("v.selectedCount", 0);
          //use Math.ceil() to Round a number upward to its nearest integer
          component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
        } else {
          // if there is no records then display message
          component.set("v.bNoRecordsFound", true);
        }
      } else {
        //alert('Error...');
      }
    });
    $A.enqueueAction(action);
  },
  // navigate to next pagination record set
  next: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = end + 1; i < end + pageSize + 1; i++) {
      if (sObjectList.length > i) {
        {
          Paginationlist.push(sObjectList[i]);
        }
      }
      counter++;
    }
    start = start + counter;
    end = end + counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  },
  // navigate to previous pagination record set
  previous: function(component, event, sObjectList, end, start, pageSize) {
    var Paginationlist = [];
    var counter = 0;
    for (var i = start - pageSize; i < start; i++) {
      if (i > -1) {
        {
          Paginationlist.push(sObjectList[i]);
        }
        counter++;
      } else {
        start++;
      }
    }
    start = start - counter;
    end = end - counter;
    component.set("v.startPage", start);
    component.set("v.endPage", end);
    component.set("v.PaginationList", Paginationlist);
  },

  PassVariable: function(component, event, helper) {
    var objChild = component.find("compB");
    component.set("v.Country", objChild.get("v.Country"));
    component.set("v.PostCode", objChild.get("v.PostCode"));
    component.set("v.Town", objChild.get("v.Town"));
    component.set("v.County", objChild.get("v.County"));
    component.set("v.LocalAreaCode", objChild.get("v.localAuthorityArea"));
    var StreetAddress;
    if (objChild.get("v.AddressLine1") != "undefined ") {
      StreetAddress =
        objChild.get("v.AddressLine1") + "\n " + objChild.get("v.Street");
    } else {
      StreetAddress = objChild.get("v.Street");
    }
    component.set("v.Street", StreetAddress);
  },

  navService: function(component) {
      const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const branchId = urlParams.get('branchId');
   //   alert(branchId);
      var state;
		if(branchId != null){
           		  state = {
                      branchId:branchId
        		};
            }else{
                  state = {
                  
                };
            }
   //   alert(state);
    component.find("navServiceMyProperty").navigate({
      type: "comm__namedPage",
      attributes: {
        pageName: "addproperty"
      },
      state: {state}
    });
  },
    
   getMyLandlords : function(component, event, helper) {
      console.log('@@ mylandlord');
        var searchTextValue =$("#searchValue").val();
        var action = component.get("c.myLandlordList");
        action.setParams({
            searchVar: null
        }); 
        action.setCallback(this, function (a) {
            var state = a.getState();
            var errors = a.getError();
            console.log(state);
            if (state == "SUCCESS") {
              //  console.log('returned value '+a.getReturnValue());
                if(a.getReturnValue()!=null){
                    
                    component.set("v.LandlordList",a.getReturnValue());
                    console.log('+++++++++LandlordList++++'+component.get("v.LandlordList"));
                  //  component.set("v.strRecordId",propertyRecId);                    
                    var pageSize = component.get("v.pageSizeLandlord");
                    var totalRecordsList = a.getReturnValue();
                    console.log('+++++++++totalRecordsList++++'+totalRecordsList);
                    var totalLength = totalRecordsList.length;
                    component.set("v.totalRecordsCountLandlord", totalLength);
                    component.set("v.startPageLandlord", 0);
                    component.set("v.endPageLandlord", pageSize - 1);
                    var PaginationLandlordList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.LandlordList").length > i) {
                            PaginationLandlordList.push(a.getReturnValue()[i]);
                        }
                    }console.log('+++++++++PaginationLandlordList++++'+JSON.stringify(PaginationLandlordList));
                    component.set("v.PaginationLandlordList", PaginationLandlordList);
                  //  console.log('++++++PaginationLandlordList+++++++'+component.get("v.PaginationLandlordList"));
                    component.set("v.selectedCount", 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCountLandlord", Math.ceil(totalLength / pageSize));
                    var xyz = getElementsByClassName("dataTables_empty");
                    for(i = 0; i < xyz.length; i++) {
                        xyz.style.visibility = 'hidden';
                    }
                    document.getElementsByClassName("dataTables_empty").style.visibility = 'hidden';
                }
                
            }
        });
        
        $A.enqueueAction(action);
    },
});