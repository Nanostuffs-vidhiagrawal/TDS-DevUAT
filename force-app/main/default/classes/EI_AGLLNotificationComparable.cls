global class EI_AGLLNotificationComparable implements Comparable {

    public Deposit__c deposit;
    
    // Constructor
    public EI_AGLLNotificationComparable(Deposit__c depo) {
        deposit = depo;
    }
    
    // Compare Deposit based on the Deposit CreatedDate.
    global Integer compareTo(Object compareTo) {
        // Cast argument to EI_AGLLNotificationComparable
         Integer returnValue = 0;
        EI_AGLLNotificationComparable compareToDeposit = (EI_AGLLNotificationComparable)compareTo;
        if( compareToDeposit.deposit.LastModifiedDate < deposit.LastModifiedDate){
        		returnValue = -1;
        }
        else if( compareToDeposit.deposit.LastModifiedDate > deposit.LastModifiedDate){
        		returnValue = 1;
        } 
         else if( compareToDeposit.deposit.LastModifiedDate == deposit.LastModifiedDate){
        		returnValue = 0;
        } 
        return returnValue;     
               
    }
}