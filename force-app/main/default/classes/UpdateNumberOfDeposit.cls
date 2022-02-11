public class UpdateNumberOfDeposit{
    
    
    public static void updateProperty(list<Deposit__c> depositList){
   // Map<Integer>
    List<Property__c> listProp = new List<Property__c>();
   /* for(Deposit__c deplist : [Select id,Property__r.Id,Property__r.NoOfDeposit__c from Deposit__c where id in: depositList]){
    Integer noDep = 0;
    noDep ++;
    Property__c prp = new Property__c(id=deplist.Property__r.Id,NoOfDeposit__c = noDep);
    listProp.add(prp );
    
    }*/
    
       for(Property__c prop : [Select id,(Select id,Active__c from Deposits__r ),NoOfDeposit__c  from Property__c where id in (Select Property__c from Deposit__c where id IN :depositList)]){
        if(prop.Deposits__r.size()>0 ){
        for(Deposit__c dep : prop.Deposits__r )
        {
            if( dep.Active__c){
             prop.NoOfDeposit__c  = String.Valueof(prop.Deposits__r.size());
            }
            else{
         prop.NoOfDeposit__c  = '0';}
        }
        listProp.add(prop);
       
      
        
        }
        
    }
    update listProp;
    }
    
}