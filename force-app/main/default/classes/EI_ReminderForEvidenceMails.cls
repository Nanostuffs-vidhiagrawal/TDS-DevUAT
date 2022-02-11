public without sharing class EI_ReminderForEvidenceMails implements Queueable,Database.AllowsCallouts {
    
    public Map<String,Set<Id>> mapOfcaseIds;
    public Set<Id> caseIds;
    public EI_ReminderForEvidenceMails(Map<String,Set<Id>> mapOfcaseIds){
        
        this.mapOfcaseIds = mapOfcaseIds;
        this.caseIds = new Set<Id>();
    }
    
    public void execute(QueueableContext QU){
        
        for(string MailTy : mapOfcaseIds.keyset()){
            for(Id caseId : mapOfcaseIds.get(MailTy)){
             if(!caseIds.contains(caseId))  caseIds.add(caseId); 
            }
        }
        
        String SDSEmail = 'ashish.singh1@espire.com';
        
        for(Case_Participant__c caspart : [Select id,name,Type__c,Is_Lead__c,Case__c,Case__r.Status,Contact__r.Email,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Case__r.Tenancy_Property_Address__c,Case__r.Deposit_Account_Number__c,Case__r.Disputed_Amount__c,Case__r.Deposit_Account_Number__r.Name from Case_Participant__c where Case__c IN : caseIds]){
            
            String jsonBody;
            
            if((caspart.Type__c == 'Landlord'  || caspart.Type__c == 'Agent' )){
                if( mapOfcaseIds.get('EvidenceGLL').contains(caspart.Case__c)){
                    jsonBody = getJSONBODYForTTAndLL(caspart,SDSEmail,'Agent');
                }else{
                    if(mapOfcaseIds.get('SelfRes').contains(caspart.Case__c))
                        jsonBody = getJSONBODYForTTLLSelf(caspart,SDSEmail,'Agent'); // json for sending reminder for self resolution
                    else
                        if(mapOfcaseIds.get('SelfRes10DayR').contains(caspart.Case__c))    
                            jsonBody = getJSONBODYForTTLLSelf10(caspart,SDSEmail,'Agent'); // json for informing 10 addition days for self resolution
                }
            }
            if(caspart.Type__c == 'Tenant' ){
                if(mapOfcaseIds.get('EvidenceGTT').contains(caspart.Case__c)){
                    jsonBody = getJSONBODYForTTAndLL(caspart,SDSEmail,'Tenant');
                }else{
                    if(mapOfcaseIds.get('SelfRes').contains(caspart.Case__c))
                        jsonBody = getJSONBODYForTTLLSelf(caspart,SDSEmail,'Tenant'); // json for sending reminder for self resolution
                    else
                        if(mapOfcaseIds.get('SelfRes10DayR').contains(caspart.Case__c))    
                            jsonBody = getJSONBODYForTTLLSelf10(caspart,SDSEmail,'Tenant'); // json for informing 10 addition days for self resolution
                }
            } 
            
            if(String.isNotBlank(JsonBody))
                EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo(JsonBody);
        }
    }
    
    public static String getJSONBODYForTTAndLL(Case_Participant__c castInst,String SDSEmail,String status){
        
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
        if(String.isNotBlank(castInst.Contact__r.Email))
            gen.writeStringField('Email', castInst.Contact__r.Email);
        
        if(String.isNotBlank(castInst.Contact__r.FirstName))
            gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateIdForLL = API_Service__mdt.getInstance('Reminder_For_Evidence_LL').Template_Id__c;
        String templateIdForTT = API_Service__mdt.getInstance('Reminder_For_Evidence_TT').Template_Id__c;
        if(status == 'Tenant')
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForTT));
        else
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForLL));
        
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }

        if(status == 'Tenant' && castInst.Is_Lead__c==false){
            gen.writeStringField('Subject', 'Reminder of your evidence deadline - : '+firstLine);
        }
        else if(status == 'Tenant' && castInst.Is_Lead__c==True){
            gen.writeStringField('Subject', 'Reminder to submit your evidence - : '+firstLine); 
        }
        
        else{
            gen.writeStringField('Subject', 'Reminder to submit your evidence - : '+firstLine);  
        }
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        if(String.isNotBlank(castInst.Contact__r.Name))
            gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Deposit_Account_Number__r.Name))
            gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Tenancy_Property_Address__c))
            gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        
        Date DueDateforEvidence = System.today().adddays(10);
        gen.writeStringField('DueDateforEvidence',String.valueOf(DueDateforEvidence));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
     public static String getJSONBODYForTTLLSelf(Case_Participant__c castInst,String SDSEmail,String status){
        
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
        if(String.isNotBlank(castInst.Contact__r.Email))
            gen.writeStringField('Email', castInst.Contact__r.Email);
        
        if(String.isNotBlank(castInst.Contact__r.FirstName))
            gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateIdForLL = API_Service__mdt.getInstance('Reminder_For_Evidence_LL').Template_Id__c;
        String templateIdForTT = API_Service__mdt.getInstance('Reminder_For_Evidence_TT').Template_Id__c;
        if(status == 'Tenant')
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForTT));
        else
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForLL));
        
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }

        if(status == 'Tenant')
            gen.writeStringField('Subject', 'Reminder - Let us help you reach an agreement - : '+firstLine);
        else
          gen.writeStringField('Subject', 'Reminder - Let us help you reach an agreement - : '+firstLine);  
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        if(String.isNotBlank(castInst.Contact__r.Name))
            gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Deposit_Account_Number__r.Name))
            gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Tenancy_Property_Address__c))
            gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        
        Date DueDateforEvidence = System.today().adddays(10);
        gen.writeStringField('DueDateforEvidence',String.valueOf(DueDateforEvidence));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    public static String getJSONBODYForTTLLSelf10(Case_Participant__c castInst,String SDSEmail,String status){
        
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
        if(String.isNotBlank(castInst.Contact__r.Email))
            gen.writeStringField('Email', castInst.Contact__r.Email);
        
        if(String.isNotBlank(castInst.Contact__r.FirstName))
            gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateIdForLL = API_Service__mdt.getInstance('Reminder_For_Evidence_LL').Template_Id__c;
        String templateIdForTT = API_Service__mdt.getInstance('Reminder_For_Evidence_TT').Template_Id__c;
        if(status == 'Tenant')
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForTT));
        else
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForLL));
        
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }

        if(status == 'Tenant')
            gen.writeStringField('Subject', 'No agreement yet reached - next steps -'+firstLine);
        else
          gen.writeStringField('Subject', 'No agreement yet reached - next steps -: '+firstLine);  
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        if(String.isNotBlank(castInst.Contact__r.Name))
            gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Deposit_Account_Number__r.Name))
            gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Tenancy_Property_Address__c))
            gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        
        Date DueDateforEvidence = System.today().adddays(10);
        gen.writeStringField('DueDateforEvidence',String.valueOf(DueDateforEvidence));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
}