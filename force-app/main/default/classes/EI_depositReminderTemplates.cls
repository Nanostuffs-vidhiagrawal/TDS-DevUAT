/**
* @who  Ashish Singh
* @what Generate JSON body for Mail Jet
* @when 01/02/2021
**/
public class EI_depositReminderTemplates {
     public static String jsonData;
    
    /**
* Generate JSON for Mail Jet
**/    
    public static string  JSONcreator(String fromAddress, String fromName, String toAddress,  String toName, Integer templateId, String subject, String propertyAddress, Decimal amount, String bankAccountName, String sortCode, string accountNumber, String danNo, String schemeAddress, Integer daysRemaining, String schemeSignatory){
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray(); 
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', fromAddress);
        gen.writeStringField('Name', fromName);
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', toAddress); 
        gen.writeStringField('Name', toName);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', templateId); 
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', subject); 
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();
        gen.writeStringField('name', toName); 
        gen.writeStringField('address', propertyAddress); 
        gen.writeNumberField('amount', amount); 
        gen.writeStringField('bank_account_name', bankAccountName); 
        gen.writeStringField('sort_code', sortCode); 
        gen.writeStringField('account_number', accountNumber); 
        gen.writeStringField('DAN_no', danNo); 
        gen.writeStringField('scheme_address', schemeAddress); 
        gen.writeNumberField('days', daysRemaining); 
        gen.writeStringField('scheme_signatory', schemeSignatory); 
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        jsonData = gen.getAsString(); 
        System.debug('jsonData'+jsonData);
        return jsonData; 
    }
}