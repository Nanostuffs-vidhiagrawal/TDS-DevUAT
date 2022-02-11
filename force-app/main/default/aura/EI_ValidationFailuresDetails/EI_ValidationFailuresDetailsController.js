({    
    CreateRecord: function (component, event, helper) {
        // alert("create records");
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        //alert(file);
        if (file){
            component.set("v.showResult", true);
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                
                var csv = evt.target.result;
                console.log(' file.name => ' +  file.name);
                var filename =  file.name;
                var result = helper.CSV2JSON(component, csv, filename);
                // console.log('result list of Deposits => ' + result);
                // helper.CreateDeposits(component,result);
                
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
            component.set("v.showcard", true);

        }
        
    },

    handleShowErrorDetails : function(component, event, helper){
        component.set("v.showErrorDetails", true);
    },
    
    showfiledata :  function (component, event, helper){        
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];

        if (file) {
            component.set("v.showcard", true);
            console.log("File => " + file);
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var table = document.createElement("table");
                var rows = csv.split("\n");
                
                for (var i = 0; i < rows.length; i++) {

                    var cells = rows[i].replaceAll(",", "");
                    if(cells.trim() != ""){
                        
                        cells = rows[i].split(",");
                       
                        var row = table.insertRow(-1);
                        for (var j = 0; j < cells.length; j++) {
                            var cell = row.insertCell(-1);
                            cell.innerHTML = cells[j];
                        }
                    }
                }

                var divCSV = document.getElementById("divCSV");
                divCSV.innerHTML = "";
                divCSV.appendChild(table);
            }
            reader.onerror = function (evt) {
                console.log("error reading file");
            }
        }
    },    
    
    doInit : function (component, event, helper){
        var importLogs = [];
        for(let i=0; i<10; i++){
            var data =  {date: i+'/1/2021',
                         validateOnly: i%2 ?'Yes':'No',
                         fileName: 'fileName' + i,
                         status: i%2 ?'Success':'Failed',
                         tenancies: i*5,
                         tenants: (i*10) + 5,
                         landlords: (i*5)+5,
                         failures: (i*2)+5
                        };
            importLogs.push(data);
        }
        console.log('importLogs => ' + importLogs);
        component.set("v.totalImportLogsList", importLogs);
        // Pagination
        var pageSize = component.get("v.pageSize");
        var totalRecordsList = importLogs;
        var totalLength = totalRecordsList.length;
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.startPage", 0);
        component.set("v.endPage", pageSize - 1);
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (importLogs.length > i) {
                PaginationList.push(importLogs[i]);
            }
        }
        component.set("v.showImportLogsList", PaginationList);
        component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
    },

    navPage : function(component, event, helper) {
        var sObjectList = component.get("v.totalImportLogsList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        //var whichBtn = event.getSource().get("v.name");
        //
        // check if whichBtn value is 'next' then call 'next' helper method
        if (event.target.id == "nextId") {
          component.set("v.currentPage", component.get("v.currentPage") + 1);
          helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (event.target.id == "previousId") {
          component.set("v.currentPage", component.get("v.currentPage") - 1);
          helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },

    handleViewImport : function(component, event, helper) {
        component.set("v.isViewImport", true);
        var index = event.target.id;
        console.log('index => ' + index);
        var importLogs = component.get("v.totalImportLogsList");
        console.log('importLogs => ' + importLogs);
        var viewImpDetails = importLogs[index];
        component.set("v.viewImportDetails", viewImpDetails);
        console.log('viewImportDetails => ' + component.get("v.viewImportDetails"));
    }
})