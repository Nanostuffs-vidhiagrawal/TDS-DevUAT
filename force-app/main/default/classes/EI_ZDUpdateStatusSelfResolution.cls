global class EI_ZDUpdateStatusSelfResolution implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Status,Counter__c,AGLL_Respond_Self_resolution__c,TT_respond_Self_resolution__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Respond_Date__c,IIIrd_Working_Day_SR__c from Case where Origin= \'Zero Deposit\' and  Id= \'5008E00000Itqnf\' ';
       // String query = 'select id,Status,Counter__c,AGLL_Respond_Self_resolution__c,TT_respond_Self_resolution__c,Respond_Date__c,IIIrd_Working_Day_SR__c from Case where Origin= \'Zero Deposit\' and Status= \'Self-Resolution\' ';
        return Database.getQueryLocator(query);    
    }
    global void execute(Database.BatchableContext BC, List<Case> CaseRec){
      /*	  list<case> updatecounterlist = new list<case>();
        list<case> remMailListTT = new list<case>();
        list<case> remMailListAGLL = new list<case>();
        list<case> UpdatestatustoEvidenceGathering = new list<case>();
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
                    UpdatestatustoEvidenceGathering.add(cs);
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
                else if(cs.TT_respond_evidence_gathering__c && cs.Respond_Date__c == system.today())
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
            updateCounter(updatecounterlist);
        }
        if(remMailListTT.size() >0 )
        {
            RemindermailtoTT(remMailListTT);
        }
        if(remMailListAGLL.size() >0 )
        {
            RemindermailtoAGLL(remMailListAGLL);
        }
        
        if(UpdatestatustoEvidenceGathering.size() >0 )
        {
            updatestatusToEvidenceGathering(UpdatestatustoEvidenceGathering);
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
        */
    }
    global void finish(Database.BatchableContext BC) {
        
    }
   /* public static void updateCounter(List<Case> CaseRec)
    {
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            Date datetoupdate =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
            casetoupdate.add(new Case(id = cs.id,Counter__c =2,Respond_Date__c = datetoupdate,IIIrd_Working_Day_SR__c =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 3) ));
        }
        EI_ZD_EmailUtility.sendEmailByMailJetSelfresolution(CaseRec,'Invitaion To Self-Resolution' );
        update casetoupdate;
    }
    public static void RemindermailtoTT(List<Case> CaseRec)
    {
        
        EI_ZD_EmailUtility.sendReminderEmailTT(CaseRec,'Reminder To Self-Resolution' );
    }
    public static void RemindermailtoAGLL(List<Case> CaseRec)
    {
        
        EI_ZD_EmailUtility.sendReminderEmailAGLL(CaseRec,'Reminder To Self-Resolution' );
    }
    public static void updatestatusToCloseBoth(List<Case> CaseRec)
    {
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Case closed - no response from either party',self_resolution_batch_processed__c =true,Close_Reason__c='No Response From Either Party'));
        }
        EI_ZD_EmailUtility.sendEmailCaseCloseBothNotRespond(CaseRec,'Case Close Both Parties Not Responded' );
        update casetoupdate;
    }
    public static void updatestatusToCloseAGLL(List<Case> CaseRec)
    {
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Case closed - no response from agent/landlord',self_resolution_batch_processed__c =true,Close_Reason__c='No Response From Agent/Landlord'));
        }
        EI_ZD_EmailUtility.sendEmailCaseCloseAGLLNotRespond(CaseRec,'Case Close AGLL Not Responded' );
        update casetoupdate;
    }
    public static void updatestatusToEvidenceGathering(List<Case> CaseRec)
    {
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Evidence gathering agent/landlord'));
        }
        EI_ZD_EmailUtility.sendEmailInviteEvidanceGathering(CaseRec,'Invitation to submit evidence' );
        update casetoupdate;
    }
    
    
    public static void updatestatusToTTEvidenceGathering(List<Case> CaseRec)
    {
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Evidence gathering tenant'));
        }
        update casetoupdate;
    }
    
    public static void RemindermailtoAGLLEvidence(List<Case> CaseRec)
    {
        
        EI_ZD_EmailUtility.sendReminderEmailAGLL(CaseRec,'Reminder to evidence gathering' );
    }
    
    public static void updatestatusToCloseAGLLEvidence(List<Case> CaseRec)
    {
        list<Case> casetoupdate  = new list<Case>();
        for(case cs :CaseRec)
        {
            casetoupdate.add(new Case(id = cs.id,status='Case closed - no response from agent/landlord',Evidence_gathering_batch_processed__c = true,Close_Reason__c='No Response From Agent/Landlord'));
        }
        EI_ZD_EmailUtility.sendEmailCaseCloseAGLLNotRespond(CaseRec,'Case Close AGLL Not Responded' );
        update casetoupdate;
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
    
    public static void RemindermailtoTTEvidence(List<Case> CaseRec)
    {
        
       EI_ZD_EmailUtility.sendReminderEmailTT(CaseRec,'Reminder mail evidence gathering' );
    }*/
    
    public static void mailtoAllParties(List<Case> CaseRec)
    {
        for(Case cs :CaseRec)
        {
            cs.IIIrd_Working_Day_SR__c = EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
        }
        /*
         * 
         * will Send email to all parties with updated status
         * 
         */
       
        update CaseRec;
    }
}