({
    readFile: function(component, helper, file) {
        if (!file) return;
        if(!file.name.match(/\.(csv||CSV)$/)){
            return alert('only support csv files');
        } 
        else {
            
            reader = new FileReader();
            reader.onerror =function errorHandler(evt) {
                switch(evt.target.error.code) {
                    case evt.target.error.NOT_FOUND_ERR:
                        alert('File Not Found!');
                        break;
                    case evt.target.error.NOT_READABLE_ERR:
                        alert('File is not readable');
                        break;
                    case evt.target.error.ABORT_ERR:
                        break; // noop
                    default:
                        alert('An error occurred reading this file.');	
                };
            }
            //reader.onprogress = updateProgress;
            reader.onabort = function(e) {
                alert('File read cancelled');
            };
            reader.onloadstart = function(e) { 
                var output = '<ui type=\"disc\"><li><strong>'+file.name +'</strong> ('+file.type+')- '+file.size+'bytes, last modified: '+file.lastModifiedDate.toLocaleDateString()+'</li></ui>';
                component.set("v.TargetFileName",output);
                component.set("v.uploadBar", "40");
            };
            reader.onload = function(e) {
                var data=e.target.result;
                component.set("v.fileContentData",data);
                var allTextLines = data.split(/\r\n|\n/);
                var dataRows=allTextLines.length-1;
                
                // Getting all the fields in the csv file
                var headers = allTextLines[0].toLowerCase().split(',');
                
                var csvHeadersDynamic = '';
                var csvHeadersManual = 'primary_landlord_title ,primary_landlord_first_name, primary_landlord_surname, primary_landlord_company, primary_landlord_building_name_or_number, primary_landlord_street, primary_landlord_town, primary_landlord_county, primary_landlord_postcode, primary_landlord_country, primary_landlord_mobile, primary_landlord_landline_phone, primary_landlord_email,'+
                    'joint_landlord_title, joint_landlord_first_name, joint_landlord_surname, joint_landlord_company, joint_landlord_building_name_or_number, joint_landlord_street, joint_landlord_town, joint_landlord_county, joint_landlord_postcode, joint_landlord_country, joint_landlord_mobile, joint_landlord_email,'+ 
                    'tenancy_building_name_or_number, tenancy_street, tenancy_town, tenancy_administrative_area, tenancy_postcode,' +
                    'tenancy_start_date, tenancy_end_date, deposit_amount, deposit_amount_to_protect, rent_amount, deposit_received_date, number_of_tenants';
                var isColumnsValid = true;
                //check coming columns should not out from csvHeaders
                for(let index in headers){
                    let headerStr = headers[index].trim().replaceAll(' ', '_');
                    
                    
                    if(!(headerStr.includes('tenant') && (headerStr.includes('lead') || headerStr.includes('joint'))) ){
                        csvHeadersDynamic += headerStr+', ';
                        if(!csvHeadersManual.includes(headerStr)){
                            isColumnsValid = false;
                        }
                    }
                }
                //check coming columns should not missed from csvHeader
                var csvHeadersManualList = csvHeadersManual.split(',');
                if(csvHeadersDynamic != ''){
                    for(let index in csvHeadersManualList){
                        let headerStr = csvHeadersManualList[index].trim();
                        
                        if(!csvHeadersDynamic.includes(headerStr)){
                            isColumnsValid = false;
                        }
                    }
                }
                if(isColumnsValid){
                    
                    var listOfDeposits = [];
                    var mapOfDeposits = new Map();
                    var listDeposits =[];
                    
                    // Creating the list of Object type for Deposit from the file rows
                    for(var i=1; i<allTextLines.length; i++) {
                        
                        var currentDepositObj = new Object();
                        // Pulling the data for each column of a row into a map of the 'field name' and 'row data'
                        
                        var str = allTextLines[i];
                        
                        if(str.replace(/,| /g,'') != ''){
                            var flag = 0;
                            var currentRowData = []; 
                            var temp = '';
                            for (let ch=0; ch<str.length; ch++) {
                                if (str[ch] == ',' && flag == 0) {
                                    currentRowData.push(temp);
                                    temp='';
                                }
                                else if (str[ch] == '\"' && flag == 0) {
                                    flag = 1;
                                }
                                else if (str[ch] == '\"' && flag == 1) {
                                    flag = 0;
                                }
                                else {
                                    temp=temp+str[ch]; 
                                }
                                
                                if(ch == str.length-1){
                                    currentRowData.push(temp);
                                }
                            }
                          
                            for(var j=0; j<headers.length; j++) {
                                if(currentRowData[j]!="undefined" && currentRowData[j]!=null){
                                
                                    currentDepositObj[headers[j].trim().replaceAll(' ', '_')] = currentRowData[j].trim();
                                }
                            }
                            listOfDeposits.push(currentDepositObj);
                        }
                    }           
component.set("v.uploadBar", "50");
                    component.set("v.ListOfTenancies",listOfDeposits);
                    // Creating a Map/Object of Deposit from the listOfDeposits
                    for(var i=0; i<listOfDeposits.length; i++) {
                        var mapKey = i+1; //'row_'+(i+1);
                        var values = listOfDeposits[i]; 
                        mapOfDeposits[mapKey] = listOfDeposits[i];
                        listDeposits.push({key: mapKey, value: values}) ;
                    }
                    
                    component.set("v.ListOfTenancies", listDeposits);
                    component.set("v.noOfDeposits", listDeposits.length);
                                 
                    // Calling helper for validation of the deposit rows
                    helper.checkValidationsForDeposits(component, helper, mapOfDeposits, file, dataRows);
                    
                    var numOfRows=component.get("v.noOfDeposits");
                    if(dataRows > numOfRows+1 || dataRows == 1 || dataRows== 0) {
                        component.set("v.showMain",true);
                    } 
                    else {
                        var lines = [];
                        var filecontentdata;
                        var content = "<table class=\"table slds-table slds-table--bordered slds-table--cell-buffer\">";
                        content += "<thead><tr class=\"slds-text-title--caps\">";
                        for(i=0;i<headers.length; i++){
                            content += '<th scope=\"col"\>'+headers[i]+'</th>';
                        }
                        content += "</tr></thead>";
                        for (var i=1; i<allTextLines.length; i++) {
                            filecontentdata = allTextLines[i].split(',');
                            if(filecontentdata[0]!=''){
                                content +="<tr>";
                                
                                for(var j=0;j<filecontentdata.length;j++){
                                    content +='<td>'+filecontentdata[j]+'</td>';
                                }
                                content +="</tr>";
                            }
                        }
                        content += "</table>";
                        
                        component.set("v.TableContent",content);
                        component.set("v.showMain",false);                   
                    }
                }
                else{
                    alert("columns are not currect in uploaded .csv file. Please check and try again!");
                }
            }
            reader.readAsText(file);
            
        }
        
        var reader = new FileReader();
        reader.onloadend = function() {
         
        };
        reader.readAsDataURL(file);
        
    },
    
    checkValidationsForDeposits : function(component, helper, mapOfDeposits, dataRows) {
       
        var errorCount = 0;
        var errKey;
        var successRows = 0; //isPartialSuccess = false;
        var listErrors =[];
        var totalTenants = 0;
        var totalLandlords = 0
        var str;
        var isRowErrored = false;
        
        for(var depo in mapOfDeposits) {
            
            str = depo; //'row_'+i;
            isRowErrored = false;
            
            // count no of Landlords
            var number_of_landlords = 1;
            if(mapOfDeposits[str].joint_landlord_first_name.length > 0 || mapOfDeposits[str].joint_landlord_surname.length > 0 
               || mapOfDeposits[str].joint_landlord_company.length > 0 || mapOfDeposits[str].joint_landlord_building_name_or_number.length > 0
               || mapOfDeposits[str].joint_landlord_street.length > 0 || mapOfDeposits[str].joint_landlord_town.length > 0
               || mapOfDeposits[str].joint_landlord_postcode.length > 0 || mapOfDeposits[str].joint_landlord_country.length > 0)
            {
                number_of_landlords = 2;

                if((mapOfDeposits[str].joint_landlord_first_name=='' || mapOfDeposits[str].joint_landlord_first_name==undefined ||
                mapOfDeposits[str].joint_landlord_first_name==null || 
                mapOfDeposits[str].joint_landlord_surname=='' || mapOfDeposits[str].joint_landlord_surname==undefined ||
                mapOfDeposits[str].joint_landlord_surname==null) &&
                (mapOfDeposits[str].joint_landlord_company=='' || mapOfDeposits[str].joint_landlord_company==undefined ||
                    mapOfDeposits[str].joint_landlord_company==null)  )
                {
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Joint landlord First name';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].joint_landlord_first_name;
                    currentErrorObj['errorMessage']='Must have either Landlord’s First name and Last name or Landlord’s Company name';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                    
                    currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Joint Landlord Surname';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].joint_landlord_surname;
                    currentErrorObj['errorMessage']='Must have either Landlord’s First name and Last name or Landlord’s Company name';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                    
                    currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Joint Landlord Company';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].joint_landlord_company;
                    currentErrorObj['errorMessage']='Must have either Landlord’s First name and Last name or Landlord’s Company name';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
                
                if((mapOfDeposits[str].joint_landlord_building_name_or_number=='' || mapOfDeposits[str].joint_landlord_building_name_or_number==undefined ||
                mapOfDeposits[str].joint_landlord_building_name_or_number==null) &&
                (mapOfDeposits[str].joint_landlord_street=='' || mapOfDeposits[str].joint_landlord_street==undefined ||
                    mapOfDeposits[str].joint_landlord_street==null)  )
                {
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Joint Landlord Building name or number';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].joint_landlord_building_name_or_number;
                    currentErrorObj['errorMessage']='\'Joint Landlord building name or number\' or \'Joint Landlord street\' is required';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                    
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Joint Landlord Street';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].joint_landlord_street;
                    currentErrorObj['errorMessage']='\'Joint Landlord building name or number\' or \'Joint Landlord street\' is required';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }

                if(mapOfDeposits[str].joint_landlord_mobile=='' || mapOfDeposits[str].joint_landlord_mobile==undefined || 
                    mapOfDeposits[str].joint_landlord_mobile==null){
                    let mobileNum = mapOfDeposits[str].joint_landlord_mobile;;
                    let isAlfabetContails = false;
                    for(var i=0; i<mobileNum.length;i++){
                        if(/^[a-zA-Z()]+$/.test(mobileNum[i]) || /[^\w\s]/gi.test(mobileNum[i])){
                            isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(mobileNum[i]);
                        }
                    }
                    
                    if(isAlfabetContails){
                        var currentErrorObj = new Object();
                        errKey = 'error_'+errorCount;
                        currentErrorObj['depoKey']=str;
                        currentErrorObj['landlords']=number_of_landlords;
                        currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                        currentErrorObj['status']='Failed';
                        currentErrorObj['fieldName']='Joint Landlord Mobile';
                        currentErrorObj['fieldValue']=mapOfDeposits[str].joint_landlord_mobile;
                        currentErrorObj['errorMessage']='\'Joint Landlord mobile\' should only be numbers';
                        errorCount++;
                        isRowErrored = true;
                        listErrors.push({key: errKey, value: currentErrorObj}) ;
                    }
                }

                if(mapOfDeposits[str].joint_landlord_email=='' || mapOfDeposits[str].joint_landlord_email==undefined || 
                mapOfDeposits[str].joint_landlord_email==null) {
                    var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                    if (!mapOfDeposits[str].joint_landlord_email.match(regExpEmailformat)) {
                        var currentErrorObj = new Object();
                        errKey = 'error_'+errorCount;
                        currentErrorObj['depoKey']=str;
                        currentErrorObj['landlords']=number_of_landlords;
                        currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                        currentErrorObj['status']='Failed';
                        currentErrorObj['fieldName']='Joint Landlord Email';
                        currentErrorObj['fieldValue']=mapOfDeposits[str].joint_landlord_email;
                        currentErrorObj['errorMessage']='\'Joint Landlord Email\' is not valid';
                        errorCount++;
                        isRowErrored = true;
                        listErrors.push({key: errKey, value: currentErrorObj}) ;
                    }  
                }
            }
			totalLandlords += number_of_landlords;
            totalTenants += parseFloat(mapOfDeposits[str].number_of_tenants);
            if((mapOfDeposits[str].primary_landlord_first_name=='' || mapOfDeposits[str].primary_landlord_first_name==undefined ||
               mapOfDeposits[str].primary_landlord_first_name==null || 
               mapOfDeposits[str].primary_landlord_surname=='' || mapOfDeposits[str].primary_landlord_surname==undefined ||
               mapOfDeposits[str].primary_landlord_surname==null) &&
               (mapOfDeposits[str].primary_landlord_company=='' || mapOfDeposits[str].primary_landlord_company==undefined ||
                mapOfDeposits[str].primary_landlord_company==null)  )
            {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary landlord First name';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_first_name;
                currentErrorObj['errorMessage']='Must have either Landlord’s First name and Last name or Landlord’s Company name';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                
                currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Surname';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_surname;
                currentErrorObj['errorMessage']='Must have either Landlord’s First name and Last name or Landlord’s Company name';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                
                currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Company';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_company;
                currentErrorObj['errorMessage']='Must have either Landlord’s First name and Last name or Landlord’s Company name';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
            
            if((mapOfDeposits[str].primary_landlord_building_name_or_number=='' || mapOfDeposits[str].primary_landlord_building_name_or_number==undefined ||
               mapOfDeposits[str].primary_landlord_building_name_or_number==null) &&
               (mapOfDeposits[str].primary_landlord_street=='' || mapOfDeposits[str].primary_landlord_street==undefined ||
                mapOfDeposits[str].primary_landlord_street==null)  )
            {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Building name or number';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_building_name_or_number;
                currentErrorObj['errorMessage']='\'Primary Landlord building name or number\' or \'Primary Landlord street\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Street';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_street;
                currentErrorObj['errorMessage']='\'Primary Landlord building name or number\' or \'Primary Landlord street\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
       
            if(mapOfDeposits[str].primary_landlord_town=='' || mapOfDeposits[str].primary_landlord_town==undefined || 
               mapOfDeposits[str].primary_landlord_town==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Town';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_town;
                currentErrorObj['errorMessage']='\'Primary Landlord town\' is required.';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }

            if(mapOfDeposits[str].primary_landlord_postcode=='' || mapOfDeposits[str].primary_landlord_postcode==undefined || 
               mapOfDeposits[str].primary_landlord_postcode==null) 
            {  
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Postcode';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_postcode;
                currentErrorObj['errorMessage']='\'Primary Landlord postcode\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
          /*  else{
                var isConsist = false;
               	var postCodePiclist = component.get("v.postalCodePicklist");
            
               
                //var strCode = mapOfDeposits[str].primary_landlord_postcode.substring(0, 2);
                var strCode = mapOfDeposits[str].primary_landlord_postcode;
                for(let pc=0; pc<postCodePiclist.length; pc++){
                    if(strCode.startsWith(postCodePiclist[pc])){
                        isConsist = true;
                        break;
                    }
                }
                
                if(!isConsist){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Primary Landlord Postcode';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_postcode;
                    currentErrorObj['errorMessage']='\'Primary Landlord postcode\' should only be in Scotland';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
            }*/
            
            if(mapOfDeposits[str].primary_landlord_country=='' || mapOfDeposits[str].primary_landlord_country==undefined || 
               mapOfDeposits[str].primary_landlord_country==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Country';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_country;
                currentErrorObj['errorMessage']='Please enter \'Primary Landlord Country’';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }

            if(mapOfDeposits[str].primary_landlord_mobile=='' || mapOfDeposits[str].primary_landlord_mobile==undefined || 
               mapOfDeposits[str].primary_landlord_mobile==null) 
            {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Mobile';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_mobile;
                currentErrorObj['errorMessage']='\'Primary Landlord mobile\' is Required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
            else{
                let mobileNum = mapOfDeposits[str].primary_landlord_mobile;;
                let isAlfabetContails = false;
                for(var i=0; i<mobileNum.length;i++){
                    if(/^[a-zA-Z()]+$/.test(mobileNum[i]) || /[^\w\s]/gi.test(mobileNum[i]) ){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(mobileNum[i]);
                    }
                }
                
                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Primary Landlord Mobile';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_mobile;
                    currentErrorObj['errorMessage']='\'Primary Landlord mobile\' should only be numbers';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
            }

            if(mapOfDeposits[str].primary_landlord_landline_phone!='' && mapOfDeposits[str].primary_landlord_landline_phone!=undefined && 
               mapOfDeposits[str].primary_landlord_landline_phone!=null) 
            {
                let PhoneNum = mapOfDeposits[str].primary_landlord_landline_phone;
                let isAlfabetContails = false;
                for(var i=0; i<PhoneNum.length;i++){
                    if(/^[a-zA-Z()]+$/.test(PhoneNum[i]) || /[^\w\s]/gi.test(PhoneNum[i]) ){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(PhoneNum[i]);
                    }
                }
                
                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Primary Landlord Landline Phone';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_landline_phone;
                    currentErrorObj['errorMessage']='\'Primary Landlord Landline Phone\' should only be numbers';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
            }

            if(mapOfDeposits[str].primary_landlord_email=='' || mapOfDeposits[str].primary_landlord_email==undefined || 
               mapOfDeposits[str].primary_landlord_email==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Primary Landlord Email';
                currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_email;
                currentErrorObj['errorMessage']='\'Primary Landlord Email\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
           }
            else {
               var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
               if (!mapOfDeposits[str].primary_landlord_email.match(regExpEmailformat)) {
                   var currentErrorObj = new Object();
                   errKey = 'error_'+errorCount;
                   currentErrorObj['depoKey']=str;
                   currentErrorObj['landlords']=number_of_landlords;
                   currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                   currentErrorObj['status']='Failed';
                   currentErrorObj['fieldName']='Primary Landlord Email';
                   currentErrorObj['fieldValue']=mapOfDeposits[str].primary_landlord_email;
                   currentErrorObj['errorMessage']='\'Primary Landlord Email\' is not valid';
                   errorCount++;
                   isRowErrored = true;
                   listErrors.push({key: errKey, value: currentErrorObj}) ;
               }  
           }

            if(mapOfDeposits[str].tenancy_start_date=='' || mapOfDeposits[str].tenancy_start_date==undefined || 
               mapOfDeposits[str].tenancy_start_date==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Tenancy Start Date';
                currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_start_date;
                currentErrorObj['errorMessage']='\'Tenancy Start Date\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;

            }
            else{ 
                let tenancyStartDate = mapOfDeposits[str].tenancy_start_date;

                let isAlfabetContails = false;
                for(var i=0; i<tenancyStartDate.length;i++){
                    if(/^[a-zA-Z()]+$/.test(tenancyStartDate[i]) || /[^\w\-\/\s]/gi.test(tenancyStartDate[i])){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(tenancyStartDate[i]);
                    }
                }

                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Tenancy Start Date';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_start_date;
                    currentErrorObj['errorMessage']='\'Tenancy Start Date\' should not contain characters';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;

                }
                else{
                    let isValidDate = validatedate(tenancyStartDate);

                    if(!isValidDate){
                        var currentErrorObj = new Object();
                        errKey = 'error_'+errorCount;
                        currentErrorObj['depoKey']=str;
                        currentErrorObj['landlords']=number_of_landlords;
                        currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                        currentErrorObj['status']='Failed';
                        currentErrorObj['fieldName']='Tenancy Start Date';
                        currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_start_date;
                        currentErrorObj['errorMessage']='\'Tenancy Start Date\' is not valid';
                        errorCount++;
                        isRowErrored = true;
                        listErrors.push({key: errKey, value: currentErrorObj}) ;
                    }
                    /*else{
                        var startDatesplited = tenancyStartDate.split(/[-\/]+/);
                        let todate = new Date();
                        if((new Date(startDatesplited[2]+'-'+startDatesplited[1]+'-'+startDatesplited[0]+' '+'01:00:00').getTime()) < (new Date(todate.getFullYear()+'-'+(todate.getMonth()+1)+'-'+todate.getDate()+' '+'01:00:00').getTime())){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']='Tenancy Start Date';
                            currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_start_date;
                            currentErrorObj['errorMessage']='\'Tenancy Start Date\' cannot be in past';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                    }*/
                }
            }
         
            if(mapOfDeposits[str].tenancy_end_date!='' && mapOfDeposits[str].tenancy_end_date!=undefined &&
               mapOfDeposits[str].tenancy_end_date!=null)
            {
                var tenancyEndDate = mapOfDeposits[str].tenancy_end_date;
                
                let isAlfabetContails = false;
                for(var i=0; i<tenancyEndDate.length;i++){
                    if(/^[a-zA-Z()]+$/.test(tenancyEndDate[i]) || /[^\w\-\/\s]/gi.test(tenancyEndDate[i])){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(tenancyEndDate[i]);
                    }
                }
                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Tenancy End Date';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_end_date;
                    currentErrorObj['errorMessage']='\'Tenancy End Date\' should not contain characters';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
                else{
                    let isValidDate = validatedate(tenancyEndDate);
                    if(!isValidDate){
                        var currentErrorObj = new Object();
                        errKey = 'error_'+errorCount;
                        currentErrorObj['depoKey']=str;
                        currentErrorObj['landlords']=number_of_landlords;
                        currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                        currentErrorObj['status']='Failed';
                        currentErrorObj['fieldName']='Tenancy End Date';
                        currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_end_date;
                        currentErrorObj['errorMessage']='\'Tenancy End Date\' is not valid';
                        errorCount++;
                        isRowErrored = true;
                        listErrors.push({key: errKey, value: currentErrorObj}) ;
                    }else{
                        var endDatesplited = tenancyEndDate.split(/[-\/]+/);
                        let todate = new Date();
                        if((new Date(endDatesplited[2]+'-'+endDatesplited[1]+'-'+endDatesplited[0]+' '+'01:00:00').getTime()) < (new Date(todate.getFullYear()+'-'+(todate.getMonth()+1)+'-'+todate.getDate()+' '+'01:00:00').getTime())){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']='Tenancy End Date';
                            currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_end_date;
                            currentErrorObj['errorMessage']='\'Tenancy End Date\' cannot be in past';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                    }
                }
            }
         
            var depositAmount = mapOfDeposits[str].deposit_amount;
            //depositAmount = depositAmount.replaceAll(/[^\w.\s]/gi, '');
            var depositProtedtedAmount = mapOfDeposits[str].deposit_amount_to_protect;
            //depositProtedtedAmount = depositProtedtedAmount.replaceAll(/[^\w.\s]/gi, '');
            
            if(depositAmount=='' || depositAmount==undefined || depositAmount==null ){
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Deposit Amount';
                currentErrorObj['fieldValue']=depositAmount;
                currentErrorObj['errorMessage']='\'Deposit Amount\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
            else{
                let isAlfabetContails = false;
                for(var i=0; i<depositAmount.length;i++){
                    if(/^[a-zA-Z()]+$/.test(depositAmount[i]) || /[^\w,.\s]/gi.test(depositAmount[i])){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(depositAmount[i]);
                    }
                }
                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Deposit Amount';
                    currentErrorObj['fieldValue']="£"+(depositAmount);
                    currentErrorObj['errorMessage']='\'Deposit Amount\' should not contain characters';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
                else if(parseFloat(depositAmount)<=0){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Deposit Amount';
                    currentErrorObj['fieldValue']="£"+parseFloat(depositAmount).toFixed(2);
                    currentErrorObj['errorMessage']='\'Deposit Amount\' cannot be 0';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
            }
        
            if(depositProtedtedAmount=='' || depositProtedtedAmount==undefined || depositProtedtedAmount==null ){
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Deposit Amount to Protect';
                currentErrorObj['fieldValue']=depositProtedtedAmount;
                currentErrorObj['errorMessage']='\'Deposit Amount to Protect\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
            else{
                let isAlfabetContails = false;
                for(var i=0; i<depositProtedtedAmount.length;i++){
                    if(/^[a-zA-Z()]+$/.test(depositProtedtedAmount[i]) || /[^\w,.\s]/gi.test(depositProtedtedAmount[i])){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(depositProtedtedAmount[i]);
                    }
                }
                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Deposit Amount to Protect';
                    currentErrorObj['fieldValue']="£"+(depositProtedtedAmount);
                    currentErrorObj['errorMessage']='\'Deposit Amount to Protect\' should not contain characters';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
                else if(parseFloat(depositProtedtedAmount)<=0){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Deposit Amount to Protect';
                    currentErrorObj['fieldValue']="£"+parseFloat(depositProtedtedAmount).toFixed(2);
                    currentErrorObj['errorMessage']='\'Deposit Amount to Protect\' cannot be 0';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
            }
             
            if(parseFloat(depositAmount)>0 && parseFloat(depositProtedtedAmount)>0
              && (parseFloat(depositAmount)) < (parseFloat(depositProtedtedAmount))) 
            {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Deposit Amount';
                currentErrorObj['fieldValue']="£"+parseFloat(depositAmount).toFixed(2);
                currentErrorObj['errorMessage']='\'Deposit Amount to Protect\' cannot be more than \'Deposit Amount\' ';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                
                currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Deposit Amount to Protect';
                currentErrorObj['fieldValue']="£"+parseFloat(depositProtedtedAmount).toFixed(2);
                currentErrorObj['errorMessage']='\'Deposit Amount to Protect\' cannot be more than \'Deposit Amount\'';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
            
            var rentAmount = mapOfDeposits[str].rent_amount;
            //rentAmount = rentAmount.replaceAll(/[^\w.\s]/gi, '');
            if(rentAmount!='' && rentAmount!=undefined && rentAmount !=null){
                let isAlfabetContails = false;
                for(var i=0; i<rentAmount.length;i++){
                    if(/^[a-zA-Z()]+$/.test(rentAmount[i]) || /[^\w,.\s]/gi.test(rentAmount[i])){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(rentAmount[i]);
                    }
                }
                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Rent Amount';
                    currentErrorObj['fieldValue']="£"+(rentAmount);
                    currentErrorObj['errorMessage']='\'Rent Amount\' should not contain characters';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }else if(parseFloat(depositAmount)>0 && parseFloat(rentAmount)>0
                         && (parseFloat(depositAmount)) > (2*(parseFloat(rentAmount))) ){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Rent Amount';
                    currentErrorObj['fieldValue']="£"+parseFloat(rentAmount).toFixed(2);
                    currentErrorObj['errorMessage']='As per the Housing Act 1988, a tenancy deposit Amount should be a maximum of two months\'Rent Amount.';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                    
                    currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Deposit Amount';
                    currentErrorObj['fieldValue']="£"+parseFloat(depositAmount).toFixed(2);
                    currentErrorObj['errorMessage']='As per the Housing Act 1988, a tenancy deposit Amount should be a maximum of two months\'Rent Amount.';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
            }
            
            if(mapOfDeposits[str].deposit_received_date=='' || mapOfDeposits[str].deposit_received_date==undefined || 
               mapOfDeposits[str].deposit_received_date==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Deposit Received Date';
                currentErrorObj['fieldValue']=mapOfDeposits[str].deposit_received_date;
                currentErrorObj['errorMessage']='\'Deposit Received Date\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
            else{
                var depositReceivedDate = mapOfDeposits[str].deposit_received_date;
                
                let isAlfabetContails = false;
                for(var i=0; i<depositReceivedDate.length;i++){
                    if(/^[a-zA-Z()]+$/.test(depositReceivedDate[i]) || /[^\w\-\/\s]/gi.test(depositReceivedDate[i])){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(depositReceivedDate[i]);
                    }
                }
                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Deposit Received Date';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].deposit_received_date;
                    currentErrorObj['errorMessage']='\'Deposit Received Date\' should not contain characters';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
                else{
                    let isValidDate = validatedate(depositReceivedDate);
                    if(!isValidDate){
                        var currentErrorObj = new Object();
                        errKey = 'error_'+errorCount;
                        currentErrorObj['depoKey']=str;
                        currentErrorObj['landlords']=number_of_landlords;
                        currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                        currentErrorObj['status']='Failed';
                        currentErrorObj['fieldName']='Deposit Received Date';
                        currentErrorObj['fieldValue']=mapOfDeposits[str].deposit_received_date;
                        currentErrorObj['errorMessage']='\'Deposit Received Date\' is not valid';
                        errorCount++;
                        isRowErrored = true;
                        listErrors.push({key: errKey, value: currentErrorObj}) ;
                    }
                    else{
                        var receivedDatesplited = depositReceivedDate.split(/[-\/]+/);
                        let todate = new Date();
                        if((new Date(receivedDatesplited[2]+'-'+receivedDatesplited[1]+'-'+receivedDatesplited[0]+' '+'01:00:00').getTime()) > (new Date(todate.getFullYear()+'-'+(todate.getMonth()+1)+'-'+todate.getDate()+' '+'01:00:00').getTime())){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']='Deposit Received Date';
                            currentErrorObj['fieldValue']=mapOfDeposits[str].deposit_received_date;
                            currentErrorObj['errorMessage']='\'Deposit Received Date\' cannot be in future';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                    }
                }
            }
            
            if((mapOfDeposits[str].tenancy_building_name_or_number=='' || mapOfDeposits[str].tenancy_building_name_or_number==undefined ||
                mapOfDeposits[str].tenancy_building_name_or_number==null) &&
               (mapOfDeposits[str].tenancy_street=='' || mapOfDeposits[str].tenancy_street==undefined ||
                mapOfDeposits[str].tenancy_street==null)  )
            {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Tenancy Building name or number';
                currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_building_name_or_number;
                currentErrorObj['errorMessage']='\'Tenancy Building name or number\' or \'Tenancy street\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
                
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Tenancy Street';
                currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_street;
                currentErrorObj['errorMessage']='\'Tenancy Building name or number\' or \'Tenancy street\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
       
            if(mapOfDeposits[str].tenancy_town=='' || mapOfDeposits[str].tenancy_town==undefined || 
               mapOfDeposits[str].tenancy_town==null) {
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Tenancy Town';
                currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_town;
                currentErrorObj['errorMessage']='\'Tenancy Town\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }

            if(mapOfDeposits[str].tenancy_postcode=='' || mapOfDeposits[str].tenancy_postcode==undefined || 
               mapOfDeposits[str].tenancy_postcode==null) 
            {  
                var currentErrorObj = new Object();
                errKey = 'error_'+errorCount;
                currentErrorObj['depoKey']=str;
                currentErrorObj['landlords']=number_of_landlords;
                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                currentErrorObj['status']='Failed';
                currentErrorObj['fieldName']='Tenancy Postcode';
                currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_postcode;
                currentErrorObj['errorMessage']='\'Tenancy Postcode\' is required';
                errorCount++;
                isRowErrored = true;
                listErrors.push({key: errKey, value: currentErrorObj}) ;
            }
            else{
                var isConsist = false;
               	var postCodePiclist = component.get("v.postalCodePicklist");
                
                var strCode = mapOfDeposits[str].tenancy_postcode;
                for(let pc=0; pc<postCodePiclist.length; pc++){
                    if(strCode.startsWith(postCodePiclist[pc])){
                        isConsist = true;
                        break;
                    }
                }
                
                if(!isConsist){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Tenancy Postcode';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].tenancy_postcode;
                    currentErrorObj['errorMessage']='\'Tenancy Postcode\' should only be in Scotland';
                    errorCount++;
                    
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                    isRowErrored = true;
                }
            }
            
            if(mapOfDeposits[str].number_of_tenants=='' || mapOfDeposits[str].number_of_tenants==undefined || 
               mapOfDeposits[str].number_of_tenants==null) {
                 var currentErrorObj = new Object();
                 errKey = 'error_'+errorCount;
                 currentErrorObj['depoKey']=str;
                 currentErrorObj['landlords']=number_of_landlords;
                 currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                 currentErrorObj['status']='Failed';
                 currentErrorObj['fieldName']='Number of Tenants';
                 currentErrorObj['fieldValue']=mapOfDeposits[str].number_of_tenants;
                 currentErrorObj['errorMessage']='\'Number of Tenants\' is required';
                 errorCount++;
                 isRowErrored = true;
                 listErrors.push({key: errKey, value: currentErrorObj}) ;
             }
            else {
                var noOfTenants = mapOfDeposits[str].number_of_tenants;
                let isAlfabetContails = false;
                for(var i=0; i<noOfTenants.length;i++){
                    if(/^[a-zA-Z()]+$/.test(noOfTenants[i]) || /[^\w\s]/gi.test(noOfTenants[i])){
                        isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(noOfTenants[i]);
                    }
                }
                if(isAlfabetContails){
                    var currentErrorObj = new Object();
                    errKey = 'error_'+errorCount;
                    currentErrorObj['depoKey']=str;
                    currentErrorObj['landlords']=number_of_landlords;
                    currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['status']='Failed';
                    currentErrorObj['fieldName']='Number of tenant';
                    currentErrorObj['fieldValue']=mapOfDeposits[str].number_of_tenants;
                    currentErrorObj['errorMessage']='\'Number of tenant\' should not contain characters';
                    errorCount++;
                    isRowErrored = true;
                    listErrors.push({key: errKey, value: currentErrorObj}) ;
                }
                else{
                    for(var t=1; t<=mapOfDeposits[str].number_of_tenants; t++){
                        var tenantTitle = '';
                        var tenantFName = '';
                        var tenantLName = '';
                        var tenantMobile = '';
                        var tenantEmail = '';
                        if(t==1){
                            tenantTitle = 'Tenant_'+t+'_Lead'+'_Title';
                            tenantFName = 'Tenant_'+t+'_Lead'+'_First_name';
                            tenantLName = 'Tenant_'+t+'_Lead'+'_Surname';
                            tenantMobile = 'Tenant_'+t+'_Lead'+'_Mobile';
                            tenantEmail = 'Tenant_'+t+'_Lead'+'_email';
                        }else{
                            tenantTitle = 'Tenant_'+t+'_Joint'+'_Title';
                            tenantFName = 'Tenant_'+t+'_Joint'+'_First_name';
                            tenantLName = 'Tenant_'+t+'_Joint'+'_Surname';
                            tenantMobile = 'Tenant_'+t+'_Joint'+'_Mobile';
                            tenantEmail = 'Tenant_'+t+'_Joint'+'_email';
                        }
                        
                        if(mapOfDeposits[str][tenantTitle.toLowerCase()]==undefined){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']=tenantTitle.replaceAll("_", " ");
                            currentErrorObj['fieldValue']=mapOfDeposits[str][tenantTitle.toLowerCase()];
                            currentErrorObj['errorMessage']='The number of Tenants specified in Column \'Number of Tenants\' does not match the details specified for the Tenants in excel';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                        else if(mapOfDeposits[str][tenantTitle.toLowerCase()]=='' || mapOfDeposits[str][tenantTitle.toLowerCase()]==null){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']=tenantTitle.replaceAll("_", " ");
                            currentErrorObj['fieldValue']=mapOfDeposits[str][tenantTitle.toLowerCase()];
                            currentErrorObj['errorMessage']=tenantTitle.replaceAll("_", " ") +' is required';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                        
                        if(mapOfDeposits[str][tenantFName.toLowerCase()]==undefined){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']=tenantFName.replaceAll("_", " ");
                            currentErrorObj['fieldValue']=mapOfDeposits[str][tenantFName.toLowerCase()];
                            currentErrorObj['errorMessage']='The number of Tenants specified in Column \'Number of Tenants\' does not match the details specified for the Tenants in excel';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                        else if(mapOfDeposits[str][tenantFName.toLowerCase()]=='' || mapOfDeposits[str][tenantFName.toLowerCase()]==null){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']=tenantFName.replaceAll("_", " ");
                            currentErrorObj['fieldValue']=mapOfDeposits[str][tenantFName.toLowerCase()];
                            currentErrorObj['errorMessage']=tenantFName.replaceAll("_", " ")+' is required';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                        
                        if(mapOfDeposits[str][tenantLName.toLowerCase()]==undefined){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']=tenantLName.replaceAll("_", " ");
                            currentErrorObj['fieldValue']=mapOfDeposits[str][tenantLName.toLowerCase()];
                            currentErrorObj['errorMessage']='The number of Tenants specified in Column \'Number of Tenants\' does not match the details specified for the Tenants in excel';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                        else if(mapOfDeposits[str][tenantLName.toLowerCase()]=='' || mapOfDeposits[str][tenantLName.toLowerCase()]==null ){
                            var currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']=tenantLName.replaceAll("_", " ");
                            currentErrorObj['fieldValue']=mapOfDeposits[str][tenantLName.toLowerCase()];
                            currentErrorObj['errorMessage']=tenantLName.replaceAll("_", " ")+' is required';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }

                        if(mapOfDeposits[str][tenantMobile.toLowerCase()]==undefined){
                            let currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']=tenantMobile.replaceAll("_", " ");
                            currentErrorObj['fieldValue']=mapOfDeposits[str][tenantMobile.toLowerCase()];
                            currentErrorObj['errorMessage']='The number of Tenants specified in Column \'Number of Tenants\' does not match the details specified for the Tenants in excel';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                        else if(mapOfDeposits[str][tenantMobile.toLowerCase()]!='' || mapOfDeposits[str][tenantMobile.toLowerCase()]!=null ){
                            let mobileNum = mapOfDeposits[str][tenantMobile.toLowerCase()];;
                            let isAlfabetContails = false;
                            for(var i=0; i<mobileNum.length;i++){
                                if(/^[a-zA-Z()]+$/.test(mobileNum[i]) || /[^\w\s]/gi.test(mobileNum[i])){
                                    isAlfabetContails = true; // /^[a-zA-Z()]+$/.test(mobileNum[i]);
                                }
                            }
                            
                            if(isAlfabetContails){
                                let currentErrorObj = new Object();
                                errKey = 'error_'+errorCount;
                                currentErrorObj['depoKey']=str;
                                currentErrorObj['landlords']=number_of_landlords;
                                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                                currentErrorObj['status']='Failed';
                                currentErrorObj['fieldName']=tenantMobile.replaceAll("_", " ");
                                currentErrorObj['fieldValue']=mapOfDeposits[str][tenantMobile.toLowerCase()];
                                currentErrorObj['errorMessage']='\''+ tenantMobile.replaceAll("_", " ") +'\' should only be numbers';
                                errorCount++;
                                isRowErrored = true;
                                listErrors.push({key: errKey, value: currentErrorObj}) ;
                            }
                        }
						
                        if(mapOfDeposits[str][tenantEmail.toLowerCase()]==undefined){
                            let currentErrorObj = new Object();
                            errKey = 'error_'+errorCount;
                            currentErrorObj['depoKey']=str;
                            currentErrorObj['landlords']=number_of_landlords;
                            currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                            currentErrorObj['status']='Failed';
                            currentErrorObj['fieldName']=tenantEmail.replaceAll("_", " ");
                            currentErrorObj['fieldValue']=mapOfDeposits[str][tenantEmail.toLowerCase()];
                            currentErrorObj['errorMessage']='The number of Tenants specified in Column \'Number of Tenants\' does not match the details specified for the Tenants in excel';
                            errorCount++;
                            isRowErrored = true;
                            listErrors.push({key: errKey, value: currentErrorObj}) ;
                        }
                        else if(mapOfDeposits[str][tenantEmail.toLowerCase()]!='' && mapOfDeposits[str][tenantEmail.toLowerCase()]!=null) {
                            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                            if (!mapOfDeposits[str][tenantEmail.toLowerCase()].match(regExpEmailformat)) {
                                let currentErrorObj = new Object();
                                errKey = 'error_'+errorCount;
                                currentErrorObj['depoKey']=str;
                                currentErrorObj['landlords']=number_of_landlords;
                                currentErrorObj['tenants']=mapOfDeposits[str].number_of_tenants;
                                currentErrorObj['status']='Failed';
                                currentErrorObj['fieldName']=tenantEmail.replaceAll("_", " ");
                                currentErrorObj['fieldValue']=mapOfDeposits[str][tenantEmail.toLowerCase()];
                                currentErrorObj['errorMessage']='\'' + tenantEmail.replaceAll("_", " ") + '\' is not valid';
                                errorCount++;
                                isRowErrored = true;
                                listErrors.push({key: errKey, value: currentErrorObj}) ;
                            }  
                        }
                    }
                }
             }
            
            if(isRowErrored == false){
                successRows++; //isPartialSuccess = true;
            }
        }
        
        component.set("v.validationErrorList", listErrors);  // total Errors
        component.set("v.totalFailures",errorCount);  // Number of Failures
        component.set("v.totalTenants",totalTenants);  // Number of Tenants
        component.set("v.totalLandlords",totalLandlords);  // Number of Landlords
        
        
        if(errorCount == 0){
            if(component.get("v.isValidateOnly")){
                component.set("v.statusOfValidate",'Successful');
            }else{
                component.set("v.statusOfValidate",'Successful');
            }
        } else if(successRows > 0 && successRows < component.get("v.ListOfTenancies").length){ 
            component.set("v.statusOfValidate",'Partial success');
        } else if(errorCount != 0){
            component.set("v.statusOfValidate",'Failed');
        }
            
        if(component.get("v.isValidateOnly") || errorCount > 0){ // if validating only
            helper.uploadCSV(component, helper);
        }
        else if(errorCount == 0){
            component.set("v.isDisableImport", true);
            
            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
            const branchId = urlParams.get('branchId');
            
            helper.apex(component,'importData',{BranchId : branchId,
                ListOfTenancies : component.get("v.ListOfTenancies"),
                isValidateOnly : component.get("v.isValidateOnly"),
                FileName : component.get("v.fileName"),
                totalTenants : component.get("v.totalTenants"),
                totalLandlords : component.get("v.totalLandlords"),
                statusOfValidate : component.get("v.statusOfValidate"),
                contactId : component.get("v.currentUser").ContactId,
                accountID : component.get("v.currentUser").AccountId})
            .then(function(result){
                component.set("v.updatesucceessmessage", true);                
             });
            
            /*var action = component.get("c.importData");
            action.setParams({
                BranchId : branchId,
                ListOfTenancies : component.get("v.ListOfTenancies"),
                isValidateOnly : component.get("v.isValidateOnly"),
                FileName : component.get("v.fileName"),
                totalTenants : component.get("v.totalTenants"),
                totalLandlords : component.get("v.totalLandlords"),
                statusOfValidate : component.get("v.statusOfValidate"),
                contactId : component.get("v.currentUser").ContactId,
                accountID : component.get("v.currentUser").AccountId,
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                var res = a.getReturnValue();
                if (res == "Success"){
                    component.set("v.updatesucceessmessage", true);
                } 
            });
            $A.enqueueAction(action);
            */
        }
        
        //GOD class to check date validity
        function validatedate(d)
        {
            var dateformat = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
            // Match the date format through regular expression
            if(d.match(dateformat))
            {     
                var splittedDate = d.split(/[-\/]+/);
                var splittedDateLength = splittedDate.length;
                if (splittedDateLength>1)
                {
                    var pdate = d.split(/[-\/]+/);
                }
                var dd = parseInt(pdate[0]);
                var mm  = parseInt(pdate[1]);
                var yy = parseInt(pdate[2]);
                
                // Create list of days of a month [assume there is no leap year by default]
                var ListofDays = [31,28,31,30,31,30,31,31,30,31,30,31];
                if (mm==1 || mm>2)
                {
                    if (dd>ListofDays[mm-1])
                    {
                        return false;
                    }
                }
                if (mm==2)
                {
                    var lyear = false;
                    if ( (!(yy % 4) && yy % 100) || !(yy % 400)) 
                    {
                        lyear = true;
                    }
                    if ((lyear==false) && (dd>=29))
                    {
                        return false;
                    }
                    if ((lyear==true) && (dd>29))
                    {
                        return false;
                    }
                }
                return true;
            }
            else
            {
                return false;
            }
        }
    }, 
    
    uploadCSV : function(component, helper){
        //alert('upload CSV start');
        // get the Records [deposit__c] list from 'ListOfTenancies' attribute 
        var ListTenancies = component.get("v.ListOfTenancies");
        var createListTenacies = [];
        for(var i=0; i< ListTenancies.length; i++){
        
            createListTenacies.push(ListTenancies[i].value);
        }
        
        // call the helper function which "return" the CSV data as a String   
        var csvString = helper.convertArrayOfObjectsToCSV(component,createListTenacies);   
        if (csvString == null){return;} 
        
    
        
        helper.convertCSVToFile(component, helper, csvString);
    }, 
    
    convertArrayOfObjectsToCSV : function(component, objectRecords){
    
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        //keys = ['FirstName','LastName','Department','MobilePhone','Id' ];
        
        // Get the CSV header from the list.
        keys = new Set();
        objectRecords.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                keys.add(key);
            });
        });
        
        keys = Array.from(keys);
        
    
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }   
                
                csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                
                counter++;
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult;        
    },
    
    convertCSVToFile : function(component, helper, csvString){
        
        // convert String CSV into File type
        var blob = new Blob([csvString], { type: 'data:text/csv;charset=utf-8' });
        var fileName = component.get("v.fileName");
        fileName = fileName.replaceAll(' ', '');
        var file = new File([blob], fileName, {type: "data:text/csv;charset=utf-8"});
    
    
        let fileLable = ''; // ???????
        let recordId = component.get("v.recordId"); //???
        const currentDate = new Date();
        const timestamp = currentDate.getTime();
        var baseUrl = component.get("v.secureURI");
    
        var baseUrlLength = baseUrl.length;
    
        var indexOfQueryStart = baseUrl.indexOf("?");
    
        var sasKeys = baseUrl.substring(indexOfQueryStart, baseUrlLength);
    
        var submitUri = baseUrl.substring(0, indexOfQueryStart) + '/'+ timestamp +'-'+ file.name + sasKeys;
    
        component.set("v.azureLink", submitUri);
        component.set("v.fileNameInAzure", timestamp +'-'+ file.name);
        
        var reader = new FileReader();
        reader.onload = function() {
            var dataURL = reader.result;
            helper.uploadToAzure(component, file, dataURL.match(/,(.*)$/)[1],submitUri,fileLable);
        };
        reader.readAsDataURL(file);
    },
    
    uploadToAzure : function(component, file, base64Data,submitUri,fileLable) {
        //debugger;
        var xhr = new XMLHttpRequest();
        var endPoint = submitUri;
        
        xhr.open("PUT", endPoint, true);
        xhr.setRequestHeader('x-ms-blob-type', 'BlockBlob');
        xhr.setRequestHeader('Content-Type', file.type);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 201) {   
                
                window.setTimeout(
                    $A.getCallback(function() {
                    })
                    ,1000);
              
                // Server call for inserting the 'Bulk Import' object's record
                var actionUpload = component.get('c.insertNewBulkImport');
                actionUpload.setParams({
                    isValidateOnly : component.get("v.isValidateOnly"),
                    fileName : component.get("v.fileName"),
                    azureFileName : component.get("v.fileNameInAzure"),
                    azureLink : component.get("v.azureLink"),
                    totalTenancies : component.get("v.noOfDeposits"),
                    totalTenants : component.get("v.totalTenants"),
                    totalLandlords : component.get("v.totalLandlords"),
                    totalFailures : component.get("v.totalFailures"),
                    statusOfValidate : component.get("v.statusOfValidate"),
                    contactId : component.get("v.currentUser").ContactId,
                    accountID : component.get("v.currentUser").AccountId,
                    //ListOfTenancies : component.get("v.ListOfTenancies")
                });
                // Create a callback that is executed after the server-side action returns
                actionUpload.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        // Console log the user with the value returned from the server
                        /*let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info',
                            message: 'File Uploaded Successfully',
                            type: 'success'
                        });
                        toastEvent.fire();*/
                    }
                    else if (state === "INCOMPLETE") {
                        // do something
                    }
                        else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    // We create a helper method for displaying errors through toast messages 
                                    helper.handleErrors(errors);
                                }
                            } else {
                            }
                        }
                });
                $A.enqueueAction(actionUpload);
                
            }
            else{
                //image error code
            }
            
        };
        xhr.send(file);
    },
    
    fetchScotlandPostalCodes : function(component, event, helper){
        var action = component.get("c.getScotlandPostalCodes");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.postalCodePicklist", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    
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
        component.set("v.showfailuresList", Paginationlist);
    },
    
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
        component.set("v.showfailuresList", Paginationlist);
    }, 
    
    apex : function( component, apexAction, params ) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
    },
    
    // helper to show errors in the form of toast messages
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire(); 
    },
    
})