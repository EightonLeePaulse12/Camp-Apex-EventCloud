@isTest
private class EventTriggerHandlerTest {

    @isTest
    static void testOnBeforeInsert() {
        List<CAMPX__Event__c> events = new List<CAMPX__Event__c>();

        for (Integer i = 0; i < 25; i++) {
            events.add(new CAMPX__Event__c(Name = 'Test Event ' + i));
        }

        Test.startTest();
        insert events;
        Test.stopTest();

        events = [SELECT Id, CAMPX__Status__c FROM CAMPX__Event__c WHERE Id IN :events];

        // Verify that the status is set to 'Planning' for all records
        for (CAMPX__Event__c event : events) {
            System.assertEquals('Planning', event.CAMPX__Status__c, 'Status should be set to Planning on insert');
        }
    }

    @isTest
    static void testOnAfterInsertAndUpdate() {
        // Insert records to test onAfterInsert
        List<CAMPX__Event__c> events = new List<CAMPX__Event__c>();

        for (Integer i = 0; i < 3; i++) {
            events.add(new CAMPX__Event__c(Name = 'Test Event ' + i, CAMPX__Status__c = 'Planning'));
        }

        Test.startTest();
        insert events;
        Test.stopTest();

        events = [SELECT Id, CAMPX__Status__c, CAMPX__StatusChangeDate__c FROM CAMPX__Event__c WHERE Id IN :events];

        // Verify that StatusChangeDate__c is set after insert
        for (CAMPX__Event__c event : events) {
            System.assertEquals('Planning', event.CAMPX__Status__c);
            System.assertNotEquals(null, event.CAMPX__StatusChangeDate__c, 'Status should be set on insert');
        }

        // Update records to test onAfterUpdate
        for (CAMPX__Event__c event : events) {
            event.CAMPX__Status__c = 'Completed';
        }

        update events;

        events = [SELECT Id, CAMPX__Status__c, CAMPX__StatusChangeDate__c FROM CAMPX__Event__c WHERE Id IN :events];

        // Verify that StatusChangeDate__c is updated after status change
        for (CAMPX__Event__c event : events) {
            System.assertEquals('Completed', event.CAMPX__Status__c, 'Status should be updated to Completed');
            System.assertNotEquals(null, event.CAMPX__StatusChangeDate__c, 'StatusChangeDate__c should be updated on status change');
        }
    }
}
