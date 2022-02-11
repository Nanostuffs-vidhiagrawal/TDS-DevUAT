Public class EI_PrimaryLandlordDetailsHandler {
    
    
    Public static void UpdatePrimaryLandlordAfterInsert (Map<Id, Property_Allocation__c> NewPropAllocate){
        Map<Id, Property__c> PropertyMap = New Map<Id, Property__c> (); //List<Property__c> PropertyList = New List<Property__c> ();
        For(Property_Allocation__c PropAll : NewPropAllocate.values()){
            If(PropAll.Relation_to_Property__c =='Primary Landlord'){
                Property__c Prop = New Property__c ();     
                Prop.Id = PropAll.Property__c;
                Prop.Primary_Landlord__c =PropAll.Contact__c;
                PropertyMap.put(PropAll.Property__c, Prop); //PropertyList.add(Prop);
            }
        }
        if(PropertyMap.size()>0 ){
            update PropertyMap.values(); //Update PropertyList; 
            
            
        }
        
        
    }
    
    Public static void UpdatePrimaryLandlordAfterUpdate (Map<Id, Property_Allocation__c> NewPropAllocate){
        
        Map<Id, Property__c> PropertyMap = New Map<Id, Property__c> (); //List<Property__c> PropertyList = New List<Property__c> ();
        For(Property_Allocation__c PropAll : NewPropAllocate.values()){
            If(PropAll.Relation_to_Property__c =='Primary Landlord'){
                Property__c Prop = New Property__c ();     
                Prop.Id = PropAll.Property__c;
                Prop.Primary_Landlord__c =PropAll.Contact__c;
                PropertyMap.put(PropAll.Property__c, Prop); //PropertyList.add(Prop);
            }
        }
        if(PropertyMap.size()>0 ){
            update PropertyMap.values(); //Update PropertyList; 
            
            
        }
        
    }
    
    
}