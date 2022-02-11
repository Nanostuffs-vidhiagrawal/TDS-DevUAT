({
    doInit : function(component, event, helper) {
        // 1. Calling helper method "doInit".
        helper.doInit(component, event, helper);
    },
    // 2. Method to download CSV file.
    downloadCSV : function(component, event, helper,fileTitle) {
        // 3. Getting table data to download it in CSV.
        var gridData = component.get("v.gridData");       // 4. Spliting headers form table.
        var gridDataHeaders = gridData["headers"];
        // 5. Spliting row form table.
        var gridDataRows = gridData["rows"];
        // 6. CSV download.
        var csv = '';
        for(var i = 0; i < gridDataHeaders.length; i++){         
            csv += (i === (gridDataHeaders.length - 1)) ? gridDataHeaders[i]["title"] : gridDataHeaders[i]["title"] + ','; 
        }
        csv += "\n";
        var data = [];
        for(var i = 0; i < gridDataRows.length; i++){
            var gridRowIns = gridDataRows[i];
            var gridRowInsVals = gridRowIns["vals"];
            var tempRow = [];
            for(var j = 0; j < gridRowInsVals.length; j++){                                     
                var tempValue = gridRowInsVals[j]["val"];
                if(tempValue.includes(',')){
                    tempValue = "\"" + tempValue + "\"";
                }
                tempValue = tempValue.replace(/(\r\n|\n|\r)/gm,"");                 
                tempRow.push(tempValue);
            }
            data.push(tempRow); 
        }
        data.forEach(function(row){
            csv += row.join(',');
            csv += "\n";
        });
        // 6. To download table in CSV format.
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'fileTitle'+'.csv'; 
        hiddenElement.click();
    }
    
})