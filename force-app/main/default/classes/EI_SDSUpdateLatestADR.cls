public class EI_SDSUpdateLatestADR {
    public static void getAllAdrToUpdateLatest(List<Adjudication_Report__c> adrList) {
        List<Adjudication_Report__c> updateAdr = new List<Adjudication_Report__c>();
         List<Adjudication_Report__c> updateAdr2 = new List<Adjudication_Report__c>();
        List<Case> caseList = new List<Case>();

        for(Adjudication_Report__c adr:adrList){
            adr.Latest_AD_Report__c = true;
            caseList.add(new Case(id=adr.Dispute__c));
                updateAdr.add(adr);
        }
        for(Adjudication_Report__c adr: [Select id,Latest_AD_Report__c from Adjudication_Report__c where Status__c = 'Published' and Dispute__c =: caseList and Id not in : updateAdr]){
           system.debug('@@!! '+adr.Latest_AD_Report__c);
            if(adr.Latest_AD_Report__c){
                
                adr.Latest_AD_Report__c = false;
                updateAdr2.add(adr);
              system.debug('@@ '+adr.Latest_AD_Report__c);
            }
        }
        if(updateAdr2.size()>0){
            update updateAdr2;
        }

        
    }
}