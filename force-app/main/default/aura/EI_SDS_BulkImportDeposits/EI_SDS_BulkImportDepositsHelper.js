({
	csvToArray : function(component,str) {
        let delimiter = ",";
            const headers = str.slice(0, str.indexOf("\n")).split(delimiter);
            const rows = str.slice(str.indexOf("\n") + 1).split("\n");
            const arr = rows.map(function (row) {
                const values = row.split(delimiter);
                const el = headers.reduce(function (object, header, index) {
                    object[header] = values[index];
                    return object;
                }, {});
                return el;
            });

        component.set('v.rec',arr);
        console.log('arr '+JSON.stringify(arr));
        console.log('liine 16 '+arr.length);
        
            
    }
})