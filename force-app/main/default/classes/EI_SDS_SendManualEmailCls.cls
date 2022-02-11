public without sharing class EI_SDS_SendManualEmailCls {
    public static List<Holiday> holidayList;
    public static List<String> attachmentList = new List<String>();
    
    @AuraEnabled
    public static String saveAttachments(String attachment){
       String str = attachment;
        system.debug('attachment>>>>>>'+str);
        return str;
    }
    
    @AuraEnabled
    public static void sendEmailsofList(string emailDetails){
        System.debug('Enterd in sendEmailofList');
        System.Debug('email List Details String => ' + emailDetails);
        List<emailDetailsWrapper> emailList = (List<emailDetailsWrapper>) System.JSON.deserialize(emailDetails, List<emailDetailsWrapper>.class);
        System.Debug('email List wrapper => ' + emailList);
        for(emailDetailsWrapper email : emailList){
            System.Debug('email CaseId  => ' + email.caseId);
            System.Debug('email fromEmail => ' + email.fromEmail);
            System.Debug('email to => ' + email.to);
            System.Debug('email mailBody => ' + email.mailbody);
            System.Debug('email Subject => ' + email.subject);
            System.Debug('email uploadedFiles => ' + email.uploadedFiles);
        }
    }
    
    public class emailDetailsWrapper {
        @AuraEnabled 
        public String CaseId { get; set; } 
        @AuraEnabled 
        public String fromEmail { get; set; }
        @AuraEnabled 
        public String to { get; set; }
        @AuraEnabled 
        public String mailBody { get; set; }
        @AuraEnabled 
        public String subject { get; set; }
        @AuraEnabled 
        public List<String> uploadedFiles { get; set; }     
    }
    
  /*  @AuraEnabled
    public static List<API_Service__mdt> getAllMetaDataList(Id recordId){
        String ObjName = recordId.getSobjectType().getDescribe().getName();
        String SchemeName;
        if(ObjName == 'Case'){
            SchemeName = [Select Id, Deposit_Account_Number__r.scheme_Name__c from Case WHERE Id =: recordId].Deposit_Account_Number__r.scheme_Name__c; // sds
        }else{
            SchemeName = [Select Id, scheme_Name__c from Deposit__c WHERE Id =: recordId].scheme_Name__c; // sds
        }
        System.debug('SchemeName => ' + SchemeName);
        List<API_Service__mdt> metaDataList = [SELECT EndPoint_URL__c, Username__c, Password__c, From_Name__c, From_Address__c,
                                               Template_Id__c, Scheme_Signatory__c, Scheme_Address__c,Scheme_Bank_Account_Number__c,
                                               Scheme_Sort_Code__c, Scheme_Bank_Name__c, Label
                                               FROM API_Service__mdt 
                                               WHERE Template_Id__c IN ('2358250', '2358273', '2358582', '2358481', '2358430', '2358560','3057972', '2405001', '3060802', '2402017', '3189300')];
        //In('2462648', '2961838', '2359314')  Scheme_Signatory__c = 'SafeDeposits Scotland'];
        System.debug('All Meta Data List : ' + metaDataList);
        return metaDataList;
    }*/
    
    //temprary testing method 
     @AuraEnabled
    public static List<Map<String, String>> getAllMetaDataList(Id recordId){
        List<Map<String, String>> listToreturn = new List<Map<String, String>>();
        
        List<Matching_Temp_Var__c> getAllTemplates = [Select Template_Id__c, Custom_Metadata_Label__c, text_body__c, Subject__c from Matching_Temp_Var__c where Var_Name__c = '' ]; 
        for(Matching_Temp_Var__c mtv : getAllTemplates){
            Map<String, String> IdAndLabelMap = new Map<String, String>();
            IdAndLabelMap.put('Template_Id__c' , mtv.Template_Id__c); 
            IdAndLabelMap.put('Label', mtv.Custom_Metadata_Label__c); 
            listToreturn.add(IdAndLabelMap);
        }
        
        return listToreturn;
    }
    
    public static HttpRequest mailJetAuthentication(){
        List<API_Service__mdt> mailJetSettings = metaDataListbyLabel('mailJetSDS');
        
        HttpRequest req = new HttpRequest();
        String endPoint = mailJetSettings[0].EndPoint_URL__c; // String endPoint = 'https://api.mailjet.com/v3.1/send';
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/text'); 
        
        String username = mailJetSettings[0].Username__c; // String username = '149e22044add6860160c56c12a500708';   // SDS
        String password = mailJetSettings[0].Password__c; // String password = '3bc9ecf441468a0dee61982308eb7fb7';
       
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);       
        System.debug('authorizationHeader : ' + authorizationHeader);
        req.setHeader('Authorization', authorizationHeader);   
        return req;      
    }
    
    @AuraENabled
    public static Map<String, String> getMailJetTextBody(Integer tempId, String toEMail, Id recordId, Id toRecConId){
        List<API_Service__mdt> mailJetSettings = metaDataListbyLabel('mailJetSDS');
        System.debug('toEMail :' + toEMail);
        System.debug('tempId :' + tempId);
        System.debug('recordId :' + recordId);
        System.debug('toRecConId :' + toRecConId);
        System.debug('object Name :' + recordId.getSobjectType().getDescribe().getName());
        String ObjName = recordId.getSobjectType().getDescribe().getName();
        String toObjName = toRecConId.getSobjectType().getDescribe().getName();
        
        Contact con = [Select Id, Name, AccountId from Contact Where Id = :toRecConId];
        String conId = con.Id;
        String accId = con.AccountId;
        String caseId = '';
        String depositId = '';
        String repayReqLineId = '';
        String repayReqId = '';
        String installmentId = '';
        String schemeId = '';
        List<Repayment_Request_Line__c> RRL;
        List<Installment__c> inst;
            
        if(ObjName == 'Case'){
            RRL = [Select Id, Name, Repayment_Request__c From Repayment_Request_Line__c where Repayment_Request__r.Case__c =:recordId AND 
                  (Contact__c = :conId OR Account__c = :accId) limit 1];
            if(RRL.size() > 0){
                repayReqLineId = RRL[0].Id;
                repayReqId = RRL[0].Repayment_Request__c;
            }
            List<Case> cs = [Select Id, Deposit_Account_Number__c, Deposit_Account_Number__r.Scheme__c From Case Where Id = :recordId];
            if(cs.size() > 0){
                caseId = cs[0].Id;
                depositId = cs[0].Deposit_Account_Number__c;
                SchemeId = cs[0].Deposit_Account_Number__r.Scheme__c;
            }
            inst = [Select Id, Name From Installment__c Where Case__c = :recordId AND Contact__c = :conId limit 1];
            if(inst.size() > 0){
                installmentId = inst[0].Id;
            }
        }else if(ObjName == 'Deposit__c'){
            RRL = [Select Id, Name, Repayment_Request__c From Repayment_Request_Line__c where Repayment_Request__r.Deposit__c =:recordId AND
                  (Contact__c = :conId OR Account__c = :accId) limit 1];
            if(RRL.size() > 0){
                repayReqLineId = RRL[0].Id;
                repayReqId = RRL[0].Repayment_Request__c;
            }
            List<Deposit__c> depo = [Select Id, Name, Scheme__c, caseId__c From Deposit__c Where Id = :recordId];
            if(depo.size() > 0){
                depositId = depo[0].Id;
                caseId = depo[0].caseId__c;
                SchemeId = depo[0].Scheme__c;
            }
            inst = [Select Id, Name From Installment__c Where Deposit__c = :recordId AND Contact__c = :conId limit 1];
            if(inst.size() > 0){
                installmentId = inst[0].Id;
            }
        }
                
        String subject = '';
        String textPart = '';
            
        /*HttpRequest req = new HttpRequest();
        String endPoint = 'https://api.mailjet.com/v3/REST/template/'+tempId+'/detailcontent';
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/text'); 
       
         String username = mailJetSettings[0].Username__c; // String username = '149e22044add6860160c56c12a500708';   // SDS
        String password = mailJetSettings[0].Password__c; // String password = '3bc9ecf441468a0dee61982308eb7fb7';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);       
        req.setHeader('Authorization', authorizationHeader); 
        
        Http http = new Http();
        HTTPResponse response = http.send(req); 
        system.debug('response-->>' + response.getBody()); 
       	String getbody = response.getBody();
        System.debug('******** getBody ********' + JSON.serializePretty(getbody));
        getbody = getbody.replace('-', '_');
        EI_SDS_SendManualEmailWrapper templatedetails = (EI_SDS_SendManualEmailWrapper)System.JSON.deserialize(getbody, EI_SDS_SendManualEmailWrapper.class);
		
        EI_SDS_SendManualEmailWrapper.cls_Headers HeadersDetails = templatedetails.Data[0].Headers;
        //System.debug('textPart: ' + templatedetails.Data[0].Text_part);
        //System.debug('Html_part: ' + templatedetails.Data[0].Html_part);
		//System.debug('Subject: ' + HeadersDetails.Subject);
         
        subject = HeadersDetails.Subject;
        textPart = templatedetails.Data[0].Text_part;
        
        textPart = textPart.replace('_', '-');
        textPart = textPart.replace('\n\n', '<br>');
        textPart = textPart.replace('\n', '<br>');
       // System.debug('image link : '+ textPart.substringBetween('<<SDS_Logo>> [', ']'));
        textPart = textPart.replace('<<SDS-Logo>> [', '<img src=\"' );
        textPart = textPart.replaceFirst(']', '\" />' );
    */
       // by creating new record for fetched template body
       // Matching_Temp_Var__c textbody = new Matching_Temp_Var__c(text_body__c = templatedetails.Data[0].Html_part);
       // insert textbody;
        Matching_Temp_Var__c gettextbody = [Select Template_Id__c, text_body__c, Subject__c from Matching_Temp_Var__c where Template_Id__c =:String.valueOf(tempId) and Var_Name__c = '' ]; //'a2F3H000000Bk7bUAC'
		textPart = gettextbody.text_body__c; 
        subject = gettextbody.Subject__c;
        System.debug('textPart: ' + textPart);
        System.debug('Subject: ' + subject);
        
        String varSet = ''; // selected template's variable names set
        String[] textPartSplit = textPart.split('var');
        for(Integer i=0; i< textPartSplit.size(); i++){
            
            String tp = textPartSplit[i];
            if(tp.startsWith(':')){
                System.debug('tp=> '+ tp);
                String varName = tp.substringBetween(':', ':');
                System.debug('var Name :' + varName);
                if(varName != null && varName.toLowerCase() != 'date'){
                    varSet += '\'' + varName + '\'';
                    if(i != textPartSplit.size()-1){
                        varSet += ', ';
                    }
                }
            }
        }
        System.debug('Text Part Temp var Set :' + varSet);
        
        String[] subjectSplit = subject.split('var');
        for(Integer i=0; i< subjectSplit.size(); i++){
            
            String tp = subjectSplit[i];
            if(tp.startsWith(':')){
                System.debug('tp=> '+ tp + ' i=> ' + i);
                String varName = tp.substringBetween(':', ':');
                System.debug('var Name :' + varName);
                if(i == 1 && varSet != ''){
                    varSet += ', ';
                }
                if(varName != null && varName.toLowerCase() != 'date'){
                    varSet += '\'' + varName + '\'';
                    if(i != subjectSplit.size()-1){
                        varSet += ', ';
                    }
                }
            }
        }
        System.debug('Temp var Set :' + varSet);
        
        // get Object Field API names and where condition field of varnames from custom object Matching_Temp_Var__c
        String query = 'SELECT Var_Name__c, isTable__c, Date_Function__c, Object_Name__c, Field_API_Name__c, Where_Check_Field__c, get_value_of_Object__c FROM Matching_Temp_Var__c where Var_Name__c IN ('+varSet+') AND Template_Id__c = \''+tempId+'\' '  ;
        System.debug(' query : ' + query);
        List<Matching_Temp_Var__c> mtvList = database.query(query); 
        System.debug('mtvList : ' + mtvList);
             
        Map<String, String> varValues = new Map<String, String>(); // Field's API names and their values
        Map<String, String> varnameANDDateFuncMap = new Map<String, String>(); // template variable and date Function Map
        Map<String, String> varnameANDapinameMap = new Map<String, String>(); // template variable and Field API name's Map
        Map<String, String> objANDFieldMap = new Map<String, String>(); // Object and Field API name's Map
        Map<String, String> objANDWhereCheckFieldMap = new Map<String, String>(); // Object and where condition field Map
        String tableDate = '<table>';
        for(integer i=0; i< mtvList.size(); i++){
            Matching_Temp_Var__c matchObj = new Matching_Temp_Var__c();
            if(!mtvList[i].isTable__c && mtvList[i].Field_API_Name__c != null){
                matchObj = mtvList[i];
                
                String varFieldAPINames = '';
                if(objANDFieldMap.containsKey(matchObj.Object_Name__c)){  // if obj contains
                    varFieldAPINames = objANDFieldMap.get(matchObj.Object_Name__c);  // get fields
                }
                
                if(!varFieldAPINames.contains(','+ matchObj.Field_API_Name__c+' ')){ // check for duplicate variable names from template
                    System.debug('if not contains varFieldAPINames => ' + varFieldAPINames);
                    varFieldAPINames += ',' + matchObj.Field_API_Name__c + ' ';
                }
                objANDWhereCheckFieldMap.put(matchObj.Object_Name__c, matchObj.Where_Check_Field__c);
                objANDFieldMap.put(matchObj.Object_Name__c, varFieldAPINames);
                
                varnameANDapinameMap.put(mtvList[i].Var_Name__c, mtvList[i].Field_API_Name__c + mtvList[i].Object_Name__c);
                varnameANDDateFuncMap.put(mtvList[i].Var_Name__c, mtvList[i].Date_Function__c);
            }
            else if(mtvList[i].isTable__c && mtvList[i].Field_API_Name__c != null){
                Map<String, String> tableVarValues = new Map<String, String>(); // table Field's API names and their values
                String tableDataQuery = '';
                if(mtvList[i].Object_Name__c == 'Repayment_Request_Line__c' && repayReqId != null && repayReqId != ''){
                    tableDataQuery = 'Select '+mtvList[i].Field_API_Name__c+' FROM '+mtvList[i].Object_Name__c+' WHERE Repayment_Request__c = \''+repayReqId+'\' ';
                }
                else if(mtvList[i].Object_Name__c == 'Deposit_Allocation__c' && depositId != null && depositId != ''){
                    tableDataQuery = 'Select '+mtvList[i].Field_API_Name__c+' FROM '+mtvList[i].Object_Name__c+' WHERE Deposit__c = \''+depositId+'\' ';
                }
                else if(mtvList[i].Object_Name__c == 'Dispute_Item__c' && caseId != null && caseId != ''){
                    tableDataQuery = 'Select '+mtvList[i].Field_API_Name__c+' FROM '+mtvList[i].Object_Name__c+' WHERE Dispute__c = \''+caseId+'\' ';
                }
                
                if(tableDataQuery != ''){
                    System.debug('tableDataQuery => ' + tableDataQuery);
                    List<sObject> objList = database.query(tableDataQuery);
                    String[] allFieldAPInamesSplited = mtvList[i].Field_API_Name__c.split(',');
                    for(sObject CP : objList){
                        for(integer j=0; j<allFieldAPInamesSplited.size(); j++){
                            String fieldName = allFieldAPInamesSplited[j];
                            System.Debug('fieldName => ' + fieldName);
                            if(fieldName.contains('__r.')){
                                Map<String, Object> convertedsubObjToMap = CP.getSobject(fieldName.substringBefore('.')).getPopulatedFieldsAsMap(); // map of populated field names(allFieldAPInames) and their corresponding values
                                for (String subfieldName : convertedsubObjToMap.keySet()){
                                    System.debug('subfieldName => ' + subfieldName + 'String.ValueOf(fieldName.substringAfter => ' + String.ValueOf(fieldName.substringAfter('.')));
                                    System.debug('sub field name is ' + fieldName.substringBefore('.').trim()+'.'+subfieldName.trim() + ', value is ' + convertedsubObjToMap.get(subfieldName));
                                    tableVarValues.put(fieldName.substringBefore('.').trim()+'.'+subfieldName , String.valueOf(convertedsubObjToMap.get(subfieldName) ));
                                }
                            }else{
                                Map<String, Object> convertedObjToMap = CP.getPopulatedFieldsAsMap(); // map of populated field names(allFieldAPInames) and their corresponding values
                                for (String mainfieldName : convertedObjToMap.keySet()){
                                    System.debug('field name is ' + mainfieldName + ', value is ' + convertedObjToMap.get(mainfieldName));
                                    tableVarValues.put(mainfieldName , String.valueOf(convertedObjToMap.get(mainfieldName) ));
                                    System.debug('tableVarValues => ' + tableVarValues.get(allFieldAPInamesSplited[1]));
                                }
                            }
                        }
                        System.debug('allFieldAPInamesSplited[0] => ' + allFieldAPInamesSplited[0] + ' Value is => ' + tableVarValues.get(allFieldAPInamesSplited[0]));
                        System.debug('allFieldAPInamesSplited[1] => ' + allFieldAPInamesSplited[1] + 'Value is => ' + tableVarValues.get(allFieldAPInamesSplited[1]));
                        tableDate += '<tr>';
                        tableDate += '<td>'+ tableVarValues.get(allFieldAPInamesSplited[0]) +':'+'<td>';
                        tableDate += '<td>'+'£'+ tableVarValues.get(allFieldAPInamesSplited[1]) +'<td>';
                        tableDate += '</tr>';
                    }
                    tableDate += '</table><br/><br/>';
                    varValues.put(mtvList[i].Field_API_Name__c+mtvList[i].Object_Name__c , tableDate);
                    varnameANDapinameMap.put(mtvList[i].Var_Name__c, mtvList[i].Field_API_Name__c + mtvList[i].Object_Name__c);
                }
            }
            else{
                varnameANDapinameMap.put(mtvList[i].Var_Name__c, mtvList[i].Field_API_Name__c + mtvList[i].Object_Name__c);
                varnameANDDateFuncMap.put(mtvList[i].Var_Name__c, mtvList[i].Date_Function__c);
            }
        }
        System.debug('varnameANDapinameMap : ' + varnameANDapinameMap);
        System.debug('varnameANDDateFuncMap : ' + varnameANDDateFuncMap);
        System.debug('objANDFieldMap : ' + objANDFieldMap);
        
        //Map<String, String> varValues = new Map<String, String>(); // Field's API names and their values
        for(String sobj : objANDFieldMap.keySet()){
            String WhereField = objANDWhereCheckFieldMap.get(sobj);
            String allFieldAPInames = objANDFieldMap.get(sobj);
            /*List<String> splitedWhereField = WhereField.split(',');
            String WhereStatement = '';
            for(String WField : splitedWhereField){
                WhereStatement += WField + ' = \''+recordId+'\' OR ' + WField + ' = \''+toRecAccID+'\'';
            }*/
            String getValueQuery = '';
            if(sobj == 'Contact' && conId != null && conId != ''){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Id = \'' + conId + '\' limit 1 ';
            }
            else if(sobj == 'Account' && accId != null && accId != ''){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Id = \'' + accId + '\' limit 1 ';
            }
            else if(sobj == 'Case' && caseId != null && caseId != ''){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Id = \'' + caseId + '\' limit 1 ';
            }
            else if(sobj == 'Deposit__c' && depositId != null && depositId != ''){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Id = \'' + depositId + '\' limit 1 ';
            }
            else if(sobj == 'Repayment_Request__c' && repayReqId != null && repayReqId != ''){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Id = \'' + repayReqId + '\' limit 1 ';
            }
            else if(sobj == 'Repayment_Request_Line__c' && repayReqLineId != null && repayReqLineId != ''){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Id = \'' + repayReqLineId + '\' limit 1 ';
            }
            else if(sobj == 'Installment__c' && installmentId != null && installmentId != ''){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Id = \'' + installmentId + '\' limit 1 ';
            }
            else if(sobj == 'Scheme__c' && schemeId != null && schemeId != ''){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Id = \'' + schemeId + '\' limit 1 ';
            }
            else if(sobj == 'API_Service__mdt' && tempId != null){
                getValueQuery = 'SELECT Id ' +allFieldAPInames+ ' FROM '+ sobj +' where Template_Id__c = \'' + tempId + '\' limit 1 ';
            }
            
            if(getValueQuery != ''){
                System.debug(' getValueQuery : ' + getValueQuery);
                sObject CP = database.query(getValueQuery);
                System.debug('CP : ' + CP);
                
                List<String> allFieldAPInamesSplited = allFieldAPInames.split(',');
                /*if(allFieldAPInames.contains(',')){
				allFieldAPInamesSplited = allFieldAPInames.split(',');
				System.Debug('allFieldAPInamesSplited => ' + allFieldAPInamesSplited[1]);
				}*/
                for(integer j=1; j<allFieldAPInamesSplited.size(); j++){
                    String fieldName = allFieldAPInamesSplited[j];
                    System.Debug('fieldName => ' + fieldName);
                    if(fieldName.contains('__r.')){
                        System.Debug('fieldNameSplited [0] => ' + fieldName.substringBefore('.'));
                        System.debug('deposit Acc => ' + fieldName.substringAfter('.'));
                        Map<String, Object> convertedsubObjToMap = new Map<String, Object>();
                        if(CP.getSobject(fieldName.substringBefore('.')) != null){
                            convertedsubObjToMap = CP.getSobject(fieldName.substringBefore('.')).getPopulatedFieldsAsMap(); // map of populated field names(allFieldAPInames) and their corresponding values
                        }
                        for (String subfieldName : convertedsubObjToMap.keySet()){
                            if(CP.getSobject(fieldName.substringBefore('.')) != null){
                                System.debug('subfieldName => ' + subfieldName + 'String.ValueOf(fieldName.substringAfter => ' + String.ValueOf(fieldName.substringAfter('.')));
                                System.debug('sub field name is ' + fieldName.substringBefore('.').trim()+'.'+subfieldName.trim()+sobj.trim() + ', value is ' + convertedsubObjToMap.get(subfieldName));
                                varValues.put(fieldName.substringBefore('.').trim()+'.'+subfieldName.trim()+sobj.trim() , String.valueOf(convertedsubObjToMap.get(subfieldName) ));
                            }else{
                                varValues.put(fieldName.substringBefore('.').trim()+'.'+subfieldName.trim()+sobj.trim() , '' );
                            }
                        }
                    }else{
                        Map<String, Object> convertedObjToMap = CP.getPopulatedFieldsAsMap(); // map of populated field names(allFieldAPInames) and their corresponding values
                        for (String mainfieldName : convertedObjToMap.keySet()){
                            System.debug('field name is ' + mainfieldName + ', value is ' + convertedObjToMap.get(mainfieldName));
                            varValues.put(mainfieldName+sobj , String.valueOf(convertedObjToMap.get(mainfieldName) ));
                        }
                    }
                }        
            }
        }
    	System.debug('varValues : ' + varValues);
        
        for(String tp : textPartSplit){
            if(tp.startsWith(':')){
                String varName = tp.substringBetween(':', ':');
                System.debug('var Name :' + varName);
                String valueAPIname;
                String dateFunction = varnameANDDateFuncMap.get(varName);
                System.debug('dateFunction => ' + dateFunction);
                if(varName.toLowerCase() == 'date'){
                    DateTime dt = System.today();
                    System.debug('dt=> ' + dt.date().format());
                    textPart = textPart.replace(':'+varName+':', dt.date().format() ); // replace varname(date/Date) with current date
                    //textPart = textPart.replace('{{var:' +varName+ ':&quot;&quot;}}', '');
                }
                if(dateFunction != null){
                    if(dateFunction.toLowerCase().contains('adddays')){
                        System.debug('dateFunction. days => ' + dateFunction.substringBetween('(', ')'));
                        valueAPIname = varnameANDapinameMap.get(varName); 
                        Date startDate = varValues.get(valueAPIname)!=null? Date.valueOf(varValues.get(valueAPIname)) : System.today();
                        Integer days = Integer.valueOf(dateFunction.substringBetween('(', ')'));
                        textPart = textPart.replace(':'+varName+':', String.ValueOf(calculateAddDays(startDate, days).format()) );
                    }
                    else if(dateFunction.toLowerCase().contains('addmonths')){
                        System.debug('dateFunction. days => ' + dateFunction.substringBetween('(', ')'));
                        valueAPIname = varnameANDapinameMap.get(varName); 
                        Date startDate = varValues.get(valueAPIname)!=null? Date.valueOf(varValues.get(valueAPIname)) : System.today();
                        Integer months = Integer.valueOf(dateFunction.substringBetween('(', ')'));
                        textPart = textPart.replace(':'+varName+':', String.valueOf(calculateAddMonths(startDate, months).format()) );
                    }
                    else if(dateFunction.toLowerCase().contains('workingdaysbw')){
                        System.debug('dateFunction. days => ' + dateFunction.substringBetween('(', ')'));
                        valueAPIname = varnameANDapinameMap.get(varName); 
                        Date startDate = varValues.get(valueAPIname)!=null? Date.valueOf(varValues.get(valueAPIname)) : System.today();
                        Integer days = Integer.valueOf(dateFunction.substringBetween('(', ')'));
                        textPart = textPart.replace(':'+varName+':', String.valueOf(calculateWorkingDaysBetweenTwoDates(startDate, days)) );
                    }
                    else if(dateFunction.toLowerCase().contains('daysbw')){
                        System.debug('daysbw dateFunction => ' + dateFunction);
                        valueAPIname = varnameANDapinameMap.get(varName); 
                        System.debug('daysbw valueAPIname => ' + valueAPIname + varValues.get(valueAPIname));
                        Date endDate = varValues.get(valueAPIname)!=null? Date.valueOf(varValues.get(valueAPIname)) : System.today();
                        Integer days = Integer.valueOf(dateFunction.substringBetween('(', ')'));
                        System.debug('end Date => ' + endDate + ' Days => ' + days);
                        textPart = textPart.replace(':'+varName+':', String.valueOf(calculateDaysBetween(endDate, days)) );
                    }
                    else if(dateFunction.toLowerCase().contains('todaydate')){
                        System.debug('todaydate dateFunction => ' + dateFunction);
                        textPart = textPart.replace(':'+varName+':', String.valueOf(System.today().format()) );
                    }
                }
                else{
                    valueAPIname = varnameANDapinameMap.get(varName); // get Field API name of template variable
                    System.debug('varnameANDapinameMap var Name :' + valueAPIname + ':'+varName+':');
                    
                    System.debug(':'+varName+':' +'Field Value' + (varValues.get(valueAPIname) != null ? varValues.get(valueAPIname) : '') );
                    
                    if(varName.containsIgnoreCase('date') && varValues.get(valueAPIname) != null){
                        date DateVal = Date.valueOf(varValues.get(valueAPIname));
                        textPart = textPart.replace(':'+varName+':', varValues.get(valueAPIname) != null ? DateVal.format() : '' );
                    }
                    else{
                        textPart = textPart.replace(':'+varName+':', varValues.get(valueAPIname) != null ? varValues.get(valueAPIname) : '' ); // replace varname with its value in mail body
                    }
                }
            }
        }
        
        for(String tp : subjectSplit){
            if(tp.startsWith(':')){
                String varName = tp.substringBetween(':', ':');
                System.debug('var Name :' + varName);
                String valueAPIname;
                if(varName.toLowerCase() == 'date'){
                    subject = subject.replace(tp.substringBetween(':', ':'), String.valueOf(System.today()) ); // replace varname(date/Date) with current date
                    subject = subject.replace('{{var:'+varName+':\""}}', '');
                }else{
                    valueAPIname = varnameANDapinameMap.get(varName); // get Field API name of template variable
                    System.debug('varnameANDapinameMap var Name :' + valueAPIname);
                    
                    System.debug( 'varName' + varName + 'Field Value' + varValues.get(valueAPIname) != null ? varValues.get(valueAPIname) : '' );
                    subject = subject.replace(':'+varName+':', varValues.get(valueAPIname) != null ? varValues.get(valueAPIname) : '' ); // replace varname with its value in mail body
                }
            }
        }
        
        System.Debug('textPart =>>> ' + textPart);
        textPart = textPart.replace('{{var', '');
        textPart = textPart.replaceAll('&quot;&quot;}}', '');
        System.Debug('return textPart =>>> ' + textPart);
        System.Debug('subject =>>> ' + subject);
        subject = subject.replace('{{var', '');
        subject = subject.replaceAll('\""}}', '');
        System.Debug('return subject =>>> ' + subject);
        Map<String, String> returnTemplate = new Map<String, String>{'subject' => subject, 'body'=> textPart};
        return returnTemplate;
    }
    
    public static Date calculateAddDays(Date startDate, integer noOfDays){
        return startDate.addDays(noOfDays);
    }
    
    public static Date calculateAddMonths(Date startDate, integer noOfMonths){
        return startDate.addMonths(noOfMonths);
    }
    
    public static Integer calculateDaysBetween(Date endDate, Integer days){
        return System.today().daysBetween(endDate.addDays(days));
    }
    
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        if(startDate == null){
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()){
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
     public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) == 5 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }
    
    public class saveMsgWrapper{
        public string resBody;
        Map<String,recipient> recMap;
        public string Subject;
    }   
    
    public class recipient{
        String Email;
        String name;
        String recId;
        public  String Link;
        public String buttonLink;
        public   String Label;
        public recipient(String Email,String name,String recId,String Link){
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            this.link = link;
        }
        public recipient(String Email,String name,String recId,String Link,String buttonLink,String Label ){
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            this.link = link;
            this.buttonLink = buttonLink;
            this.Label = Label;
        }
        public recipient(String Email,String name,String recId){
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            
        }
    }
    
    public static void saveErrorDetails(String recId,String error,String subject,String email){
        Mailjet_Message__c mm = new Mailjet_Message__c(response_status__c='Error',Subject__c=Subject,Record_ID__c=recId,
                                                       Error__c=error);
        insert mm;
    }
    
    public static void saveMessageDetails(String resJSON,Map<String,recipient> recMap, STring Subject){
        List<response> jsonList = new  List<response>();
        //add try catch if deserialize breaks create Message with error
        try{
            jsonList =    ( List<response>) System.JSON.deserialize(resJSON, List<response>.class);
        }
        catch(Exception e){
            system.debug('ERROR --> '+e.getMessage());
        }
        system.debug(jsonList);
        List<Mailjet_Message__c> mailJetList = new List<Mailjet_Message__c>();
        for(response res : jsonList){
            
            for(Messages msg : res.Messages){
                system.debug(msg);
                Mailjet_Message__c mm = new Mailjet_Message__c(response_status__c='success',Subject__c=Subject,Record_ID__c=recMap.get(msg.to[0].Email).recid,
                                                               Message_Id__c=msg.to[0].MessageID,Email_ID__c=msg.to[0].Email);
                mailJetList.add(mm);
            }
        }
        
        insert mailJetList;
    }
   
    public static List<API_Service__mdt> metaDataListbyLabel(String metaDataLabel){
        List<API_Service__mdt> metaDataList = [SELECT EndPoint_URL__c, Username__c, Password__c, From_Name__c, From_Address__c,
                                               Template_Id__c, Scheme_Signatory__c, Scheme_Address__c,Scheme_Bank_Account_Number__c,
                                               Scheme_Sort_Code__c,Scheme_Bank_Name__c, Label
                                               FROM API_Service__mdt 
                                               WHERE QualifiedApiName=:metaDataLabel];
        return metaDataList;
    }
    
    public class response{
        String Status;
        List<Messages> messages;
    }
    
    public class Messages{
        String Status;
        String CustomID;
        List<To> To;
    }
    
    
    public class To{
        String Email;
        String MessageUUID;
        String MessageID;
        String MessageHref;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> fetchRecipients(Id recordId){
        String ObjName = recordId.getSobjectType().getDescribe().getName();
        System.debug('ObjName => ' + ObjName);
        List<Map<String,String>> returnRecipients = new List<Map<String,String>>();
        if(ObjName == 'Case'){
            list<Case_Participant__c> CP = [select id, type__c, Contact__c, Contact__r.name, Contact__r.Email, Account__r.name, Account__r.PersonEmail, Account__r.Email__c from Case_Participant__c where Case__c=:recordId];
            Set<Id> CPaccIdSet = new Set<Id>();
            map<Id, String> cpRoleIdMap = new map<Id, String>();
            for(Case_Participant__c participient : CP){
                CPaccIdSet.add(participient.Account__c);
                cpRoleIdMap.put(participient.Account__c, participient.type__c);
                /*Map<String,String>  newMap = new Map<String,String>();
                String name = participient.Contact__r.name; // participient.Account__r.name;
                String email = participient.Contact__r.Email; //String email = participient.Account__r.PersonEmail != null ? participient.Account__r.PersonEmail : participient.Account__r.Email__c;
                newMap.put('name', name);
                newMap.put('email', email);
                newMap.put('Id', participient.contact__c);
                returnRecipients.add(newMap);*/
            }
            LIst<Contact> CPconList = [select id, name, Email, AccountId From Contact Where AccountId IN :(CPaccIdSet)];
            for(Contact participientCon : CPconList){
                Map<String,String>  newMap = new Map<String,String>();
                String name = participientCon.name;
                String email = participientCon.Email;
                newMap.put('name', name);
                newMap.put('email', email);
                newMap.put('role', cpRoleIdMap.get(participientCon.AccountId) );
                newMap.put('Id', participientCon.Id);
                returnRecipients.add(newMap);
            }
        }
        else{
            list<Deposit__c> DA = [select id, customer__c, Customer_Name__c, customer__r.Email__c, customer__r.PersonEmail, Customer__r.IsPersonAccount,
                                   (select id, Role__c, Deposit_Holder__c, Deposit_Holder__r.Salutation, Deposit_Holder__r.FirstName, Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Deposit_Holder__r.Email__c, Deposit_Holder__r.IsPersonAccount,
                                    contact__c, contact__r.Name, contact__r.Email, contact__r.AccountId 
                                    from Deposit_Allocations__r) 
                                   from Deposit__c where id=:recordId limit 1];
            System.debug('depositHolders => ' + DA);
            for(Deposit__c deposit : DA){
                Map<String,String>  newMap = new Map<String,String>();
                String name = deposit.Customer_Name__c;
                String email = deposit.customer__r.PersonEmail!=null? deposit.customer__r.PersonEmail: deposit.customer__r.Email__c;
                //newMap.put('name', name);
                //newMap.put('email', email);
                //newMap.put('Id', deposit.customer__c);
                //returnRecipients.add(newMap);
                
                for(Deposit_Allocation__c depAlloc : deposit.Deposit_Allocations__r){
                    System.debug('depAlloc => ' + depAlloc);
                    Map<String,String>  DAMap = new Map<String,String>();
                    String DAname = depAlloc.contact__r.name; //depAlloc.Deposit_Holder__r.Name;
                    String DAemail = depAlloc.contact__r.Email; //depAlloc.Deposit_Holder__r.PersonEmail!=null? depAlloc.Deposit_Holder__r.PersonEmail: depAlloc.Deposit_Holder__r.Email__c;
                    DAMap.put('name', DAname);
                    DAMap.put('email', DAemail);
                    DAMap.put('role', depAlloc.Role__c);
                    DAMap.put('Id', depAlloc.contact__c);
                    returnRecipients.add(DAMap);
                }
            }
        }
        System.debug('returnRecipients => ' + returnRecipients);
        return returnRecipients;
    }
    
/*  @AuraEnabled
    public static list<Deposit__c> fetchDA(Id depositId){
        
        list<Deposit__c> depositHolders = [select id, customer__c, Customer_Name__c, customer__r.Email__c, customer__r.PersonEmail, Customer__r.IsPersonAccount,
                                                   (select id, Deposit_Holder__c, Deposit_Holder__r.Salutation, Deposit_Holder__r.FirstName, Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Deposit_Holder__r.Email__c, Deposit_Holder__r.IsPersonAccount 
                                                    from Deposit_Allocations__r) 
                                                   from Deposit__c where id=:depositId];
        System.debug('depositHolders => ' + depositHolders);
        return depositHolders;
    }
    */
    
    @AuraEnabled
    public static String sendEmailFromActivityTab(Id recordId, Integer tempId, String fromEmail, String to, String mailBody,String subject,  List<String> uploadedFiles){
       // System.debug('entered into sendEmailFromActivityTab' + uploadedFiles);
            // System.debug('ContentType'+ uploadedFiles.substringBetween('data:', ';base64')); 
            // System.debug('Filename'+ uploadedFiles.substringBetween('fileName:', ';data:'));
            // System.debug('Base64Content'+ uploadedFiles.substringAfter('base64,'));
        
        String caseId = '';
        Case caseData;
        String ObjName = recordId.getSobjectType().getDescribe().getName();
        if(ObjName == 'Deposit__c'){
            List<Deposit__c> depo = [Select Id, Name, caseId__c From Deposit__c Where Id = :recordId];
            if(depo.size() > 0){
                caseId = depo[0].caseId__c;
            }
        }else{
            caseId = recordId;
        }
        
        if(CaseId != null){
            caseData = [Select Id, status, Respond_Date__c From Case Where Id = :caseId];
        }
        
        System.debug('Enterd in sendEmailofList');
        System.Debug('email CaseId  => ' + caseId);
        System.Debug('email fromEmail => ' + fromEmail);
        System.Debug('email to => ' + to);
        System.Debug('email mailBody => ' + mailbody);
        System.Debug('email Subject => ' + subject);
        System.Debug('email uploadedFiles => ' + uploadedFiles);
        System.Debug('caseData => ' + caseData);
        HttpRequest req = mailJetAuthentication();
        
        Integer mailJetTemplateId;        
        List<API_Service__mdt> templateId = metaDataListbyLabel('SDSManualEMail'); 
        
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c); //3094320;
        
        Map<String,recipient> recMap = new Map<String,recipient>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        
        gen.writeStartArray();
        
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        
        gen.writeStartObject();
        gen.writeStringField('Email', fromEmail);  //'ashish.singh1@espire.com' // templateId[0].From_Address__c
        gen.writeStringField('Name', String.valueOf(templateId[0].From_Name__c) );  //'SafeDeposits' // 'SafeDeposits Scotland'
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email',to); 
        gen.writeStringField('Name', to);
        gen.writeEndObject();      
        gen.writeEndArray();	
        
        gen.writeNumberField('TemplateID', mailJetTemplateId); 
        gen.writeBooleanField('TemplateLanguage', true);
        system.debug('subject**** '+subject );
        if(String.isNotBlank(Subject)){
            gen.writeStringField('Subject', Subject);
        }
        
        gen.writeFieldName('Variables');    
        
        gen.writeStartObject();
        gen.writeStringField('body',mailBody);
        gen.writeEndObject(); 

        gen.writeFieldName('Attachments');
        gen.writeStartArray();  
        
         
       /* String attachedFile = uploadedFiles[0];
        gen.writeStartObject(); 
        gen.writeStringField('ContentType', attachedFile.substringBetween('data:', ';base64')); 
        gen.writeStringField('Filename', attachedFile.substringBetween('fileName:', ';data:'));
        gen.writeStringField('Base64Content', attachedFile.substringAfter('base64,'));
        gen.writeEndObject();
*/
        for(String aFile: uploadedFiles){
            //String aFile = uploadedFiles[a];
            gen.writeStartObject();
            gen.writeStringField('ContentType', aFile.substringBetween('data:', ';base64')); 
            gen.writeStringField('Filename', aFile.substringBetween('fileName:', ';data:'));
            gen.writeStringField('Base64Content', aFile.substringAfter('base64,'));
           gen.writeEndObject();
        }
        
        gen.writeEndArray();
        
        /*  gen.writeStartObject(); 
        gen.writeStringField('ContentType', 'application/pdf'); 
        gen.writeStringField('Filename', 'picture.pdf');
        gen.writeStringField('Base64Content', uploadedFiles.substringAfter('base64,'));
        gen.writeEndObject();      
        gen.writeEndArray();
        */
        gen.writeEndObject(); 
        gen.writeEndArray();
        gen.writeEndObject();
        
        try{
            String jsonData = gen.getAsString();
            req.setBody(jsonData);
            system.debug(jsonData);
            Http http = new Http();
            HTTPResponse res;
            Date today = System.today();
            System.debug('today => ' + today);
            
            System.debug('condition true>>>>>>>');
            if(tempId == 3136162 || tempId == 3151036){ // NPP 14 || NPP 15
                if(caseId != null){
                    if(caseData.status == 'Review of decision requested' && caseData.Respond_Date__c < today){
                        if(tempId == 3136162){ //NPP14
                            caseData.status = 'Review request declined';
                        }else if(tempId == 3151036){ //NPP15
                            caseData.status = 'Review request accepted';
                        }
                        res = http.send(req);
                        if(res.getStatusCode() == 200){
                            String resBody = res.getBody();
                            system.debug(resBody);                
                            if(!resBody.startsWith('[')){
                                resBody = '['+resBody+']';
                            }
                            recipient rec = new recipient(to,to,caseId);
                            recMap.put(to,rec);
                            //saveMessageDetails(resBody,recMap,Subject );
                            saveMessageDetailsAura(resBody,recMap,Subject,mailBody );
                        }
                    }else{
                        return 'kpiNotPasses';
                    }
                }else{
                    return 'CaseNUll';
                }
                /*else if(tempId == 3151036 && caseData.status == 'Review of decision requested'){
				caseData.status = 'Review request accepted';
				}*/
                update caseData;
                return 'Success';
            }else{
                res = http.send(req);
                if(res.getStatusCode() == 200){
                    String resBody = res.getBody();
                    
                    system.debug(resBody);                
                    if(!resBody.startsWith('[')){
                        resBody = '['+resBody+']';
                    }
                    recipient rec = new recipient(to,to,caseId);
                    recMap.put(to,rec);
                    //saveMessageDetails(resBody,recMap,Subject );
                    saveMessageDetailsAura(resBody,recMap,Subject,mailBody );
                }
                return 'Success';
            }
            /*Http http = new Http();
            HTTPResponse res = http.send(req); 
            if(res.getStatusCode() == 200){
                String resBody = res.getBody();
                
                system.debug(resBody);                
                if(!resBody.startsWith('[')){
                    resBody = '['+resBody+']';
                }
                recipient rec = new recipient(to,to,caseId);
                recMap.put(to,rec);
                //saveMessageDetails(resBody,recMap,Subject );
                saveMessageDetailsAura(resBody,recMap,Subject,mailBody );
            }*/
            
            //system.debug('res-->>'+res.getBody());
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e);
            return 'Fail';
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        
    }
    
    
    public static void saveMessageDetailsAura(String resJSON,Map<String,recipient> recMap, STring Subject,String body){
        List<response> jsonList = new  List<response>();
        //add try catch if deserialize breaks create Message with error
        try{
            jsonList =    ( List<response>) System.JSON.deserialize(resJSON, List<response>.class);
        }
        catch(Exception e){
            system.debug('ERROR --> '+e.getMessage());
        }
        system.debug(jsonList);
        List<Mailjet_Message__c> mailJetList = new List<Mailjet_Message__c>();
        for(response res : jsonList){
            
            for(Messages msg : res.Messages){
                system.debug(msg);
                system.debug('>>>>>>>>>'+recMap);
                Mailjet_Message__c mm = new Mailjet_Message__c(response_status__c='success',Subject__c=Subject,Record_ID__c=recMap.get(msg.to[0].Email).recid,
                                                               Message_Id__c=msg.to[0].MessageID,Email_ID__c=msg.to[0].Email,sent_message__c =body);
                mailJetList.add(mm);
            }
        }
        
        insert mailJetList;
    }
    
}