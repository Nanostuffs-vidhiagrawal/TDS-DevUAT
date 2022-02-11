public class EI_ZDCaseTriggerHandler {
    
    public static Boolean IsExecuted=false;
    public static Boolean IsMailExecuted=false;
    private static AssignmentRule caseAssignmentRule;
    public static void sendmailToSelfResolution(Map<Id,Case> newMap, Map<Id,Case> oldMap)
    {
        Map<STring,Case> casePartMap = new  Map<String,Case> ([select id,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,
                                                               Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,
                                                               (select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), 
                                                               (select id,Contact__r.Email,Contact__r.FirstName,Type__c,Access_Code__c from case_participants__r)
                                                               from case where id in : newMap.keyset()]);
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        
        for(Case newCase : newMap.values()) {
            
            if(newCase.Status=='Self-Resolution' && (!system.isBatch()) && newCase.Status != oldMap.get(newCase.Id).Status  && newCase.RecordTypeId ==devRecordTypeId && oldMap.get(newCase.Id).Status !='On Hold'  && newCase.Origin=='Zero Deposit' )
            {
                case cs = casePartMap.get(newCase.id);
                String floa ='';
                String sloa ='';
                String postcode='';
                list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
                list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
                if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.City__c != null){
                    sloa=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.City__c;
                    
                }
                if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                    floa=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c;
                    
                }
                if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                    postcode=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Postal_Code__c;
                    
                }
                Map<String,String> var = new Map<String,String>();
                var.put('floa',floa);
                var.put('sloa',sloa);
                var.put('postcode',postcode);
                
                if(newCase.Respond_Date__c != null){
                    String  todaysDateStr = newCase.Respond_Date__c.Day() + '/' + newCase.Respond_Date__c.month() + '/' + newCase.Respond_Date__c.year();
                    var.put('date',todaysDateStr);
                    
                }
                list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
                
                for(case_participant__c cp : cs.case_participants__r){
                    
                    if(cp.type__c == 'Tenant'){
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id,null,label.EI_ZD_LoginURL,'Claim Account');
                        tenantList.add(rec);
                    }
                    else {
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id,null,label.EI_ZD_AGLLLoginURL+cp.Access_Code__c,'Your Claim');
                        agentList.add(rec);
                    }
                    
                }
                if(newCase.Tenancy_Property_Address__c!=null)
                    var.put('propaddress',newCase.Tenancy_Property_Address__c);
                if(newCase.Tenancy_Property_Address__c!=null)
                    var.put('guaranteenum',newCase.ZD_Reference_Number__c);
                if(newCase.Total_Claim_Amount__c!=null)
                    var.put('totalclaim',newCase.Total_Claim_Amount__c+'');
                
                
                if(tenantList.size()>0)
                    EI_ZD_EmailUtility.sendEmail('Thank You for Responding - Your Agent/Landlord will now Review', JSON.Serialize(tenantList),var,'ZP2AC2TT','mailJetZD');
                if(agentList.size()>0)  
                    EI_ZD_EmailUtility.sendEmail('Decision Required - Tenant Response to Claim on '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP2AC2AGLL','mailJetZD');
            }
            
            
            
            // EI_ZD_EmailUtility.sendEmailByMailJet(newCase.ID,'Self Resolution Invitation Mail');
        }
        
        
    }
    public static void sendmailToInviteEvidenceAGLL(Map<Id,Case> newMap, Map<Id,Case> oldMap)
    {
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        Map<STring,Case> casePartMap = new  Map<String,Case> ([select id,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,
                                                               Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,
                                                               (select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), 
                                                               (select id,Contact__r.Email,Contact__r.FirstName,Type__c,access_code__c from case_participants__r)
                                                               from case where id in : newMap.keyset()]);
        for(Case newCase : newMap.values()) {
            if(newCase.Status=='Evidence gathering agent/landlord' && (!system.isBatch()) && newCase.Status != oldMap.get(newCase.Id).Status && oldMap.get(newCase.Id).Status !='On Hold' && newCase.RecordTypeId ==devRecordTypeId  && newCase.Origin=='Zero Deposit' )
            {
                
                String floa ='';
                String sloa ='';
                String postcode='';
                list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
                list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
                if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.City__c != null){
                    sloa=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.City__c;
                    
                }
                if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                    floa=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c;
                    
                }
                if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                    postcode=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Postal_Code__c;
                    
                }
                Map<String,String> var = new Map<String,String>();
                var.put('floa',floa);
                var.put('sloa',sloa);
                var.put('postcode',postcode);
                
                var.put('bulletlist','<ul style="color: #55575d;font-family: arial;font-size: 13px;line-height: 22px;"> <li>   A copy of the tenancy agreement signed by all parties</li> <li>If you are claiming for rent, then a rent statement</li> <li>If you are claiming for anything else: <ul> <li>Check in and check out reports, or other evidence that shows the state of the property at the start and end of the tenancy (if you do not have a check in or check out report, then we need photographs that are clearly dated); and</li> <li>Evidence that explains the size of the financial loss you are claiming for (for example, invoices or receipts for work or purchases)</li> </ul> </li> </ul>');
                
                list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
                if(newCase.Respond_Date__c != null){
                    String  todaysDateStr =  newCase.Respond_Date__c.Day() + '/' + newCase.Respond_Date__c.month() + '/' + newCase.Respond_Date__c.year();
                    var.put('date',todaysDateStr);
                    
                }
                
                for(case_participant__c cp : casePartMap.get(newCase.id).case_participants__r){
                    
                    if(cp.type__c == 'Tenant'){
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id);
                        tenantList.add(rec);
                    }
                    else {
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id,null,label.EI_ZD_AGLLLoginURL+cp.Access_Code__c,'Provide Evidence');
                        agentList.add(rec);
                    }
                    
                }
                if(newCase.Tenancy_Property_Address__c!=null)
                    var.put('propaddress',newCase.Tenancy_Property_Address__c);
                if(newCase.Tenancy_Property_Address__c!=null)
                    var.put('guaranteenum',newCase.ZD_Reference_Number__c);
                if(newCase.Total_Claim_Amount__c!=null)
                    var.put('totalclaim',newCase.Total_Claim_Amount__c+'');
                
                
                if(tenantList.size()>0)
                    EI_ZD_EmailUtility.sendEmail('Evidence Requested From Your Agent/Landlord - We Will Notify You of Next Action', JSON.Serialize(tenantList),var,'ZP5AC1TT','mailJetZD');
                if(agentList.size()>0)  
                    EI_ZD_EmailUtility.sendEmail('Provide Evidence Now to Support Claim  - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP5AC1AGLL','mailJetZD');
                
                // EI_ZD_EmailUtility.sendEmailByMailJet(newCase.ID,'Agent/landlord invitation to evidence gathering ');
            }
        }
        
    }
    
    public static void makePayment(Map<Id,Case> newMap, Map<Id,Case> oldMap)
    {
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        Set<Id> claimIds =  newMap.keyset();
        list<Case_Participant__c> CP = [select Case__c,id,account__r.Tenant_External_ID__c from Case_Participant__c where Case__c in :claimIds and Is_Lead__c=true];
        map<id,string> caseParticipant = new map<id,string>();
        for(Case_Participant__c casePar : CP){
            caseParticipant.put(casePar.Case__c, casePar.account__r.Tenant_External_ID__c);
        }
        
        for(Case newCase : newMap.values()) {
            if((newCase.Status=='Case closed - agreement reached' || newCase.Status=='Decision issued') && (newCase.Make_Payment_By_Community__c==false) && (!system.isBatch()) && newCase.Status != oldMap.get(newCase.Id).Status &&  newCase.RecordTypeId ==devRecordTypeId  && newCase.Origin=='Zero Deposit' )
            {
                
                EI_ZD_PaymentAPI.getperformcalloutTrigger(newCase.Id,newCase.External_ID__c, 'Adjudication',newCase.Final_Amount_paid__c, 'Zero Deposite',caseParticipant.get(newCase.Id),newCase.Claim_Agreed_By__c);
            }
        }
    }
    public static void sendmailToInviteEvidenceTT(Map<Id,Case> newMap, Map<Id,Case> oldMap)
    {
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        Map<STring,Case> casePartMap = new  Map<String,Case> ([select id,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,
                                                               Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,
                                                               (select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), 
                                                               (select id,Contact__r.Email,Contact__r.FirstName,Type__c,access_code__c from case_participants__r)
                                                               from case where id in : newMap.keyset()]);
        for(Case cs : newMap.values()) {
            if(cs.Status=='Evidence gathering tenant' && (!system.isBatch()) && cs.Status != oldMap.get(cs.Id).Status && oldMap.get(cs.Id).Status !='On Hold'  && cs.RecordTypeId ==devRecordTypeId && cs.Origin=='Zero Deposit' )
            {
                String floa ='';
                String sloa ='';
                String postcode='';
                if(casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.City__c != null){
                    sloa=casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.City__c;
                    
                }
                if(casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                    floa=casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.Street__c;
                    
                }
                if(casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                    postcode=casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.Postal_Code__c;
                    
                }
                list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
                list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
                Map<String,String> var = new Map<String,String>();
                var.put('floa',floa);
                var.put('sloa',sloa);
                var.put('postcode',postcode);
                if(cs.Respond_Date__c != null){
                    String todaysDateStr =  cs.Respond_Date__c.Day() + '/' + cs.Respond_Date__c.month() + '/' + cs.Respond_Date__c.year();
                    var.put('date',todaysDateStr);
                    
                }
                
                
                list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
                
                for(case_participant__c cp : casePartMap.get(cs.id).case_participants__r){
                    
                    if(cp.type__c == 'Tenant'){
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id,null,label.EI_ZD_LoginURL,'Review and Provide Evidence');
                        tenantList.add(rec);
                    }
                    else {
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                        agentList.add(rec);
                    }
                    
                }
                
                if(tenantList.size()>0)
                    EI_ZD_EmailUtility.sendEmail('Provide Evidence Now - Ensure Amount You Owe is Fair and Correct', JSON.Serialize(tenantList),var,'ZP5AC19TT','mailJetZD');
                if(agentList.size()>0)  
                    EI_ZD_EmailUtility.sendEmail('Thank You for Your Evidence - Awaiting Tenant Response - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP5AC19AGLL','mailJetZD');
                
                //  EI_ZD_EmailUtility.sendEmailByMailJet(newCase.ID,'Tenent invitation to evidence gathering');
            }
        }
        
    }
    /* public static void handleCloseCaseEmail(Map<Id,Case> newMap, Map<Id,Case> oldMap)
{
Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
for(Case newCase : newMap.values()) {
if(newCase.Status =='Closed' && (!system.isBatch()) && newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId  && newCase.Origin=='Zero Deposit'  //
&& (newCase.Close_Reason__c != 'No Response From Either Party' && newCase.Close_Reason__c != 'No Response From Agent/Landlord' )
)
{
if(newCase.Claim_Agreed_By__c=='Tenant')
{
EI_ZD_EmailUtility.sendEmailByMailJet(newCase.ID,'Tenant agrees to claim');
}
else if(newCase.Claim_Agreed_By__c=='Agent/Landlord')
{
EI_ZD_EmailUtility.sendEmailByMailJet(newCase.ID,'Agent/Landlord agrees to claim');
}
else if(newCase.Close_Reason__c == 'Case Closed')
{
EI_ZD_EmailUtility.sendEmailByMailJet(newCase.ID,'Claim cancelled');
}

}
}
}*/
    //ZP-6
    Public static void handleStatusCaseMail(Map<Id,Case> newMap, Map<Id,Case> oldMap){
        
        Map<String,String> mapJSON = new Map<String,String>();
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        // SOQL just to get all participants
        Map<STring,Case> casePartMap = new  Map<String,Case> ([select id,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,
                                                               Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,
                                                               (select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), 
                                                               (select id,Contact__r.Email,Contact__r.FirstName,Type__c from case_participants__r)
                                                               from case where id in : newMap.keyset()]);
        for(String caseId : newMap.keySet()) {
            Case oldCase = oldMap.get(caseId);
            Case newCase = newMap.get(caseId);
            String floa ='';
            String sloa ='';
            String postcode='';
            if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
            }
            
            
            if( newCase.RecordTypeId ==devRecordTypeId  ){
                if(newCase.Status == 'Case cancelled' &&
                   oldCase.Status != 'Case cancelled')
                {
                    
                    list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
                    list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
                    Map<String,String> var = new Map<String,String>();
                    for(case_participant__c cp : casePartMap.get(caseId).case_participants__r){
                        if(cp.type__c == 'Tenant'){
                            EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id);
                            tenantList.add(rec);
                        }
                        else {
                            EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id);
                            agentList.add(rec);
                        }
                        
                        var.put('floa',floa);
                        var.put('url','www.google.com');
                        var.put('sloa',sloa);
                        var.put('postcode',postcode);
                        
                        
                        
                    }
                    if(tenantList.size()>0)
                        EI_ZD_EmailUtility.sendEmail('Claim Cancelled - '+floa +', '+sloa, JSON.Serialize(tenantList),var,'CaseCancelTenant','mailJetZD');
                    if(agentList.size()>0)  
                        EI_ZD_EmailUtility.sendEmail('Claim Cancelled - '+floa +', '+sloa, JSON.Serialize(agentList),var,'AGLLCaseCancel','mailJetZD');
                    
                }
                else if((newCase.Status == 'Adjudication' || newCase.Status == 'Evidence review complete') &&
                        (oldCase.Status != 'Adjudication' && oldCase.Status != 'Evidence review complete' && oldCase.Status != 'On Hold'))
                { 
                    Map<String,String> var = new Map<String,String>();
                    for(Dispute_Item__c di : casePartMap.get(caseId).Dispute_Items__r){
                        var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
                    }
                    list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
                    
                    for(case_participant__c cp : casePartMap.get(caseId).case_participants__r){
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id);
                        recipientList.add(rec);
                        
                    }
                    
                    
                    if(newCase.Tenancy_Property_Address__c!=null)
                        var.put('propaddress',floa);
                    
                    DateTime todaysDate = System.today();
                    String todaysDateStr = todaysDate.format('dd/MM/yyyy');
                    var.put('issuedate',todaysDateStr);
                    if(newCase.Tenancy_Property_Address__c!=null)
                        var.put('guaranteenum',newCase.ZD_Reference_Number__c);
                    if(newCase.Total_Claim_Amount__c!=null)
                        var.put('totalclaim',newcase.Total_Claim_Amount__c+'');
                    if(casePartMap.get(caseId).owner.name!=null)
                        var.put('user',casePartMap.get(caseId).owner.name);
                    
                    
                    EI_ZD_EmailUtility.sendEmail('Case update - '+floa, JSON.Serialize(recipientList),var,'CaseAdjudication','mailJetZD');
                    EI_ZDCaseTriggerHandler.isExecuted = true;
                }
                /* else if(newCase.Status == 'Case closed - agreement reached' &&
oldCase.Status != 'Case closed - agreement reached')
{
Map<String,String> var = new Map<String,String>();
list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();

for(case_participant__c cp : casePartMap.get(caseId).case_participants__r){
if(cp.type__c == 'Tenant'){
EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id);
tenantList.add(rec);
}
else {
EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id);
agentList.add(rec);
}
}
if(newcase.Total_Agreed_by_Tenant__c!=null){
var.put('agreeamt',newcase.Total_Agreed_by_Tenant__c+'');
}


if(tenantList.size()>0)
EI_ZD_EmailUtility.sendEmail('Claim Agreed - Your Payment is Now Due', JSON.Serialize(tenantList),var,'tenantCaseCLose','mailJetZD');
if(agentList.size()>0)  
EI_ZD_EmailUtility.sendEmail('Claim Agreed - Confirm Bank Details for Payout -'+floa +' '+sloa+casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.Street__c +' '+casePartMap.get(newCase.id).Deposit_Account_Number__r.Property__r.city__c   , JSON.Serialize(agentList),var,'AGLLCaseCLose','mailJetZD');



}*/
            }
        }
        
    }
    public static void sendmailToInviteAGLLTT(Map<Id,Case> newMap, Map<Id,Case> oldMap){
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        Map<STring,Case> casePartMap = new  Map<String,Case> ([select id,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,
                                                               Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,
                                                               (select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), 
                                                               (select id,Contact__r.Email,Contact__r.FirstName,Type__c,Access_Code__c from case_participants__r)
                                                               from case where id in : newMap.keyset()]);
        for(Case cs : newMap.values()) {
            
            if(cs.Status=='Invitation to view the claim' && cs.Status != oldMap.get(cs.Id).Status && oldMap.get(cs.Id).Status !='On Hold'  && cs.RecordTypeId ==devRecordTypeId )
            {
                String floa ='';
                String sloa ='';
                String postcode='';
                if(casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.City__c != null){
                    sloa=casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.City__c;
                    
                }
                if(casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                    floa=casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.Street__c;
                    
                }
                if(casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.Street__c != null){
                    postcode=casePartMap.get(cs.id).Deposit_Account_Number__r.Property__r.Postal_Code__c;
                    
                }
                list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
                list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
                Map<String,String> var = new Map<String,String>();
                var.put('floa',floa);
                var.put('sloa',sloa);
                var.put('postcode',postcode);
                var.put('value',cs.Total_Claimed_by_Landlord__c+'');
                if(cs.Respond_Date__c != null){
                    String todaysDateStr =  cs.Respond_Date__c.Day() + '/' + cs.Respond_Date__c.month() + '/' + cs.Respond_Date__c.year();
                    var.put('date',todaysDateStr);
                    
                }
                
                
                list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
                
                for(case_participant__c cp : casePartMap.get(cs.id).case_participants__r){
                    
                    if(cp.type__c == 'Tenant'){
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id,null,label.EI_ZD_LoginURL,'Claim Account');
                        tenantList.add(rec);
                    }
                    else {
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                        agentList.add(rec);
                    }
                    
                }
                
                // if(tenantList.size()>0)
                //   EI_ZD_EmailUtility.sendEmail('View Your Landlord’s Claim -  '+floa +', '+sloa, JSON.Serialize(tenantList),var,'ZP1AC6TT','mailJetZD');
                if(agentList.size()>0)  
                    EI_ZD_EmailUtility.sendEmail('Claim Submitted - Confirmation', JSON.Serialize(agentList),var,'ZP1AC6AGLL','mailJetZD');
                
                //  EI_ZD_EmailUtility.sendEmailByMailJet(newCase.ID,'Tenent invitation to evidence gathering');
            }
        }
    }
    
    // To update respond date, will update later according the case status
    public static void updateResponddate(Map<Id,Case> newMap, Map<Id,Case> oldMap) 
    {
        system.debug('check flag trigger 460');
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        list<Case> casetoUpdate= new list<Case>();
        for(Case newCase : newMap.values()) {
            system.debug('check flag trigger newCase.Status'+ newCase.Status);
            system.debug('check flag trigger oldMap.get(newCase.Id).Status-'+oldMap.get(newCase.Id).Status);
            system.debug('check flag trigger newCase.RecordTypeId=='+newCase.RecordTypeId);
            system.debug('check flag trigger devRecordTypeId--'+devRecordTypeId);
            system.debug('check flag trigger newCase.Status--'+newCase.Status);
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && (newCase.Status=='Self-Resolution' || newCase.Status=='Evidence gathering agent/landlord' || newCase.Status=='Evidence gathering tenant' ) && oldMap.get(newCase.Id).Status !='On Hold' )
            {
                system.debug('check flag trigger 466');
                Date ResponseDate=EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
                Date IIIrdWorkingdate  = EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 3);
                newCase.Respond_Date__c=ResponseDate;
                newcase.IIIrd_Working_Day_SR__c = IIIrdWorkingdate;
                newcase.Previous_on_hold_end_date__c = null;
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
                EI_ZDCaseTriggerHandler.isExecuted = true;
            }
            else if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && (newCase.Status=='Evidence review complete' || newCase.Status=='Adjudication') && oldMap.get(newCase.Id).Status !='On Hold' &&  oldMap.get(newCase.Id).Status !='Evidence review complete' )
            {
                Date ResponseDate=EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(),20);
                Date IIIrdWorkingdate  = EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
                newCase.Respond_Date__c=ResponseDate;
                newcase.IIIrd_Working_Day_SR__c = IIIrdWorkingdate; 
                newcase.Previous_on_hold_end_date__c = null;
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
                EI_ZDCaseTriggerHandler.isExecuted = true;
            }
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && newCase.Status=='Invitation to view the claim')
            {
                newcase.Previous_on_hold_end_date__c = null;
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
            }
            
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && newCase.Status=='Evidence review complete')
            {
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
            }
            
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit')
            {
                
                if(newCase.Status=='On Hold'){
                    newCase.PreviousStatus__c = oldMap.get(newCase.Id).Status;
                    integer totalNoOfDays = 0;
                    integer checkday =0;
                    
                    if(newCase.Previous_on_hold_end_date__c != null && newCase.On_Hold_Start_Date__c == newCase.Previous_on_hold_end_date__c)
                    {
                        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
                        if(EI_ZD_HomePage.checkifItisWorkingDay(newCase.On_Hold_Start_Date__c,holidays))
                        {
                            checkday=1; 
                        }
                    }

                    if(newCase.On_Hold_End_Date__c != null)
                    {
                        if(newCase.On_Hold_Start_Date__c == newcase.On_Hold_End_Date__c)
                        {
                            if(checkday >0)
                            {
                                totalNoOfDays=0;
                            }
                            else
                            {
                                totalNoOfDays=1;
                            }
                            
                            /*
                            if(newCase.Previous_on_hold_end_date__c == newcase.On_Hold_End_Date__c)
                            {
                                totalNoOfDays=0;
                            }
                            else
                            {
                                totalNoOfDays=1; 
                            }*/
                        }
                        else
                        {
                            if(checkday >0)
                            {
                                totalNoOfDays = EI_ZD_HomePage.calculateWorkingDays(newCase.On_Hold_Start_Date__c.adddays(1),newCase.On_Hold_End_Date__c);
                            }
                            else
                            {
                                totalNoOfDays = EI_ZD_HomePage.calculateWorkingDays(newCase.On_Hold_Start_Date__c,newCase.On_Hold_End_Date__c);
                            }
                            
                        }
                        
                    }
                    if(totalNoOfDays > 0)
                    {
                        if(!Test.isRunningTest()){
                            newCase.Respond_Date__c= EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(newCase.Respond_Date__c,totalNoOfDays+1); 
                        }
                    }
                    
                    if(oldMap.get(newCase.Id).Status =='Invitation to view the claim')
                    {
                        decimal oldnoofdays = newCase.On_hold_Invitation_to_view_the_claim__c != null ? newCase.On_hold_Invitation_to_view_the_claim__c : 0;
                        newCase.On_hold_Invitation_to_view_the_claim__c = oldnoofdays+totalNoOfDays;
                    }
                    else if(oldMap.get(newCase.Id).Status =='Self-resolution') {
                        decimal oldnoofdays = newCase.On_hold_self_resolution__c != null ? newCase.On_hold_self_resolution__c : 0;
                        newCase.On_hold_self_resolution__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Evidence gathering agent/landlord')
                    {
                        decimal oldnoofdays = newCase.On_hold_Evidence_gathering_agent_landlor__c != null ? newCase.On_hold_Evidence_gathering_agent_landlor__c : 0;
                        newCase.On_hold_Evidence_gathering_agent_landlor__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Evidence gathering tenant')
                    {
                        decimal oldnoofdays = newCase.On_hold_Evidence_gathering_tenant__c != null ? newCase.On_hold_Evidence_gathering_tenant__c : 0;
                        newCase.On_hold_Evidence_gathering_tenant__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Awaiting evidence review')
                    {
                        decimal oldnoofdays = newCase.On_hold_Awaiting_evidence_review__c != null ? newCase.On_hold_Awaiting_evidence_review__c : 0;
                        newCase.On_hold_Awaiting_evidence_review__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Evidence review complete')
                    {
                        decimal oldnoofdays = newCase.On_hold_evidence_review_complete__c != null ? newCase.On_hold_evidence_review_complete__c : 0;
                        newCase.On_hold_evidence_review_complete__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Adjudication')
                    {
                        decimal oldnoofdays = newCase.On_hold_adjudication__c != null ? newCase.On_hold_adjudication__c : 0;
                        newCase.On_hold_adjudication__c = oldnoofdays+totalNoOfDays;
                    }
                    //newcase.Previous_on_hold_end_date__c = newCase.On_Hold_End_Date__c;
                }
                if(oldMap.get(newCase.Id).Status=='On Hold' && newCase.Status != 'On Hold' ){
                    if((newCase.On_Hold_End_Date__c != Date.today() &&  newCase.On_Hold_End_Date__c > Date.today()) || newCase.On_Hold_End_Date__c== null )
                    {
                        newCase.On_Hold_End_Date__c =Date.today();
                    }
                    newcase.Previous_on_hold_end_date__c = newCase.On_Hold_End_Date__c;
                }
                 
            }
            
            if(oldMap.get(newCase.Id).Status =='On Hold' && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit')
            {
                /*
                 * 
                 * 
                 */
                
                if ( oldMap.get(newCase.Id).On_Hold_End_Date__c != null && newCase.On_Hold_End_Date__c != null  && oldMap.get(newCase.Id).On_Hold_End_Date__c != newCase.On_Hold_End_Date__c)
                {
                    
                    integer totalNoOfDays =0 ;
                    
                   // newCase.Previous_on_hold_end_date__c = newCase.On_Hold_End_Date__c;
                    
                        if(oldMap.get(newCase.Id).On_Hold_End_Date__c > newCase.On_Hold_End_Date__c)
                        {
                            totalNoOfDays = EI_ZD_HomePage.calculateWorkingDays(newCase.On_Hold_End_Date__c.adddays(1),oldMap.get(newCase.Id).On_Hold_End_Date__c);
                            totalNoOfDays= (totalNoOfDays) * (-1);
                        }
                        else
                        {
                                totalNoOfDays = EI_ZD_HomePage.calculateWorkingDays((oldMap.get(newCase.Id).On_Hold_End_Date__c).adddays(1),newCase.On_Hold_End_Date__c);
                           
                        }
                    
//============================================================   
//
                 
                    
                    
                    /*integer checkday =0;
                    
                    if(newCase.Previous_on_hold_end_date__c != null && newCase.On_Hold_Start_Date__c !=newCase.On_Hold_End_Date__c  
                       && newCase.On_Hold_Start_Date__c == newCase.Previous_on_hold_end_date__c)
                    {
                        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
                        if(EI_ZD_HomePage.checkifItisWorkingDay(newCase.On_Hold_Start_Date__c,holidays))
                        {
                            checkday=1; 
                        }
                    } */
                    
                    if(totalNoOfDays > 0)
                    {
                        
                        newCase.Respond_Date__c=EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(oldMap.get(newCase.Id).Respond_Date__c,(totalNoOfDays+1));	
                    }
                    else
                    {
                        if(totalNoOfDays < 0)
                        {
                            newCase.Respond_Date__c=calculateNegativeWorkingDaysBetweenTwoDates(oldMap.get(newCase.Id).Respond_Date__c,math.abs(totalNoOfDays-1));
                        	    
                        }
                    }
                    
                    
                    if(newCase.PreviousStatus__c =='Invitation to view the claim' || oldMap.get(newCase.Id).PreviousStatus__c =='Invitation to view the claim' )
                    {
                        decimal oldnoofdays = newCase.On_hold_Invitation_to_view_the_claim__c != null ? newCase.On_hold_Invitation_to_view_the_claim__c : 0;
                        newCase.On_hold_Invitation_to_view_the_claim__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if(newCase.PreviousStatus__c =='Self-resolution' || oldMap.get(newCase.Id).PreviousStatus__c =='Self-resolution') 
                    {
                        decimal oldnoofdays = newCase.On_hold_self_resolution__c != null ? newCase.On_hold_self_resolution__c : 0;
                        newCase.On_hold_self_resolution__c = oldnoofdays+totalNoOfDays;
                           
                    }
                    else if (newCase.PreviousStatus__c =='Evidence gathering agent/landlord' || oldMap.get(newCase.Id).PreviousStatus__c =='Evidence gathering agent/landlord')
                    {
                        decimal oldnoofdays = newCase.On_hold_Evidence_gathering_agent_landlor__c != null ? newCase.On_hold_Evidence_gathering_agent_landlor__c : 0;
                        newCase.On_hold_Evidence_gathering_agent_landlor__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if (newCase.PreviousStatus__c =='Evidence gathering tenant' || oldMap.get(newCase.Id).PreviousStatus__c =='Evidence gathering tenant')
                    {
                        decimal oldnoofdays = newCase.On_hold_Evidence_gathering_tenant__c != null ? newCase.On_hold_Evidence_gathering_tenant__c : 0;
                        newCase.On_hold_Evidence_gathering_tenant__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if (newCase.PreviousStatus__c =='Awaiting evidence review' || oldMap.get(newCase.Id).PreviousStatus__c =='Awaiting evidence review')
                    {
                        decimal oldnoofdays = newCase.On_hold_Awaiting_evidence_review__c != null ? newCase.On_hold_Awaiting_evidence_review__c : 0;
                        newCase.On_hold_Awaiting_evidence_review__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if (newCase.PreviousStatus__c =='Evidence review complete' || oldMap.get(newCase.Id).PreviousStatus__c =='Evidence review complete')
                    {
                        decimal oldnoofdays = newCase.On_hold_evidence_review_complete__c != null ? newCase.On_hold_evidence_review_complete__c : 0;
                        newCase.On_hold_evidence_review_complete__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if (newCase.PreviousStatus__c =='Adjudication' || oldMap.get(newCase.Id).PreviousStatus__c =='Adjudication')
                    {
                        decimal oldnoofdays = newCase.On_hold_adjudication__c != null ? newCase.On_hold_adjudication__c : 0;
                        
                            newCase.On_hold_adjudication__c = oldnoofdays+totalNoOfDays;                        
                    }
                   // newCase.Previous_on_hold_end_date__c = newCase.On_Hold_End_Date__c;
                        
                } 
/*
 * 
 * 
 * 
 */
            }
            
            EI_ZDCaseTriggerHandler.isExecuted = true;               
        } 
    }
    public static void handleCaseAssignmentRuleTrigger(Map<Id,Case> newMap, Map<Id,Case> oldMap){
        List<Case> casesToFireAR = new List<Case>();
        List<Case> casesToUpdateStatus = new List<Case>();
        for(Id caseId : newMap.keySet()) {
            if(oldMap.get(caseId).status != newMap.get(caseId).status /* && oldMap.get(caseId).status != 'On Hold'*/ && newMap.get(caseId).status =='Evidence review complete' )
            {

                casesToFireAR.add(newMap.get(caseId));
            } 
            
            if( (newMap.get(caseId).ownerId== System.Label.EI_ZD_QueueId || newMap.get(caseId).ownerId== System.Label.SDS_Adjudication_Queue ) &&  oldMap.get(caseId).status =='Adjudication')
            {                                      
                casesToUpdateStatus.add(new case( id=newMap.get(caseId).id, status ='Evidence review complete' ) );
            }
        }
        List<Case> cases = new List<Case>();
        for(Case c : [Select Id from Case where Id in :casesToFireAR])  {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            c.setOptions(dmo);
            cases.add(c);
        }
        if (cases.size() >0)
        {
            Database.update(cases); 
        }
        if (casesToUpdateStatus.size() >0)
        {
            Database.update(casesToUpdateStatus); 
        }
        
        
    }
    public static void handleCasePartiAssignmentRuleTrigger(Map<Id,Case> newMap, Map<Id,Case> oldMap){
        List<Case> casesToFireAR = new List<Case>();
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        for(Id caseId : newMap.keySet()) {
            if(oldMap.get(caseId).OwnerId != newMap.get(caseId).OwnerId  && newMap.get(caseId).RecordTypeId ==devRecordTypeId/*&& newMap.get(caseId).status =='Adjudication'*/ )
            {
                casesToFireAR.add(newMap.get(caseId));
            }   
        }
        List<AccountShare > sharesToCreate  = new List<AccountShare >();
        for(Case c : [Select Id,OwnerId,(select id,Account__c from Case_Participants__r) from Case where Id in :casesToFireAR])  {
            for(Case_Participant__c  cps:c.Case_Participants__r)
            {
                AccountShare cs = new AccountShare();
                cs.AccountAccessLevel = 'Edit';
                cs.AccountId = cps.Account__c;
                cs.OpportunityAccessLevel ='Read';
                cs.UserOrGroupId =c.OwnerId  ;
                sharesToCreate.add(cs);
            }
            
        }
        if(!Test.isRunningTest()){
            if (!sharesToCreate.isEmpty())
                try{
                    insert sharesToCreate;
                }
            catch(exception e)
            {}
            
        }
    }
    
    public static Date calculateNegativeWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    
   /* public static void updateDisputeItem(Map<Id,Case> newMap, Map<Id,Case> oldMap)
    {
        
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        list<Id> caseIDTenantAgree= new list<Id>();
        list<Id> caseIDLandlordAgree= new list<ID>();
        for(Case newCase : newMap.values()) {
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && newCase.Status=='Case closed - agreement reached' && oldMap.get(newCase.Id).Status !='On Hold' )
            {
                if(newCase.Claim_Agreed_By__c =='Agent/Landlord')
                {
                   caseIDLandlordAgree.add(newCase.Id);
                }
                else if(newCase.Claim_Agreed_By__c =='Tenant')
                {
                    caseIDTenantAgree.add(newCase.Id);
                }
                
            }
        }
        if(caseIDLandlordAgree.size() > 0)
        {
            list<Dispute_Item__c> disputeItem =[select id,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c,
                                                Agreed_by_Tenant__c,Agreed_by_AGLL__c
                                                from Dispute_Item__c
                                                where Dispute__c in :caseIDLandlordAgree];
            
            list<Dispute_Item__c> disputeItemToUpdate = new list<Dispute_Item__c>();
            for(Dispute_Item__c item: disputeItem)
            {
                disputeItemToUpdate.add(new Dispute_Item__c(id=item.id,Adjustment_Percentage_by_AGLL__c =item.Adjustment_Percentage_by_TT__c,
                               Agreed_by_AGLL__c =item.Agreed_by_Tenant__c ));
            }
            if(disputeItemToUpdate.size() > 0)
            {
                update disputeItemToUpdate;
            }
        }
        if(caseIDTenantAgree.size() > 0)
        {
            list<Dispute_Item__c> disputeItem =[select id,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c,
                                                Agreed_by_Tenant__c,Agreed_by_AGLL__c
                                                from Dispute_Item__c
                                                where Dispute__c in :caseIDTenantAgree];
            
            list<Dispute_Item__c> disputeItemToUpdate = new list<Dispute_Item__c>();
            for(Dispute_Item__c item: disputeItem)
            {
                disputeItemToUpdate.add(new Dispute_Item__c(id=item.id,Adjustment_Percentage_by_TT__c =item.Adjustment_Percentage_by_AGLL__c,
                               Agreed_by_Tenant__c =item.Agreed_by_AGLL__c));
            }
            if(disputeItemToUpdate.size() > 0)
            {
                update disputeItemToUpdate;
            }
        }  
    }*/
    
    public static Date calculateNegativeWorkingDaysBetweenTwoDates1(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay1(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates2(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay2(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates3(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay3(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates4(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay4(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates5(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay5(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static boolean checkifItisWorkingDay1(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static boolean checkifItisWorkingDay2(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static boolean checkifItisWorkingDay3(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static boolean checkifItisWorkingDay4(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static boolean checkifItisWorkingDay5(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates9(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay9(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static boolean checkifItisWorkingDay9(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates0(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay0(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static boolean checkifItisWorkingDay0(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates6(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay6(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static boolean checkifItisWorkingDay6(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates7(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay7(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static boolean checkifItisWorkingDay7(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    public static Date calculateNegativeWorkingDaysBetweenTwoDates8(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay8(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    public static boolean checkifItisWorkingDay8(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
      
}