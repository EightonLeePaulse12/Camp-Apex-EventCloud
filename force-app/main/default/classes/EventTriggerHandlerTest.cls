@isTest
private class EventTriggerHandlerTest {

    private static List<CAMPX__Event__c> createEvents(Integer count, String status) {
        List<CAMPX__Event__c> events = new List<CAMPX__Event__c>();
        for(Integer i = 0; i < count; i++) {
            events.add(new CAMPX__Event__c(Name = 'Test Event' + i, CAMPX__Status__c = status));
        }
        return events;
    }

    private static void verifyEventStatusAndDate(List<CAMPX__Event__c> events, String expectedStatus) {
        events = [SELECT Id, CAMPX__Status__c, CAMPX__StatusChangeDate__c FROM CAMPX__Event__c WHERE Id IN :events];

        for(CAMPX__Event__c event : events) {
            System.assertEquals(expectedStatus, event.CAMPX__Status__c, 'Status should be ' + expectedStatus);
            System.assertNotEquals(null, event.CAMPX__StatusChangeDate__c, 'Status Change Date should not be null');
        }
    }

    @isTest
    static void testOnBeforeInsert() {
        List<CAMPX__Event__c> events = createEvents(25, 'Planning');

        Test.startTest();
        insert events;
        Test.stopTest();

        // Verify that the status is set to 'Planning' for all records
        verifyEventStatusAndDate(events, 'Planning');
    }

    @isTest
    static void testOnAfterInsertAndUpdate() {
        // Insert records to test onAfterInsert
        List<CAMPX__Event__c> events = createEvents(25, 'Planning');

        Test.startTest();
        insert events;
        Test.stopTest();

        verifyEventStatusAndDate(events, 'Planning');

        // Verify that StatusChangeDate__c is set after insert
        for (CAMPX__Event__c event : events) {
            event.CAMPX__Status__c = 'Completed';
        }

        // Update records to test onAfterUpdate
        Test.startTest();
        update events;
        Test.stopTest();

        verifyEventStatusAndDate(events, 'Completed');
    }

    @isTest static void testUpdateNetRevenue() {
        // CAMPX__NetRevenue__c of CAMPX__event__c record should reflect the formula:
            // CAMPX__GrossRevenue__c - CAMPX__TotalExpenses__c
        // If either CAMPX__GrossRevenue__c or CAMPX__TotalExpenses__c are blank, the CAMPX__NetRevenue__c should be blank
    }
}