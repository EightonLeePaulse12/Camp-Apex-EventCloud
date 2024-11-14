public with sharing class EventTriggerHandler {

    private static final String STATUS_PLANNING = 'Planning';

    public static void onBeforeInsertAndUpdate(List<CAMPX__Event__c> newRecords) {
        setDefaultStatus(newRecords);
        setRevenue(newRecords);
    }


    public static void onAfterInsertAndUpdate(List<CAMPX__Event__c> newRecords, Map<Id, CAMPX__Event__c> oldRecordsMap) {
        
        List<CAMPX__Event__c> recordsToUpdate = new List<CAMPX__Event__c>();

        for(CAMPX__Event__c newEvent : newRecords) {
            Boolean isStatusChanged = isStatusChanged(newEvent, oldRecordsMap);

            if(isStatusChanged || oldRecordsMap == null || !oldRecordsMap.containsKey(newEvent.Id)) {
                recordsToUpdate.add(createStatusChangeDateUpdate(newEvent.Id));
            }
        }
    }

    public static void setDefaultStatus(List<CAMPX__Event__c> newRecords) {
        for(CAMPX__Event__c event : newRecords) {
            event.CAMPX__Status__c = STATUS_PLANNING;
        }
    }

    public static void setRevenue(List<CAMPX__Event__c> events) {
        List<CAMPX__Event__c> eventsToUpdate = new List<CAMPX__Event__c>();

        for(CAMPX__Event__c event : events) {
            if(event.CAMPX__GrossRevenue__c != null && event.CAMPX__TotalExpenses__c != null) {
                event.CAMPX__NetRevenue__c = event.CAMPX__GrossRevenue__c - event.CAMPX__TotalExpenses__c;
            } else {
                event.CAMPX__NetRevenue__c = null;  // Set to 0 if either value is missing (handle $0 scenario)
            }
            eventsToUpdate.add(event);  // Collect records for update
        }

        // Perform update operation outside the loop for the records needing NetRevenue update
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