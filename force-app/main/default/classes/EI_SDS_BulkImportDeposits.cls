public class EI_SDS_BulkImportDeposits {
    @auraenabled
    public static void runImportBatch(String fileRecords){
        Blob payload = EncodingUtil.base64Decode(fileRecords);
        system.debug('fileRecords '+payload);
     /*   EI_SDS_BulkImportDepositsBatch bid = new EI_SDS_BulkImportDepositsBatch(fileRecords);
        database.executeBatch(bid,10);   */
    }
}