public class EI_SDS_BulkInsertBatch1 implements Database.Batchable<sObject>, Database.Stateful{
    
    public integer count = 0;
    List<Account> accList = new  List<Account>();
    set<Id> accIdSet = new Set<id>();
    List<Contact> conList = new List<Contact>();
    
    public EI_SDS_BulkInsertBatch1(List<Account> accList, List<Contact> conList){
        this.accList = accList;
        this.conList = conList;
    }
    
    public Iterable<sObject> start(Database.BatchableContext BC)
    {
        return accList;
    }
    
    public void execute(Database.BatchableContext info, List<Account> accData)
    {
        Account acc = accData[0];
        System.debug('acc => ' + acc);

        try{
            //Database.SaveResult[] accsrList = Database.insert(accData, false);
            insert accData;
            for(integer i =0; i<accData.size(); i++){
                id accId = accData[i].Id;                 
                accList[count].Id = accId;
                accIdSet.add(accId);
                System.debug('accId => ' + accList[count].Id );
                conList[count].AccountId = accId;	
                count++;
            }
        }catch(Exception e){
            System.debug('Account Catch exception => '  );
            delete [Select id, name from Account Where id in:accIdSet] ;
        }
        
    }

    public void finish(Database.BatchableContext info) { 
        System.debug('finish method EI_SDS_BulkInsertBatch1 => ');
        for (integer i =0; i<conList.size(); i++) {
            Contact c = conList[i];
            System.debug('AccountId and Contact => ' + c.lastName + ' :: ' + c.AccountId);
        }
        Database.executeBatch(new EI_SDS_BulkInsertBatch2( conList, accList, accIdSet), 2);
    }
}