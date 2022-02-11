public without sharing class EI_RepaymentRequestUtility{


    public static void notifyAgent(List<Repayment_Request__c> newList,Map<id,Repayment_Request__c> oldMap){
    
    Map<Id,Id> mapOfReReqPayVsDepId = new Map<Id,Id>();
    Map<Id,Deposit__c>  mapOfdepIdVsDep = new Map<Id,Deposit__c>();
    //Set<Id> depositIds = new Set<Id>();
    
    for(Repayment_Request__c repayReq : newList){
    system.debug('>>>>>>'+repayReq.Status__c);
    system.debug('>>>>>>'+repayReq.Tenant_Repay_Requested__c);
    system.debug('>>>>>>'+repayReq.Deposit__c);
    system.debug('>>>>>>'+oldMap);
        if(repayReq.Status__c == 'Repayment requested - tenant' && (oldMap == null ? true : repayReq.Status__c != oldMap.get(repayReq.Id).Status__c) && 
           repayReq.Tenant_Repay_Requested__c && repayReq.Deposit__c != null){
            mapOfReReqPayVsDepId.put(repayReq.Id,repayReq.Deposit__c);
        }
    
    }
    
    mapOfdepIdVsDep =  new Map<id,Deposit__c>([Select id,Customer__r.PersonEmail,Deposit_Account_Number__c,Name,Customer__r.Name,Deposit__c.Property_Address__c from Deposit__c where Id IN : mapOfReReqPayVsDepId.values()]);
    system.debug('mapofdeposit>>>'+JSON.serialize(mapOfdepIdVsDep));
    String SDSEmail = 'ashish.singh1@espire.com';
    
    for(Id repayReqId : mapOfReReqPayVsDepId.keyset()){
        
        if(mapOfdepIdVsDep.containsKey(mapOfReReqPayVsDepId.get(repayReqId))){
        
            String jsonbody = getJSONBODYfornotifyAgent(mapOfdepIdVsDep.get(mapOfReReqPayVsDepId.get(repayReqId)),SDSEmail);
            SendEmails(jsonbody);
        }
    
    }
    
    }
    
    @future(callout = true)
    public static void SendEmails(string jsonData){ 
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    public static String getJSONBODYfornotifyAgent(Deposit__c depInst,String SDSEmail){
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', SDSEmail);
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', depInst.Customer__r.PersonEmail);
        gen.writeStringField('Name', depInst.Customer__r.Name);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateId = API_Service__mdt.getInstance('RequestingAgent_LandlordEvidence').Template_Id__c;
        system.debug('templateId--->>> '+templateId);
        
        gen.writeNumberField('TemplateID', Integer.valueOf(templateId));
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = depInst.Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        gen.writeStringField('Subject', 'Tenant has requested to repayment '+firstLine);
       
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        if(String.isnotBlank(depInst.Customer__r.Name))
            gen.writeStringField('LandlordName', depInst.Customer__r.Name);
        if(String.isnotBlank(depInst.Deposit_Account_Number__c))    
            gen.writeStringField('DAN_Number', depInst.Deposit_Account_Number__c);
        if(String.isnotBlank(depInst.Property_Address__c))       
            gen.writeStringField('PropertyAddress', depInst.Property_Address__c);
        gen.writeEndObject(); 
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }



}