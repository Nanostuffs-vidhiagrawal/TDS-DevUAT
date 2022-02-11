public without sharing class EI_ZD_HomePage {
    @AuraEnabled
    public static list<wrapperclass> getLoginUserDetails()
    {
        list<wrapperclass> wrprList = new list<wrapperclass>();
        
        user userdetails = [select id,profile.name,ContactId from user where id=:UserInfo.getUserId()];
        List<Case_Participant__c>  caseparti = [select Id,No_of_Attempt__c,Is_Lead__c,Is_Active__c,Case__c,Contact__c,
                                                Case__r.Deposit_Account_Number__r.Property__r.Postal_Code__c,Case__r.Deposit_Account_Number__r.Name,
                                                Case__r.Deposit_Account_Number__r.Property__r.Street__c,
                                                Case__r.Deposit_Account_Number__r.Property__r.City__c,Case__r.External_ID__c,
                                                Case__r.Deposit_Account_Number__r.Property__r.Country__c,Case__r.ZD_Reference_Number__c,
                                                Case__r.Deposit_Account_Number__r.End_Date__c,
                                                Case__r.Deposit_Account_Number__r.Property_Address__c,Case__r.No_of_Tenants__c,
                                                Case__r.status
                                                from Case_Participant__c 
                                                where Contact__c=:userdetails.ContactId and  case__r.status != 'New' order by createddate desc Limit 1 ];
        wrprList.add(new wrapperclass(userdetails,caseparti));
        return wrprList;
    }
    @AuraEnabled
    public static Case_Participant__c getCaseDetails(string AccessCode)
    {
        
        Case_Participant__c casedetails = [select id,Case__c,Case__r.Total_Claimed_by_Landlord__c,Case__r.Total_Claim_Amount__c,
                                           Case__r.Deposit_Account_Number__r.End_Date__c,Case__r.status,Case__r.External_ID__c,Case__r.PreviousStatus__c,
                                           Case__r.Total_Deposit__c from Case_Participant__c where Access_Code__c=:AccessCode limit 1];
        return casedetails;
    }
    @AuraEnabled
    public static string saveDisputeLine(decimal Cleaning,decimal Damage,decimal Redecoration,decimal Gardening,decimal RentArrears,
                                       decimal Other,string OtherReason,string CaseId,boolean claimExceedsFlag)
    {
        case currentStatus = [select id,Total_Claimed_by_Landlord__c from case where id=:CaseId limit 1];
        if(currentStatus.Total_Claimed_by_Landlord__c > 0)
        {
            return 'you has already responed to this claim';
        }
        else
        {
            List<Dispute_Item__c> disputeItemList = new list<Dispute_Item__c>();
            Id dipositItemId = Schema.SObjectType.Dispute_Item__c.getRecordTypeInfosByName().get('ZD Dispute Item').getRecordTypeId();
            if(Cleaning > 0)
            {
                disputeItemList.add(new Dispute_Item__c(Dispute__c=CaseId,RecordTypeId=dipositItemId, Agreed_by_AGLL__c=Cleaning, Claimed_by_Landlord__c=Cleaning,Type__c='Cleaning') );
            }
            if(Damage > 0)
            {
                disputeItemList.add(new Dispute_Item__c(Dispute__c=CaseId,RecordTypeId=dipositItemId,Agreed_by_AGLL__c=Damage, Claimed_by_Landlord__c=Damage,Type__c='Damage') );
            }
            if(Redecoration > 0)
            {
                disputeItemList.add(new Dispute_Item__c(Dispute__c=CaseId,RecordTypeId=dipositItemId,Agreed_by_AGLL__c=Redecoration, Claimed_by_Landlord__c=Redecoration,Type__c='Redecoration') );
            }
            if(Gardening > 0)
            {
                disputeItemList.add(new Dispute_Item__c(Dispute__c=CaseId,RecordTypeId=dipositItemId, Agreed_by_AGLL__c=Gardening, Claimed_by_Landlord__c=Gardening,Type__c='Gardening') );
            }
            if(RentArrears > 0)
            {
                disputeItemList.add(new Dispute_Item__c(Dispute__c=CaseId,RecordTypeId=dipositItemId, Agreed_by_AGLL__c=RentArrears, Claimed_by_Landlord__c=RentArrears,Type__c='Rent') );
            }
            if(Other > 0)
            {
                disputeItemList.add(new Dispute_Item__c(Dispute__c=CaseId,RecordTypeId=dipositItemId, Agreed_by_AGLL__c=Other, Claimed_by_Landlord__c=Other,Type__c='Other',Other_Reason__c=OtherReason) );
            }
            if(disputeItemList.size() >0)
            {
                insert disputeItemList;
            }
            CreateUserForTenant(CaseId);
            updateCaseRecord(CaseId,claimExceedsFlag);
            return 'successfully inserted';
        }
        
        //EI_ZD_EmailUtility.sendEmailByMailJet(CaseId,'Invitation to respond to agent/landlord claim');
    }
    @future 
    public static void CreateUserForTenant(String CaseID) {
        list<Case_Participant__c> caseParticipant = [select id,Contact__c,Contact__r.firstname,contact__r.lastname,contact__r.email,
                                                     contact__r.Phone,contact__r.Salutation
                                                     from Case_Participant__c
                                                     where Case__c=:CaseID and Type__c='Tenant'];
        list<user> usrToInsert = new list<user>();
        
        for(Case_Participant__c usr:caseParticipant )
        {
            User u = new User();
            String fullName = usr.Contact__r.firstname + usr.contact__r.lastname;
            if (fullName.length() >= 5){
                u.alias = fullName.substring(0, 4);
            } else{
                u.alias = fullName;
            }
            String nickname = ((usr.Contact__r.firstname != null && usr.Contact__r.firstname.length() > 0) ? usr.Contact__r.firstname.substring(0, 1) : '')+usr.Contact__r.firstname.substring(0, 1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
            u.CommunityNickname = nickname;
            u.Title = usr.Contact__r.Salutation;
            u.FirstName = usr.Contact__r.FirstName;
            u.LastName = usr.Contact__r.lastname;
            u.Username = usr.Contact__r.Email;
            u.Phone = usr.Contact__r.Phone;
            u.Email = usr.Contact__r.Email;
            u.ProfileId = [Select Id,name from profile where name = 'ZD_Tenant' limit 1].Id;
            u.TimeZoneSidKey = 'Europe/London';
            u.LocaleSidKey = 'en_GB';
            u.LanguageLocaleKey = 'en_US';
            u.ContactId = usr.Contact__c;
            u.User_Type__c='Tenant';
            u.EmailEncodingKey = 'ISO-8859-1';
            usrToInsert.add(u);
        }
        Try{
            Database.insert(usrToInsert, false);
        }
        catch(exception e)
        {
        }
        
    }
    
    // @future 
    public static void updateCaseRecord(String CaseID,boolean claimExceedsFlag) {
        EI_ZDCaseTriggerHandler.IsMailExecuted = false;
        case caseRecord = new case(id=CaseID, Status='Invitation to view the claim',Respond_Date__c=calculateWorkingDaysBetweenTwoDates(date.today(),5),Claim_exceeds_the_total_level_of_cover__c=claimExceedsFlag);
        update caseRecord;
        
        
    }
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays <= noOfDays)
        {
            
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    // Calculate working days between two dates
   
    public static Integer calculateWorkingDays(Date startDate, Date endDate)
    { 
        
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        if(startDate != endDate)
        {
            Integer noOfDaysBetween = integer.valueOf(math.abs(startDate.daysBetween(endDate)));
            Integer allWorkingDays=0;
            
            for(Integer i=0;i<=noOfDaysBetween;i++) {
                if(checkifItisWorkingDay(startDate.addDays(i),holidays)) {
                    allWorkingDays++;
                }
            }
            return allWorkingDays;
        }
        else 
        {
            if(checkifItisWorkingDay(startDate,holidays)) {
                return 1;
            }
            else
            {
                return 0;
            }
            
        }
        
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

    
    @AuraEnabled
    public static list<string> validateUser(string RecordID,string Postcode)
    {
        list<string> response = new list<string>();
        
        Case_Participant__c  PropertyPostCode = [select id,No_of_Attempt__c,case__r.status,Is_Active__c,Case__c,Case__r.Deposit_Account_Number__r.Property__r.Postal_Code__c 
                                                 from Case_Participant__c 
                                                 where id=:RecordID and case__r.status != 'closed' ];
        string finalPostcode =(Postcode.toLowerCase()).deleteWhitespace();
        string PostcodefromDB =(PropertyPostCode.Case__r.Deposit_Account_Number__r.Property__r.Postal_Code__c.toLowerCase()).deleteWhitespace();
        //Postcode.toLowerCase()
        if(PropertyPostCode.Case__r.Deposit_Account_Number__r.Property__r.Postal_Code__c != null)
        {
            if(finalPostcode !=PostcodefromDB)
            {
                
                
                if(PropertyPostCode.No_of_Attempt__c == null ||PropertyPostCode.No_of_Attempt__c == 0 )
                {
                    PropertyPostCode.No_of_Attempt__c=1;
                }
                else
                {
                    PropertyPostCode.No_of_Attempt__c = PropertyPostCode.No_of_Attempt__c+1;
                }
                if(PropertyPostCode.No_of_Attempt__c ==3 && PropertyPostCode.No_of_Attempt__c !=null )
                {
                    response.add('User Deactivate');
                    update PropertyPostCode;
                }
                else
                {
                    response.add('Postcode Incorrectly');
                    update PropertyPostCode;
                }
                
            }
            else
            {
                response.add('Postcode Correct');
                PropertyPostCode.Is_Active__c = true;
                if(PropertyPostCode.case__r.status !='Invitation to view the claim')
                {
                    PropertyPostCode.Is_Lead__c=checkLeadTenant(PropertyPostCode.Case__c,PropertyPostCode.id);
                }
                PropertyPostCode.CheckResponse__c =checkLeadTenant(PropertyPostCode.Case__c,PropertyPostCode.id);
                update PropertyPostCode;
            }
        }
        else
        {
            response.add('Postcode Not Found'); 
        }
        if(PropertyPostCode.No_of_Attempt__c == null)
        {
            response.add('0');
        }
        else
        {
            response.add(string.valueOf(PropertyPostCode.No_of_Attempt__c));
        }
        return response;
    }
    @future
    public static void deactivateuser()
    {
        user usr = new user(id=UserInfo.getUserId(),isPortalEnabled = false);
        update usr;
    }
    public static boolean  checkLeadTenant(ID caseID, string Casepartid )
    {
        boolean returnvale = true;
        for(Case_Participant__c c: [select id,No_of_Attempt__c,Is_Active__c,Is_Lead__c 
                                    from Case_Participant__c 
                                    where Case__c=:caseID  ])
        {
            if(c.Is_Lead__c)
            {
                if(c.id ==Casepartid)
                {
                    returnvale = true;
                }
                else
                {
                    returnvale = false;
                } 
            }
        }
        
        return returnvale;
    }
    
    
    public class wrapperclass
    {
        @AuraEnabled public user usr{set;get;}
        @AuraEnabled public list<Case_Participant__c> Caseparticipant{set;get;}
        public wrapperclass(user usr,List<Case_Participant__c> cp)
        {
            this.usr = usr;
            this.Caseparticipant = cp;
        }
        
    }
    
    
    
}