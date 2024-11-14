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
    
    @isTest
    static void testUpdateNetRevenue() {
        // Create an event with $0 Gross Revenue and $0 Total Expenses
        CAMPX__Event__c newEvent = new CAMPX__Event__c(
            Name = 'Zero Revenue Event',
        CAMPX__GrossRevenue__c = 0,
        CAMPX__TotalExpenses__c = 0
            );
        
        // Insert the record
        Test.startTest();
        insert newEvent;
        Test.stopTest();
        
        // Verify that NetRevenue is $0 after insert
        newEvent = [SELECT Id, CAMPX__GrossRevenue__c, CAMPX__TotalExpenses__c, CAMPX__NetRevenue__c 
                FROM CAMPX__Event__c 
                WHERE Id = :newEvent.Id];
        System.assertEquals(0, newEvent.CAMPX__NetRevenue__c, 'NetRevenue should be $0 after insert');
        
        // Update the record, keeping Gross Revenue and Total Expenses at $0
        newEvent.CAMPX__GrossRevenue__c = 0;
        newEvent.CAMPX__TotalExpenses__c = 0;
        
        update newEvent;
        
        // Verify that NetRevenue is still $0 after update
        newEvent = [SELECT Id, CAMPX__GrossRevenue__c, CAMPX__TotalExpenses__c, CAMPX__NetRevenue__c 
                FROM CAMPX__Event__c 
                WHERE Id = :newEvent.Id];
        System.assertEquals(0, newEvent.CAMPX__NetRevenue__c, 'NetRevenue should still be $0 after update with $0 values for both GrossRevenue and TotalExpenses');
        
        // Update again with different values for Gross Revenue and Total Expenses
        newEvent.CAMPX__GrossRevenue__c = 5000;
        newEvent.CAMPX__TotalExpenses__c = 2000;
        
        update newEvent;
        
        // Verify that NetRevenue is updated correctly after second update (5000 - 2000 = 3000)
        newEvent = [SELECT Id, CAMPX__GrossRevenue__c, CAMPX__TotalExpenses__c, CAMPX__NetRevenue__c 
                FROM CAMPX__Event__c 
                WHERE Id = :newEvent.Id];
        System.assertEquals(3000, newEvent.CAMPX__NetRevenue__c, 'NetRevenue should be 3000 after update with different GrossRevenue and TotalExpenses');
    }
    
    private static CAMPX__Event__c createRevenueRecord(Integer count) {
        CAMPX__Event__c newEvent = new CAMPX__Event__c(Name = 'Event ' + count, CAMPX__GrossRevenue__c = 5000, CAMPX__TotalExpenses__c = 2000);
        return newEvent;
    }
}