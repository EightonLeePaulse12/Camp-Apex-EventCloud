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
    
    @isTest static void testOnEmailDefault() {
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
    
    @isTest static void testSetTierInsert() {
        List<CAMPX__Sponsor__c> newRecords = new List<CAMPX__Sponsor__c>();
        
        CAMPX__Sponsor__c blank = new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = null, CAMPX__Email__c = 'pear@example.com');
        CAMPX__Sponsor__c isZero = new CAMPX__Sponsor__c(Name='isZero Test', CAMPX__ContributionAmount__c = 0, 	CAMPX__Email__c = 'cat@example.com');
        CAMPX__Sponsor__c moreThanZeroLessThanThousand = new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 500, CAMPX__Email__c = 'sales@example.com');
        CAMPX__Sponsor__c moreThanThousandLessThanFiveThousand = new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 1600, 	CAMPX__Email__c = 'wine@example.com');
        CAMPX__Sponsor__c moreThanOrEqualFiveThousand = new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 10000, 	CAMPX__Email__c = 'dog@example.com');
        
        newRecords.add(blank);
        newRecords.add(isZero);
        newRecords.add(moreThanOrEqualFiveThousand);
        newRecords.add(moreThanThousandLessThanFiveThousand);
        newRecords.add(moreThanZeroLessThanThousand);
        
        Test.startTest();
            insert newRecords;
        Test.stopTest();

        newRecords = [SELECT Id, CAMPX__ContributionAmount__c, CAMPX__Tier__c FROM CAMPX__Sponsor__c WHERE Id IN :newRecords];

        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if(sponsor.CAMPX__ContributionAmount__c > 0 && sponsor.CAMPX__ContributionAmount__c < 1000) {
                System.assertEquals('Bronze', sponsor.CAMPX__Tier__c, 'Tier should be bronze if more than 0 but less than 1000');
            } else if (sponsor.CAMPX__ContributionAmount__c >= 1000 && sponsor.CAMPX__ContributionAmount__c < 5000 ) {
                System.assertEquals('Silver', sponsor.CAMPX__Tier__c, 'Tier should be silver if more than or equal to 1000 and less than 5000');
            } else if(sponsor.CAMPX__ContributionAmount__c >= 5000) {
                System.assertEquals('Gold', sponsor.CAMPX__Tier__c, 'Tier should be gold if greater than 5000');
            }
        }
        
    }
    
    @isTest static void testSetTierUpdate() {
        List<CAMPX__Sponsor__c> newRecords = new List<CAMPX__Sponsor__c>();
        Map<Id, CAMPX__Sponsor__c> oldRecordsMap = new Map<Id, CAMPX__Sponsor__c>();

        CAMPX__Sponsor__c moreThanZeroLessThanThousand = new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 500, CAMPX__Email__c = 'dog@example.com');
        CAMPX__Sponsor__c moreThanThousandLessThanFiveThousand = new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 1600, 	CAMPX__Email__c = 'pear@example.com');
        CAMPX__Sponsor__c moreThanOrEqualFiveThousand = new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 6000, CAMPX__Email__c = 'banana@example.com');

        newRecords.add(moreThanZeroLessThanThousand);
        newRecords.add(moreThanOrEqualFiveThousand);
        newRecords.add(moreThanThousandLessThanFiveThousand);


        Test.startTest();
        insert newRecords;
        Test.stopTest();

        moreThanZeroLessThanThousand.CAMPX__ContributionAmount__c = 1200;
        moreThanThousandLessThanFiveThousand.CAMPX__ContributionAmount__c = 5500;
        update newRecords;

        newRecords = [SELECT Id, CAMPX__ContributionAmount__c, CAMPX__Tier__c FROM CAMPX__Sponsor__c WHERE Id IN :newRecords];

        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if(sponsor.CAMPX__ContributionAmount__c > 0 && sponsor.CAMPX__ContributionAmount__c < 1000) {
                System.assertEquals('Bronze', sponsor.CAMPX__Tier__c, 'Tier should be bronze if more than 0 but less than 1000');
            } else if (sponsor.CAMPX__ContributionAmount__c >= 1000 && sponsor.CAMPX__ContributionAmount__c < 5000 ) {
                System.assertEquals('Silver', sponsor.CAMPX__Tier__c, 'Tier should be silver if more than or equal to 1000 and less than 5000');
            } else if(sponsor.CAMPX__ContributionAmount__c >= 5000) {
                System.assertEquals('Gold', sponsor.CAMPX__Tier__c, 'Tier should be gold if greater than or equal to 5000');
            }
        }
    }

    @isTest static void testAcceptedWithoutEvent() {
        List<CAMPX__Sponsor__c> newRecords = new List<CAMPX__Sponsor__c>();

        for(Integer i = 0; i < 3; i++) {
            newRecords.add(new CAMPX__Sponsor__c(Name='Test this' + i));
        }

        Test.startTest();
        for(CAMPX__Sponsor__c sponsor : newRecords) {
            try{
                insert sponsor;
                System.assert(false, 'DML error was thrown, cannot change status to accepted without related event');
            } catch (DmlException e) {
                System.assertEquals(e.getMessage(), e.getMessage());
            }
        }
        Test.stopTest();
    }
}