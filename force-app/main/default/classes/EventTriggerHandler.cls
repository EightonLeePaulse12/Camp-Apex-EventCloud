public with sharing class EventTriggerHandler {

    private static final String STATUS_PLANNING = 'Planning';

    public static void onBeforeInsert(List<CAMPX__Event__c> newRecords) {
        setDefaultStatus(newRecords);
    }

    public static void onAfterInsertAndUpdate(List<CAMPX__Event__c> newRecords, Map<Id, CAMPX__Event__c> oldRecordsMap) {
        List<CAMPX__Event__c> recordsToUpdate = new List<CAMPX__Event__c>();

        for(CAMPX__Event__c newEvent : newRecords) {
            Boolean isStatusChanged = isStatusChanged(newEvent, oldRecordsMap);

            if(isStatusChanged || oldRecordsMap == null || !oldRecordsMap.containsKey(newEvent.Id)) {
                recordsToUpdate.add(createStatusChangeDateUpdate(newEvent.Id));
            }
        }

        if(!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }

    public static void setDefaultStatus(List<CAMPX__Event__c> newRecords) {
        for(CAMPX__Event__c event : newRecords) {
            event.CAMPX__Status__c = STATUS_PLANNING;
        }
    }

    private static Boolean isStatusChanged(CAMPX__Event__c newEvent, Map<Id, CAMPX__Event__c> oldRecordsMap) {
        if(oldRecordsMap != null && oldRecordsMap.containsKey(newEvent.Id)) {
            return newEvent.CAMPX__Status__c != oldRecordsMap.get(newEvent.Id).CAMPX__Status__c;
        }
        return false;
    }

    private static CAMPX__Event__c createStatusChangeDateUpdate(Id eventId) {
        return new CAMPX__Event__c(
            Id = eventId,
            CAMPX__StatusChangeDate__c = System.now()
        );
    }
}