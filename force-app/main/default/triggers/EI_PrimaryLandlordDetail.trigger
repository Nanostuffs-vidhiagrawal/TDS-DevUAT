trigger EI_PrimaryLandlordDetail on Property_Allocation__c (After Insert,After Update) {
    
    if(Trigger.IsAfter && Trigger.IsInsert){  
     EI_PrimaryLandlordDetailsHandler.UpdatePrimaryLandlordAfterInsert(Trigger.NewMap); 
       
    }
    
    if(Trigger.IsAfter && Trigger.IsUpdate){  
     EI_PrimaryLandlordDetailsHandler.UpdatePrimaryLandlordAfterUpdate(Trigger.NewMap);   
    }
}