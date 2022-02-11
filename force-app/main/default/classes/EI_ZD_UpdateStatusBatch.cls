global class EI_ZD_UpdateStatusBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global  List<EI_ZD_EmailUtility.saveMsgWrapper> smwListFinal = new List<EI_ZD_EmailUtility.saveMsgWrapper>(); 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query ;
        if(test.isRunningTest()){
            
            query='select id,Status,Counter__c,ZD_Reference_Number__c,TT_Respond_Invitation_to_view_the_claim__c,Total_Claim_Amount__c,AGLL_Respond_Self_resolution__c,Tenancy_Property_Address__c,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,(select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), (select id,Contact__r.Email,Contact__r.FirstName,Type__c,Access_Code__c from case_participants__r),TT_respond_Self_resolution__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Respond_Date__c,IIIrd_Working_Day_SR__c from Case';
            List<Case> c =database.query(query);
        }
        else
            query = 'select id,Status,Counter__c,ZD_Reference_Number__c,TT_Respond_Invitation_to_view_the_claim__c,Total_Claim_Amount__c,AGLL_Respond_Self_resolution__c,Tenancy_Property_Address__c,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,(select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), (select id,Contact__r.Email,Contact__r.FirstName,Type__c,Access_Code__c from case_participants__r),TT_respond_Self_resolution__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Respond_Date__c,IIIrd_Working_Day_SR__c from Case where Origin= \'Zero Deposit\' and  Id= \'5008E00000JKRQP\' ';
        // query = 'select id,Status,Counter__c,ZD_Reference_Number__c,TT_Respond_Invitation_to_view_the_claim__c,Total_Claim_Amount__c,AGLL_Respond_Self_resolution__c,Tenancy_Property_Address__c,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,(select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), (select id,Contact__r.Email,Contact__r.FirstName,Type__c,Access_Code__c from case_participants__r),TT_respond_Self_resolution__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Respond_Date__c,IIIrd_Working_Day_SR__c from Case where Origin= \'Zero Deposit\' ';
        return Database.getQueryLocator(query);    
    }
    global void execute(Database.BatchableContext BC, List<Case> CaseRec){
        list<case> updatecounterlist = new list<case>();
        list<case> remMailListTT = new list<case>();
        list<case> remMailListAGLL = new list<case>();
        list<case> UpdatestatustoEvidenceGathering = new list<case>();
        list<case> UpdatestatustoEvidenceGatheringFromInitial = new list<case>();
        list<case> UpdatestatustoCloseAGLL = new list<case>();
        list<case> UpdatestatustoCloseBoth = new list<case>();
        
        
        list<case> remMailListAGLLEvidence = new list<case>();        
        list<case> UpdatestatustoCloseAGLLEvidence = new list<case>();
        list<case> UpdatestatustoTTEvidence = new list<case>();
        
        list<case> remMailListTTEvidence = new list<case>();
        list<case> UpdatestatusAwaitingEvidenceReview = new list<case>();  
        
        list<case> mailAllPartiesAdjudication = new list<case>();
        
        for(Case cs : CaseRec)
        {
            if(cs.Status=='Invitation to view the claim')
            {
                if((!cs.TT_Respond_Invitation_to_view_the_claim__c) &&  cs.Respond_Date__c == system.today())
                {
                   // UpdatestatustoEvidenceGathering.add(cs);
                   UpdatestatustoEvidenceGatheringFromInitial.add(cs);
                }
            }
            else if(cs.Status=='Self-Resolution')
            {
                if(cs.Counter__c==1 && (cs.AGLL_Respond_Self_resolution__c==false ||cs.TT_respond_Self_resolution__c ==false ) && cs.Respond_Date__c == system.today() )
                {
                    updatecounterlist.add(cs);
                }
                if(cs.AGLL_Respond_Self_resolution__c==false && cs.IIIrd_Working_Day_SR__c == system.today())
                {
                    remMailListAGLL.add(cs);
                }
                if(cs.TT_respond_Self_resolution__c==false && cs.IIIrd_Working_Day_SR__c == system.today())
                {
                    remMailListTT.add(cs); 
                }
                
                if(cs.Respond_Date__c == system.today())
                {
                    if(cs.Counter__c==1 && cs.TT_respond_Self_resolution__c==true && cs.AGLL_Respond_Self_resolution__c ==true ) 
                    {
                        UpdatestatustoEvidenceGathering.add(cs);
                    }
                    else if(cs.Counter__c==2 && cs.AGLL_Respond_Self_resolution__c ==false && cs.TT_respond_Self_resolution__c==false )
                    {
                        UpdatestatustoCloseBoth.add(cs);
                    }
                    else if(cs.Counter__c==2 && cs.AGLL_Respond_Self_resolution__c ==false)
                    {
                        UpdatestatustoCloseAGLL.add(cs);
                    }
                    else if(cs.AGLL_Respond_Self_resolution__c ==true)
                    {
                        UpdatestatustoEvidenceGathering.add(cs);
                    }
                } 
            }
            else if(cs.Status=='Evidence gathering agent/landlord')
            {
                
                if(cs.AGLL_Respond_Evidance_Gathering__c==false && cs.IIIrd_Working_Day_SR__c == system.today())
                {
                    
                    remMailListAGLLEvidence.add(cs);
                }
                else if(cs.AGLL_Respond_Evidance_Gathering__c==false && cs.Respond_Date__c == system.today())
                {
                    UpdatestatustoCloseAGLLEvidence.add(cs);
                }
                else if(cs.AGLL_Respond_Evidance_Gathering__c && cs.Respond_Date__c == system.today())
                {
                    UpdatestatustoTTEvidence.add(cs);
                }
                
            }
            else if(cs.Status=='Evidence gathering tenant')
            {
                if(! cs.TT_respond_evidence_gathering__c && cs.IIIrd_Working_Day_SR__c == system.today())
                {
                    remMailListTTEvidence.add(cs);
                }
                else if(/*cs.TT_respond_evidence_gathering__c && */cs.Respond_Date__c == system.today())
                {
                    UpdatestatusAwaitingEvidenceReview.add(cs);
                }
                
            }
            else if(cs.Status=='Evidence review complete' || cs.Status=='Adjudication' )
            {
                if(cs.IIIrd_Working_Day_SR__c == system.today())
                {
                    mailAllPartiesAdjudication.add(cs);
                }
            }
            
        }
        if(updatecounterlist.size() >0 )
        {
            smwListFInal.addAll(updateCounter(updatecounterlist));
        }
        if(remMailListTT.size() >0 )
        {
            smwListFInal.addAll(RemindermailtoTT(remMailListTT));
        }
        /* if(remMailListAGLL.size() >0 )
{
RemindermailtoTT(remMailListAGLL);
}*/
        
        if(UpdatestatustoEvidenceGathering.size() >0 )
        {
            updatestatusToEvidenceGathering(UpdatestatustoEvidenceGathering);
        }
        if(UpdatestatustoEvidenceGatheringFromInitial.size() >0 )
        {
            updatestatusToEvidenceGatheringInitila(UpdatestatustoEvidenceGatheringFromInitial);
        }
        if(UpdatestatustoCloseAGLL.size() >0 )
        {
            updatestatusToCloseAGLL(UpdatestatustoCloseAGLL);
        }
        if(UpdatestatustoCloseBoth.size() >0 )
        {
            updatestatusToCloseBoth(UpdatestatustoCloseBoth);
        }
        
        
        
        //=== Evidence gathering AGLL ====
        
        
        
        if(remMailListAGLLEvidence.size() >0 )
        {
            RemindermailtoAGLLEvidence(remMailListAGLLEvidence);
        }
        if(UpdatestatustoCloseAGLLEvidence.size() >0 )
        {
            updatestatusToCloseAGLLEvidence(UpdatestatustoCloseAGLLEvidence);
        }
        if(UpdatestatustoTTEvidence.size() >0 )
        {
            updatestatusToTTEvidenceGathering(UpdatestatustoTTEvidence);
        }
        
        //=== Evidence gathering TT ==== 
        
        if(remMailListTTEvidence.size() >0 )
        {
            RemindermailtoTTEvidence(remMailListTTEvidence);
        }
        if(UpdatestatusAwaitingEvidenceReview.size() >0 )
        {
            updatestatusToAwaitingEvidence(UpdatestatusAwaitingEvidenceReview);
        }
        // ===== Adjudication start ====
        
        if(mailAllPartiesAdjudication.size() >0 )
        {
            mailtoAllParties(mailAllPartiesAdjudication);
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        EI_ZD_EmailUtility.saveMessageDetailsBatch(smwListFinal);
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> updateCounter(List<Case> CaseRec)
    {
        List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            Date datetoupdate =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
            casetoupdate.add(new Case(id = cs.id,Counter__c =2,Respond_Date__c = datetoupdate,IIIrd_Working_Day_SR__c =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 3) ));
            
            String floa ='';
            String sloa ='';
            String postcode='';
            if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
            }
            list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
            list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
            Map<String,String> var = new Map<String,String>();
            var.put('floa',floa);
            var.put('sloa',sloa);
            var.put('postcode',postcode);
            if(datetoupdate != null){
                String todaysDateStr = datetoupdate.day() + '/' + datetoupdate.month() + '/' + datetoupdate.year();
                var.put('date',todaysDateStr);
            }
            for(Dispute_Item__c di : cs.Dispute_Items__r){
                var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
            }
            list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
            
            for(case_participant__c cp : cs.case_participants__r){
                
                if(cp.type__c == 'Tenant'){
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    tenantList.add(rec);
                }
                else {
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id,null,label.EI_ZD_AGLLLoginURL+cp.Access_Code__c,'Your Claim');
                    agentList.add(rec);
                }
                
            }
            if(cs.Tenancy_Property_Address__c!=null)
                var.put('propaddress',cs.Tenancy_Property_Address__c);
            if(cs.Tenancy_Property_Address__c!=null)
                var.put('guaranteenum',cs.ZD_Reference_Number__c);
            if(cs.Total_Claim_Amount__c!=null)
                var.put('totalclaim',cs.Total_Claim_Amount__c+'');
            
            //EI_ZD_EmailUtility.saveMsgWrapper EI_ZD_EmailUtility.saveMsgWrapper smv = new EI_ZD_EmailUtility.saveMsgWrapper();
            if(cs.AGLL_Respond_Self_resolution__c==false && cs.TT_respond_Self_resolution__c ==false)
            {
                if(tenantList.size()>0){
                    EI_ZD_EmailUtility.saveMsgWrapper smv=  EI_ZD_EmailUtility.sendEmailNew('Opportunity to Reach Agreement on Claim at '+floa +', '+sloa, JSON.Serialize(tenantList),var,'ZP2AC6_2TT','mailJetZD');
                    smwList.add(smv);
                }
                if(agentList.size()>0)  {
                    EI_ZD_EmailUtility.saveMsgWrapper smv = EI_ZD_EmailUtility.sendEmailNew('Respond by '+datetoupdate.day() + '/' + datetoupdate.month() + '/' + datetoupdate.year()+'  to Avoid Your Claim Being Closed - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP2AC6_2AGLL','mailJetZD');
                    smwList.add(smv);
                } 
            }
            else if(cs.AGLL_Respond_Self_resolution__c==false)
            {
                if(agentList.size()>0)  {
                    EI_ZD_EmailUtility.saveMsgWrapper smv = EI_ZD_EmailUtility.sendEmailNew('Respond by '+datetoupdate.day() + '/' + datetoupdate.month() + '/' + datetoupdate.year()+'  to Avoid Your Claim Being Closed - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP2AC6_2AGLL','mailJetZD');
                    smwList.add(smv);
                }                 
            }
            else
            {
                if(tenantList.size()>0){
                    EI_ZD_EmailUtility.saveMsgWrapper smv=  EI_ZD_EmailUtility.sendEmailNew('Opportunity to Reach Agreement on Claim at '+floa +', '+sloa, JSON.Serialize(tenantList),var,'ZP2AC6_2TT','mailJetZD');
                    smwList.add(smv);
                }
                
            }
            
            
            //                EI_ZD_EmailUtility.sendEmailNew('Respond by '+datetoupdate.year() + '-' + datetoupdate.month() + '-' + datetoupdate.day()+'  to Avoid Your Claim Being Closed - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP2AC6_2AGLL','mailJetZD');
        }
        //  EI_ZD_EmailUtility.sendEmailByMailJetSelfresolution(CaseRec,'Invitaion To Self-Resolution' ); // Zp-2, Ac-6.1
        update casetoupdate;
        return smwList;
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> RemindermailtoTT(List<Case> CaseRec)
    {
        List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
        for( case oCase : CaseRec){
            String floa ='';
            String sloa ='';
            String postcode='';
            list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
            list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
            Map<String,String> var = new Map<String,String>();
            if(oCase.Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=oCase.Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(oCase.Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=oCase.Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(oCase.Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=oCase.Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
            }
            var.put('floa',floa);
            var.put('sloa',sloa);
            var.put('postcode',postcode);
            if(oCase.Respond_Date__c != null){
                String todaysDateStr = oCase.Respond_Date__c.day() + '/' + oCase.Respond_Date__c.month() + '/' + oCase.Respond_Date__c.year();
                var.put('date',todaysDateStr);
            }
            for(Dispute_Item__c di : oCase.Dispute_Items__r){
                var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
            }
            list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
            
            for(case_participant__c cp : oCase.case_participants__r){
                
                if(cp.type__c == 'Tenant'){
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,oCase.Id,null,label.EI_ZD_LoginURL,'Claim Account');
                    tenantList.add(rec);
                }
                else {
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,oCase.Id,null,label.EI_ZD_AGLLLoginURL+cp.Access_Code__c,'Your Claim');
                    agentList.add(rec);
                }
                
            }
            if(oCase.Tenancy_Property_Address__c!=null)
                var.put('propaddress',oCase.Tenancy_Property_Address__c);
            if(oCase.Tenancy_Property_Address__c!=null)
                var.put('guaranteenum',oCase.ZD_Reference_Number__c);
            if(oCase.Total_Claim_Amount__c!=null)
                var.put('totalclaim',oCase.Total_Claim_Amount__c+'');
            
            
            if(tenantList.size()>0){
                EI_ZD_EmailUtility.saveMsgWrapper smv =   EI_ZD_EmailUtility.sendEmailNew('Reminder - Claim Response Still Required - '+floa +', '+sloa, JSON.Serialize(tenantList),var,'ZP2AC13TT','mailJetZD');
                smwList.add(smv);
            }
            if(agentList.size()>0)  
            {       
                EI_ZD_EmailUtility.saveMsgWrapper smv =  EI_ZD_EmailUtility.sendEmailNew('Reminder: Respond by '+oCase.Respond_Date__c.day() + '/' + oCase.Respond_Date__c.month() + '/' + oCase.Respond_Date__c.year()+' to avoid claim closure - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP2AC13AGLL','mailJetZD');
                smwList.add(smv);
                // EI_ZD_EmailUtility.sendEmailNew('Reminder: Respond by '+oCase.Respond_Date__c.day() + '/' + oCase.Respond_Date__c.month() + '/' + oCase.Respond_Date__c.year()+' to avoid claim closure - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP2AC13AGLL','mailJetZD');
            }
        }
        return smwList;
        // EI_ZD_EmailUtility.sendReminderEmailTT(CaseRec,'Reminder To Self-Resolution' ); // ZP-2 Ac-13
    }
    /*public static void RemindermailtoAGLL(List<Case> CaseRec)
{

EI_ZD_EmailUtility.sendReminderEmailAGLL(CaseRec,'Reminder To Self-Resolution' ); //ZP2-Ac13
}*/
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> updatestatusToCloseBoth(List<Case> CaseRec)
    {
        List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
        
        list<Case> casetoupdate  = new list<Case>();
        
        
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Case closed - no response from either party',self_resolution_batch_processed__c =true,Close_Reason__c='No Response From Either Party'));
            String floa ='';
            String sloa ='';
            String postcode='';
            list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
            list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
            Map<String,String> var = new Map<String,String>();
            if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
            }
            var.put('floa',floa);
            var.put('sloa',sloa);
            var.put('postcode',postcode);
            
            
            for(Dispute_Item__c di : cs.Dispute_Items__r){
                var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
            }
            list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
            
            for(case_participant__c cp : cs.case_participants__r){
                
                if(cp.type__c == 'Tenant'){
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    tenantList.add(rec);
                }
                else {
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    agentList.add(rec);
                }
                
            }
            
            if(tenantList.size()>0){
                EI_ZD_EmailUtility.saveMsgWrapper smv =    EI_ZD_EmailUtility.sendEmailNew('Claim Closed - '+floa +', '+sloa, JSON.Serialize(tenantList),var,'ZP2AC11TT','mailJetZD');
                smwList.add(smv);
            }if(agentList.size()>0)  {
                EI_ZD_EmailUtility.saveMsgWrapper smv =    EI_ZD_EmailUtility.sendEmailNew('Claim Closed - Failure to Respond - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP2AC11AGLL','mailJetZD');
                
                smwList.add(smv);
                
            }
        }
        update casetoupdate;
        return smwList;
        //EI_ZD_EmailUtility.sendEmailCaseCloseBothNotRespond(CaseRec,'Case Close Both Parties Not Responded' ); //ZP-2 Ac-11
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> updatestatusToCloseAGLL(List<Case> CaseRec)
    {
        List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
        
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Case closed - no response from agent/landlord',self_resolution_batch_processed__c =true,Close_Reason__c='No Response From Agent/Landlord'));
        }
        
        for(case cs :CaseRec)
        {
            
            String floa ='';
            String sloa ='';
            String postcode='';
            list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
            list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
            if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
            }
            Map<String,String> var = new Map<String,String>();
            var.put('floa',floa);
            var.put('sloa',sloa);
            var.put('postcode',postcode);
            
            
            for(Dispute_Item__c di : cs.Dispute_Items__r){
                var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
            }
            list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
            
            for(case_participant__c cp : cs.case_participants__r){
                
                if(cp.type__c == 'Tenant'){
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    tenantList.add(rec);
                }
                else {
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    agentList.add(rec);
                }
                
            }
            
            if(tenantList.size()>0){
                EI_ZD_EmailUtility.saveMsgWrapper smv = EI_ZD_EmailUtility.sendEmailNew('Claim Closed - '+floa +', '+sloa, JSON.Serialize(tenantList),var,'ZP2AC9TT','mailJetZD');
                smwList.add(smv);
                
            }if(agentList.size()>0)  {
                EI_ZD_EmailUtility.saveMsgWrapper smv =    EI_ZD_EmailUtility.sendEmailNew('Claim Closed - Failure to Respond - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP2AC9AGLL','mailJetZD');
                smwList.add(smv);
                
            }
            //EI_ZD_EmailUtility.sendEmailNew('Claim Closed - Failure to Respond - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP2AC9AGLL','mailJetZD');
            
        }
        // EI_ZD_EmailUtility.sendEmailCaseCloseAGLLNotRespond(CaseRec,'Case Close AGLL Not Responded' ); // ZP-2 Ac-9
        update casetoupdate;
        return smwList;
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> updatestatusToEvidenceGathering(List<Case> CaseRec)
    {
        List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
        
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Evidence gathering agent/landlord'));
            
            String floa ='';
            String sloa ='';
            String postcode='';
            if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
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
                var.put('deadlinedate',todaysDateStr);
            }
            
            for(Dispute_Item__c di : cs.Dispute_Items__r){
                var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
            }
            list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
            
            for(case_participant__c cp : cs.case_participants__r){
                
                if(cp.type__c == 'Tenant'){
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    tenantList.add(rec);
                }
                else {
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    agentList.add(rec);
                }
                
            }
            
            if(tenantList.size()>0){
                EI_ZD_EmailUtility.saveMsgWrapper smv =    EI_ZD_EmailUtility.sendEmailNew('Evidence Requested From Your Agent/Landlord - We Will Notify You of Next Action', JSON.Serialize(tenantList),var,'ZP2AC8TT','mailJetZD');
                smwList.add(smv);
                
            }
            if(agentList.size()>0)  {
                EI_ZD_EmailUtility.saveMsgWrapper smv =EI_ZD_EmailUtility.sendEmailNew('Provide Evidence Now to Support Claim - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP2AC8AGLL','mailJetZD');
                smwList.add(smv);
                
            }
            // EI_ZD_EmailUtility.sendEmailNew('Provide Evidence Now to Support Claim - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP2AC8AGLL','mailJetZD');
            
        }
        //EI_ZD_EmailUtility.sendEmailInviteEvidanceGathering(CaseRec,'Invitation to submit evidence' ); // ZD-2 ,Ac-8
        update casetoupdate;
        return smwList;
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> updatestatusToEvidenceGatheringInitila(List<Case> CaseRec)
    {
        List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
        
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Evidence gathering agent/landlord'));
            
            String floa ='';
            String sloa ='';
            String postcode='';
            if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
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
                var.put('deadlinedate',todaysDateStr);
            }
                                
 var.put('bulletlist','<ul style="color: #55575d;font-family: arial;font-size: 13px;line-height: 22px;"> <li>   A copy of the tenancy agreement signed by all parties</li> <li>If you are claiming for rent, then a rent statement</li> <li>If you are claiming for anything else: <ul> <li>Check in and check out reports, or other evidence that shows the state of the property at the start and end of the tenancy (if you do not have a check in or check out report, then we need photographs that are clearly dated); and</li> <li>Evidence that explains the size of the financial loss you are claiming for (for example, invoices or receipts for work or purchases)</li> </ul> </li> </ul>');
                
            
            for(Dispute_Item__c di : cs.Dispute_Items__r){
                var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
            }
            list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
            
            for(case_participant__c cp : cs.case_participants__r){
                
                if(cp.type__c == 'Tenant'){
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    tenantList.add(rec);
                }
                else {
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    agentList.add(rec);
                }
                
            }
            
            if(tenantList.size()>0){
                EI_ZD_EmailUtility.saveMsgWrapper smv =    EI_ZD_EmailUtility.sendEmailNew('Evidence Requested From Your Agent/Landlord - We Will Notify You of Next Action', JSON.Serialize(tenantList),var,'ZP1AC13_TT','mailJetZD');
                smwList.add(smv);
                
            }
            if(agentList.size()>0)  {
                EI_ZD_EmailUtility.saveMsgWrapper smv =EI_ZD_EmailUtility.sendEmailNew('Evidence Required to Progress Your Claim - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP1AC13_AGLL','mailJetZD');
                smwList.add(smv);
                
            }
            // EI_ZD_EmailUtility.sendEmailNew('Provide Evidence Now to Support Claim - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP2AC8AGLL','mailJetZD');
            
        }
        //EI_ZD_EmailUtility.sendEmailInviteEvidanceGathering(CaseRec,'Invitation to submit evidence' ); // ZD-2 ,Ac-8
        update casetoupdate;
        return smwList;
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> updatestatusToTTEvidenceGathering(List<Case> CaseRec)
    { 
        List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
        
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Evidence gathering tenant')); // ZP-5 Ac-19
            
            String floa ='';
            String sloa ='';
            String postcode='';
            if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
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
            
            for(Dispute_Item__c di : cs.Dispute_Items__r){
                var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
            }
            list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
            
            for(case_participant__c cp : cs.case_participants__r){
                
                if(cp.type__c == 'Tenant'){
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    tenantList.add(rec);
                }
                else {
                    EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                    agentList.add(rec);
                }
                
            }
            
            if(tenantList.size()>0){
                
                EI_ZD_EmailUtility.saveMsgWrapper smv =   EI_ZD_EmailUtility.sendEmailNew('Provide Evidence Now - Ensure Amount You Owe is Fair and Correct', JSON.Serialize(tenantList),var,'ZP5AC19TT','mailJetZD');
                smwList.add(smv);
                
            }
            if(agentList.size()>0)  {
                
                EI_ZD_EmailUtility.saveMsgWrapper smv = EI_ZD_EmailUtility.sendEmailNew('Thank You for Your Evidence - Awaiting Tenant Response - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP5AC19AGLL','mailJetZD');
                smwList.add(smv);
                
            }
            //  EI_ZD_EmailUtility.sendEmailNew('Thank You for Your Evidence - Awaiting Tenant Response - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP5AC19AGLL','mailJetZD');
            
        }
        update casetoupdate;
        return smwList;
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> RemindermailtoAGLLEvidence(List<Case> CaseRec)
    { List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
     
     
     for(case cs : CaseRec){ 
         String floa ='';
         String sloa ='';
         String postcode='';
         if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
             sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
             
         }
         if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
             floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
             
         }
         if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
             postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
             
         }
         list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
         list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
         Map<String,String> var = new Map<String,String>();
         var.put('floa',floa);
         var.put('sloa',sloa);
         var.put('postcode',postcode);
         String todaysDateStr='';
         if(cs.Respond_Date__c != null){
             todaysDateStr = cs.Respond_Date__c.Day() + '/' + cs.Respond_Date__c.month() + '/' + cs.Respond_Date__c.year();
             var.put('date',todaysDateStr);
             
         }
         
         for(Dispute_Item__c di : cs.Dispute_Items__r){
             var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
         }
         list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
         
         for(case_participant__c cp : cs.case_participants__r){
             
             if(cp.type__c == 'Tenant'){
                 EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id,null,label.EI_ZD_LoginURL,'Claim Account');
                 tenantList.add(rec);
             }
             else {
                 EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id,null,label.EI_ZD_AGLLLoginURL+cp.Access_Code__c,'Your Claim');
                 agentList.add(rec);
             }
             
         }
         
         /* if(tenantList.size()>0)
EI_ZD_EmailUtility.sendEmailNew('Evidence Requested From Your Agent/Landlord - We Will Notify You of Next Action', JSON.Serialize(tenantList),var,'ZP5AC1TT','mailJetZD');
*/  if(agentList.size()>0)  {
    EI_ZD_EmailUtility.saveMsgWrapper smv = EI_ZD_EmailUtility.sendEmailNew('Reminder: Provide Evidence by '+todaysDateStr+' Or Claim Will be Closed -'+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP5AC1_3AGLL','mailJetZD');
    smwList.add(smv);
    
}
         //EI_ZD_EmailUtility.sendEmailNew('Provide Evidence Now to Support Claim - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP5AC1AGLL','mailJetZD');
         
     }
     return smwList;
     // EI_ZD_EmailUtility.sendReminderEmailAGLL(CaseRec,'Reminder to evidence gathering' ); // ZP-5, Ac-1.2
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> updatestatusToCloseAGLLEvidence(List<Case> CaseRec)
    { List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
     
     list<Case> casetoupdate  = new list<Case>();
     for(case cs :CaseRec)
     {
         
         
         String floa ='';
         String sloa ='';
         String postcode='';
         if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
             sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
             
         }
         if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
             floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
             
         }
         if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
             postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
             
         }
         list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
         list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
         Map<String,String> var = new Map<String,String>();
         var.put('floa',floa);
         var.put('sloa',sloa);
         var.put('postcode',postcode);
         
         
         list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
         
         for(case_participant__c cp : cs.case_participants__r){
             
             if(cp.type__c == 'Tenant'){
                 EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                 tenantList.add(rec);
             }
             else {
                 EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                 agentList.add(rec);
             }
             
         }
         if(cs.Tenancy_Property_Address__c!=null)
             var.put('propaddress',cs.Tenancy_Property_Address__c);
         if(cs.Tenancy_Property_Address__c!=null)
             var.put('guaranteenum',cs.ZD_Reference_Number__c);
         if(cs.Total_Claim_Amount__c!=null)
             var.put('totalclaim',cs.Total_Claim_Amount__c+'');
         
         
         if(tenantList.size()>0){
             EI_ZD_EmailUtility.saveMsgWrapper smv = EI_ZD_EmailUtility.sendEmailNew('Claim Closed - '+floa +', '+sloa, JSON.Serialize(tenantList),var,'ZP5AC1_4TT','mailJetZD');
             smwList.add(smv);
             
         }
         if(agentList.size()>0)  {
             EI_ZD_EmailUtility.saveMsgWrapper smv =  EI_ZD_EmailUtility.sendEmailNew('Claim Closed - Failure to Provide Evidence - '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP5AC1_4AGLL','mailJetZD');
             smwList.add(smv);
         }
         //EI_ZD_EmailUtility.sendEmailNew('Claim Closed - Failure to Provide Evidence - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP5AC1_4AGLL','mailJetZD');
         
         
         
         
         casetoupdate.add(new Case(id = cs.id,status='Case closed - no response from agent/landlord',Evidence_gathering_batch_processed__c = true,Close_Reason__c='No Response From Agent/Landlord'));
     }
     // EI_ZD_EmailUtility.sendEmailCaseCloseAGLLNotRespond(CaseRec,'Case Close AGLL Not Responded' ); // ZP-5, Ac-1.3
     update casetoupdate;
     return smwList;
    }
    public static void updatestatusToAwaitingEvidence(List<Case> CaseRec)
    { 
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Awaiting Evidence Review'));
        }
        update casetoupdate;
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> RemindermailtoTTEvidence(List<Case> CaseRec)
    {  List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
     
     for(case cs :CaseRec)
     {
         String floa ='';
         String sloa ='';
         String postcode='';
         list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
         list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
         Map<String,String> var = new Map<String,String>();
         if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
             sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
             
         }
         if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
             floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
             
         }
         if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
             postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
             
         }
         var.put('floa',floa);
         var.put('sloa',sloa);
         var.put('postcode',postcode);
         String todaysDateStr='';
         if(cs.Respond_Date__c != null){
             todaysDateStr =  cs.Respond_Date__c.Day() + '/' + cs.Respond_Date__c.month() + '/' + cs.Respond_Date__c.year();
             var.put('date',todaysDateStr);
             
         }
         
         for(Dispute_Item__c di : cs.Dispute_Items__r){
             var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
         }
         list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
         
         for(case_participant__c cp : cs.case_participants__r){
             
             if(cp.type__c == 'Tenant'){
                 EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id,null,label.EI_ZD_LoginURL,'Claim Account');
                 tenantList.add(rec);
             }
             /*  else {
EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
agentList.add(rec);
}*/
             
         }
         
         if(tenantList.size()>0){
             EI_ZD_EmailUtility.saveMsgWrapper smv =  EI_ZD_EmailUtility.sendEmailNew('Reminder - Provide Evidence by '+todaysDateStr+ ' Or Amount Owed Will be Decided Without You', JSON.Serialize(tenantList),var,'ZP19AC2_1TT','mailJetZD');
             smwList.add(smv);
             
         }/*if(agentList.size()>0)  
EI_ZD_EmailUtility.sendEmailNew('Thank You for Your Evidence - Awaiting Tenant Response - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP5AC19AGLL','mailJetZD');
*/
     }
     return smwList;
     //  EI_ZD_EmailUtility.sendReminderEmailTT(CaseRec,'Reminder mail evidence gathering' ); //Zp-19 Ac-2.1
    }
    public static List<EI_ZD_EmailUtility.saveMsgWrapper> mailtoAllParties(List<Case> CaseRec)
    {
        List<EI_ZD_EmailUtility.saveMsgWrapper> smwList = new List<EI_ZD_EmailUtility.saveMsgWrapper>();
        
        for(Case cs :CaseRec)
        {
            cs.IIIrd_Working_Day_SR__c = EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
            String floa ='';
            String sloa ='';
            String postcode='';
            list<EI_ZD_EmailUtility.recipient> recList = new list<EI_ZD_EmailUtility.recipient>();
            if(cs.Deposit_Account_Number__r.Property__r.City__c != null){
                sloa=cs.Deposit_Account_Number__r.Property__r.City__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                floa=cs.Deposit_Account_Number__r.Property__r.Street__c;
                
            }
            if(cs.Deposit_Account_Number__r.Property__r.Street__c != null){
                postcode=cs.Deposit_Account_Number__r.Property__r.Postal_Code__c;
                
            }
            Map<String,String> var = new Map<String,String>();
            var.put('floa',floa);
            var.put('sloa',sloa);
            var.put('postcode',postcode);
            var.put('user',cs.Owner.Name);
            var.put('guaranteenum',cs.ZD_Reference_Number__c);
            String todaysDateStr='';
            //if(cs.Respond_Date__c != null){
            todaysDateStr = system.today().day() + '/' + system.today().month() + '/' + system.today().year();
            var.put('date',todaysDateStr);
            
            
            
            for(Dispute_Item__c di : cs.Dispute_Items__r){
                var.put(di.Type__c.toLowerCase(),di.Claimed_by_Landlord__c+'');
            }
            list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
            
            for(case_participant__c cp : cs.case_participants__r){
                EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.Id);
                recList.add(rec);
                
            }
            
            if(recList.size()>0){
                EI_ZD_EmailUtility.saveMsgWrapper smv =  EI_ZD_EmailUtility.sendEmailNew('Case update - '+floa, JSON.Serialize(recList),var,'ZP7AC1ALL','mailJetZD');
                smwList.add(smv);
            }
            /*if(agentList.size()>0)  
EI_ZD_EmailUtility.sendEmailNew('Thank You for Your Evidence - Awaiting Tenant Response - '+floa +' '+sloa, JSON.Serialize(agentList),var,'ZP5AC19AGLL','mailJetZD');
*/
        }
        
        
        /*
* 
* will Send email to all parties with updated status   Zp-7, AC-1
* 
*/
        
        update CaseRec;
        return smwList;
    }
}