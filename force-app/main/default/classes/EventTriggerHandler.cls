public with sharing class EventTriggerHandler {

    private static final String STATUS_PLANNING = 'Planning';

    public static void onBeforeInsert(List<CAMPX__Event__c> newRecords) {
        setDefaultStatus(newRecords);
    }

    public static void onAfterInsertAndUpdate(List<CAMPX__Event__c> newRecords, Map<Id, CAMPX__Event__c> oldRecordsMap) {
        setStatusChangeDate(newRecords, oldRecordsMap);
    }

    public static void setDefaultStatus(List<CAMPX__Event__c> newRecords) {
        for(CAMPX__Event__c event : newRecords) {
            event.CAMPX__Status__c = STATUS_PLANNING;
        }
    }

    public static void setStatusChangeDate(List<CAMPX__Event__c> newRecords, Map<Id, CAMPX__Event__c> oldRecordsMap) {
        List<CAMPX__Event__c> recordsToUpdate = new List<CAMPX__Event__c>();

        for(CAMPX__Event__c newEvent : newRecords) {
            if(oldRecordsMap != null && oldRecordsMap.containsKey(newEvent.Id)) {
                // Check if status changed
                if(newEvent.CAMPX__Status__c != oldRecordsMap.get(newEvent.Id).CAMPX__Status__c) {
                    CAMPX__Event__c eventToUpdate = new CAMPX__Event__c(
                        Id = newEvent.Id,
                        CAMPX__StatusChangeDate__c = System.now()
                    );
                    recordsToUpdate.add(eventToUpdate);
                }
            } else {
                // Set StatusChangeDate for new records
                CAMPX__Event__c eventToUpdate = new CAMPX__Event__c(
                    Id = newEvent.Id,
                    CAMPX__StatusChangeDate__c = System.now()
                );
                recordsToUpdate.add(eventToUpdate);
            }
        }

        // Perform a single update on records that need their StatusChangeDate__c set or updated
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
}
