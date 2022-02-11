public class EI_SDS_BulkInsertBatch2 implements Database.Batchable<sObject>, Database.Stateful{
    
    public integer count = 0;
    List<Account> accList = new  List<Account>();
    set<Id> accIdSet = new Set<id>();
    List<Contact> conList = new List<Contact>();
    set<Id> conIdSet = new Set<id>();
    
    public EI_SDS_BulkInsertBatch2( List<Contact> conList, List<Account> accList, set<Id> accIdSet){
        this.accList = accList;
        this.conList = conList;
        this.accIdSet= accIdSet;
    }
    
    public Iterable<sObject> start(Database.BatchableContext BC)
    {
        // List<String> strList = new List<String> { 'When', 'shall this', 'quarantine be over' };
        // System.debug('strList => ' + strList);
        return conList;
    }
    
    public void execute(Database.BatchableContext info, List<Contact> conData)
    {
        Contact con = conData[0];
        System.debug('con => ' + con);
        try{
            //Database.SaveResult[] consrList = Database.insert(conData, false);
            insert conData;
            System.debug('conData.size() => ' + conData.size());
            for(integer i =0; i<conData.size(); i++){
                conList[count].Id = conData[i].Id;
                conIdSet.add(conData[i].Id);
                System.debug('Contact Id of index '+ count +' => ' + conList[count].Id );
                count++;
            }
        }catch(Exception e){
            System.Debug('Contact file exeption => ' + e.getMessage() );
            System.debug('Contact Catch exception conList =>  ' + conList );
            System.debug('Contact Catch exception accList => ' + accList );
            delete [Select id, name from Contact Where id in:conIdSet] ;
            delete [Select id, name from Account Where id in:accIdSet] ;
        }
    }

    public void finish(Database.BatchableContext info) { 
        System.debug('finish method EI_SDS_BulkInsertBatch2 => ');
        for (integer i =0; i<conList.size(); i++) {
            Contact c = conList[i];
            System.debug('Contact => ' + c.lastName + ' :: ' + c.Id);
        }
    }
}