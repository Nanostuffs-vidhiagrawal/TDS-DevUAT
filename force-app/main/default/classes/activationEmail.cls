global without sharing class activationEmail{
  //  public String acid;
    
     public string respondDate{
    get {
       return getRespondDate();
    }
    public set;
  }
   public Decimal totalClaim{
    get {
       return getTotalclaim();
    }
    public set;
  }
   public String add{
    get {
       return getAddress();
    }
    public set;
  }
    public String recordId{get; set;}
     public String getAddress(){
         User u = [Select AccountId from user where id=: recordId limit 1];
         String acid = u.AccountId;
         Case_Participant__c casePart = [Select id,Case__r.Deposit_Account_Number__r.Property__r.Street__c,Case__r.Deposit_Account_Number__r.Property__r.City__c from Case_Participant__c where Account__c =: acid limit 1];
         
         string firstAddress = casePart.Case__r.Deposit_Account_Number__r.Property__r.Street__c +', '+casePart.Case__r.Deposit_Account_Number__r.Property__r.City__c ;
     
         return firstAddress ;
     }
  
 
     public String getRespondDate(){
         String  acid = [Select AccountId from user where id=: recordId].AccountId;
         Case_Participant__c casePart = [Select id,Case__r.Respond_Date__c from Case_Participant__c where Account__c =: acid limit 1];
         date dt =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(System.today(), 5);
   //      if(casePart.Case__r.Respond_Date__c != NULL ){
     //        dt = casePart.Case__r.Respond_Date__c;
             string mon ;
             if(dt.month()<10){
             mon = '0'+dt.month(); 
             }
              string dtstring = dt.day() + '/' + mon + '/' + dt.year();
         return dtstring ;
       
        
     }
      public Decimal getTotalclaim(){
         String  acid = [Select AccountId from user where id=: recordId].AccountId;
         Case_Participant__c casePart = [Select id,Case__r.Total_Claim_Amount__c from Case_Participant__c where Account__c =: acid limit 1];
         
         return casePart.Case__r.Total_Claim_Amount__c;
     }

}