/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Performs aggregation of related Dispute's Dispute amount and saves the value on the Account
 *
 * @when 31/10/2019
 */
public with sharing class FC_CaseAccountRollupCalculator {
    /**
    * Performs aggregation of related Dispute's Dispute amount and saves the value on the Account
    * @param accountIds Ids of Accounts affected by the change
    */
    public static void rollupDisputedAmountForAccounts(Set<Id> accountIds){
        List<Account> accountsToUpdate = new List<Account>();
        List<AggregateResult> results = [
                SELECT AccountId, sum(Disputed_Amount__c) sumAmount
                FROM Case
                WHERE IsClosed = false
                AND RecordTypeId IN :FC_Utils.getDisputeCaseRecordTypeIds()
                AND AccountId IN :accountIds
                GROUP BY AccountId];

        for(AggregateResult result : results){
            Account accountToUpdate = new Account(
                    Id = (Id)result.get('AccountId'), Disputes_Snapshot__c = (Decimal)result.get('sumAmount'));
            accountsToUpdate.add(accountToUpdate);
        }

        if(!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate;
            }
            catch(DmlException dme) {
                FC_ErrorLogger.error(dme);
                System.debug('### Failed to update Accounts on rollupDisputedAmountForAccounts():' + dme.getMessage());
            }
        }
    }
}