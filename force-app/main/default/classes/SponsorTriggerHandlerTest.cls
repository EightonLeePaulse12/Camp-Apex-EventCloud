@isTest
private class SponsorTriggerHandlerTest {

    private static List<CAMPX__Sponsor__c> createSponsorsWithEmail(Integer count) {
        List<CAMPX__Sponsor__c> sponsors = new List<CAMPX__Sponsor__c>();
        for(Integer i = 0; i < count; i++) {
            sponsors.add(new CAMPX__Sponsor__c(Name = 'Sponsor' + i, CAMPX__Email__c = 'email' + i + '@example.com'));
        }
        return sponsors;
    }

    private static List<CAMPX__Sponsor__c> createSponsorsWithoutEmail(Integer count) {
        List<CAMPX__Sponsor__c> sponsors = new List<CAMPX__Sponsor__c>();
        for(Integer i = 0; i < count; i++) {
            sponsors.add(new CAMPX__Sponsor__c(Name = 'Sponsor' + i));
        }
        return sponsors;
    }
    
    @isTest static void testOnBeforeInsert() {
        List<CAMPX__Sponsor__c> newRecords = createSponsorsWithEmail(25);
        CAMPX__Sponsor__c rejectedTest = new CAMPX__Sponsor__c(Name = 'Rejected Test 1', CAMPX__Status__c = 'Rejected', CAMPX__Email__c = 'rejected@example.com');

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
        List<CAMPX__Sponsor__c> sponsors = createSponsorsWithoutEmail(25);
        
        Test.startTest();
        for(CAMPX__Sponsor__c sponsor : sponsors) {
            try{
                insert sponsor;
                System.assert(false, 'Expected DmlException due to missing email');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('A sponsor can not be created without an email address'), 'Error message should indicate missing email');
            }
        }
        Test.stopTest();
    }
    
    @isTest static void testSetTierInsert() {
        List<CAMPX__Sponsor__c> newRecords = new List<CAMPX__Sponsor__c>{
            new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = null, CAMPX__Email__c = 'pear@example.com'),
            new CAMPX__Sponsor__c(Name='isZero Test', CAMPX__ContributionAmount__c = 0, 	CAMPX__Email__c = 'cat@example.com'),
            new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 500, CAMPX__Email__c = 'sales@example.com'),
            new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 1600, 	CAMPX__Email__c = 'wine@example.com'),
            new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 10000, 	CAMPX__Email__c = 'dog@example.com')
        };
        
        Test.startTest();
        insert newRecords;
        Test.stopTest();
        
        newRecords = [SELECT Id, CAMPX__ContributionAmount__c, CAMPX__Tier__c FROM CAMPX__Sponsor__c WHERE Id IN :newRecords];
        
        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if (sponsor.CAMPX__ContributionAmount__c == null || sponsor.CAMPX__ContributionAmount__c == 0) {
                System.assertEquals(null, sponsor.CAMPX__Tier__c, 'Tier should be null if contribution is null or zero');
            } else if (sponsor.CAMPX__ContributionAmount__c > 0 && sponsor.CAMPX__ContributionAmount__c < 1000) {
                System.assertEquals('Bronze', sponsor.CAMPX__Tier__c, 'Tier should be bronze if more than 0 but less than 1000');
            } else if (sponsor.CAMPX__ContributionAmount__c >= 1000 && sponsor.CAMPX__ContributionAmount__c < 5000) {
                System.assertEquals('Silver', sponsor.CAMPX__Tier__c, 'Tier should be silver if more than or equal to 1000 and less than 5000');
            } else {
                System.assertEquals('Gold', sponsor.CAMPX__Tier__c, 'Tier should be gold if greater than or equal to 5000');
            }
        }
        
    }
    
    @isTest static void testSetTierUpdate() {
        List<CAMPX__Sponsor__c> newRecords = new List<CAMPX__Sponsor__c>{
            new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 500, CAMPX__Email__c = 'dog@example.com'),
            new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 1600, 	CAMPX__Email__c = 'pear@example.com'),
            new CAMPX__Sponsor__c(Name='Blank Test', CAMPX__ContributionAmount__c = 6000, CAMPX__Email__c = 'banana@example.com')
        };
        

        insert newRecords;
        
        newRecords[0].CAMPX__ContributionAmount__c = 1200;
        newRecords[1].CAMPX__ContributionAmount__c = 5500;
        update newRecords;
        
        newRecords = [SELECT Id, CAMPX__ContributionAmount__c, CAMPX__Tier__c FROM CAMPX__Sponsor__c WHERE Id IN :newRecords];
        
        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if (sponsor.CAMPX__ContributionAmount__c >= 1000 && sponsor.CAMPX__ContributionAmount__c < 5000) {
                System.assertEquals('Silver', sponsor.CAMPX__Tier__c, 'Tier should be silver if contribution is updated to between 1000 and 5000');
            } else if (sponsor.CAMPX__ContributionAmount__c >= 5000) {
                System.assertEquals('Gold', sponsor.CAMPX__Tier__c, 'Tier should be gold if contribution is updated to 5000 or greater');
            }
        }
    }
    
    @isTest static void testAcceptedWithoutEventInsert() {
        List<CAMPX__Sponsor__c> sponsors = createSponsorsWithEmail(25);
        
        for(CAMPX__Sponsor__c sponsor : sponsors) {
            sponsor.CAMPX__Status__c = 'Accepted';
        }
        
        Test.startTest();
            try{
                insert sponsors;
                System.assert(false, 'Expected a DmlExeption due to missing event for accepted status');
            } catch(DmlException e) {
                System.assert(e.getMessage().contains('A Sponsor must be associated with an event before being Accepted.'),
                'Expected error message for missing event on accepted sponsor');
            }
        Test.stopTest();
    }
    
    @isTest static void testAcceptedWithoutEventUpdate() {
        List<CAMPX__Sponsor__c> sponsors = createSponsorsWithEmail(25);
        
        for(CAMPX__Sponsor__c sponsor : sponsors) {
            sponsor.CAMPX__Status__c = 'Pending';
        }
        
        insert sponsors;
        
        Test.startTest();
        for(CAMPX__Sponsor__c sponsor : sponsors) {
            sponsor.CAMPX__Status__c = 'Accepted';
            try{
                update sponsor;
                System.assert(false, 'Expected a DmlExeption due to missing event for accepted status');
            } catch(DmlException e) {
                System.assert(e.getMessage().contains('A Sponsor must be associated with an event before being Accepted.'),
                'Expected error message for missing event on accepted sponsor');
            }
        }
        Test.stopTest();
    }

    // When Sponsor Record's status is updated to "Accepted", their contributedamount should be added onto the related event's Gross Revenue

    @isTest static void testAddOntoGrossRev() {
        CAMPX__Event__c newEvent = new CAMPX__Event__c(Name='New event');
        insert newEvent;

        List<CAMPX__Sponsor__c> sponsors = createSponsorsWithEmail(3);

        for(CAMPX__Sponsor__c sponsor : sponsors) {
            sponsor.CAMPX__ContributionAmount__c = 2000;
            sponsor.CAMPX__Status__c = 'Accepted';
            sponsor.CAMPX__Event__c = newEvent.Id;
        }

        Test.startTest();
        insert sponsors;

        newEvent = [SELECT Id, CAMPX__GrossRevenue__c FROM CAMPX__Event__c WHERE Id = :newEvent.Id];

        System.assertEquals(6000, newEvent.CAMPX__GrossRevenue__c, 'Gross Revenue should reflect related sponsor\'s contribution amounts');
        Test.stopTest();

    }
}