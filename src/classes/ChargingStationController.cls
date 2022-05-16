public class ChargingStationController {
    
    @AuraEnabled
    public static charge__c getPayload(string recordId){
        List< charge__c > lst = [SELECT Id FROM charge__c WHERE contact__c =:recordId
                                 AND Start_Time__c != null
                                 AND End_Time__c = null
                                 ORDER BY CreatedDate DESC LIMIT 1];
        if(lst.isEmpty()) return null;
        return lst[0];
    }
    
    @AuraEnabled
    public static void createChargingRecord(string recordId){
        INSERT new charge__c(contact__c=recordId,Start_Time__c=System.now());
    }
    
    @AuraEnabled
    public static void updateChargingRecord(string recordId){
        charge__c data = getPayload(recordId);
        if(data <> null){
            data.End_Time__c = System.now();
            UPDATE data;
        }
    }
}