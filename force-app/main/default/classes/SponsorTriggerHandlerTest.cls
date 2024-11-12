@isTest 
private class SponsorTriggerHandlerTest {

    @isTest static void testOnBeforeInsert() {
        List<CAMPX__Sponsor__c> newRecords = new List<CAMPX__Sponsor__c>();

        for(Integer i = 0; i < 25; i++) {
            newRecords.add(new CAMPX__Sponsor__c(Name='Test Sponsor' + i));
        }

        CAMPX__Sponsor__c rejectedTest = new CAMPX__Sponsor__c(Name='Rejected Test 1', CAMPX__Status__c = 'Rejected');

        Test.startTest();
        insert newRecords;
        insert rejectedTest;
        Test.stopTest();


        rejectedTest = [SELECT Id, CAMPX__Status__c FROM CAMPX__Sponsor__c WHERE Id = :rejectedTest.Id];
        newRecords = [SELECT Id, CAMPX__Status__c FROM CAMPX__Sponsor__c WHERE Id IN :newRecords];

        System.assertEquals('Rejected', rejectedTest.CAMPX__Status__c, 'Status should not change if rejected on create');

        for(CAMPX__Sponsor__c sponsor : newRecords) {
            System.assertEquals('Pending', sponsor.CAMPX__Status__c, 'Should be set to pending on insert');
        }
    }

    @isTest static void testOnAfterInsertAndUpdate() {
        List<CAMPX__Sponsor__c> sponsors = new List<CAMPX__Sponsor__c>();

        for(Integer i = 0; i < 3; i++) {
            sponsors.add(new CAMPX__Sponsor__c(Name='Sponsor without email' + i));
        }

        Test.startTest();
        for(CAMPX__Sponsor__c sponsor : sponsors) {
            try{
                insert sponsor;
                System.assert(false, 'Expected DmlException was not thrown');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('A sponsor can not be created without an email address'), 'Error message should indicate missing email');
            }
        }
        Test.stopTest();
        
    }
}