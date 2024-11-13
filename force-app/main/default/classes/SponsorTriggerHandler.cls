public with sharing class SponsorTriggerHandler {
    
    private static final string STATUS_PENDING = 'Pending';

    public static void OnBeforeInsert(List<CAMPX__Sponsor__c> newRecords) {
        setDefaultStatus(newRecords);
        setEmailRequirement(newRecords);
    }

    public static void onBeforeInsertAndUpdate(List<CAMPX__Sponsor__c> newRecords) {
        setTierLevel(newRecords);
    }

    public static void setDefaultStatus(List<CAMPX__Sponsor__c> newRecords) {
        if(newRecords.size() > 0) {
            for(CAMPX__Sponsor__c sponsor : newRecords) {
                if(sponsor.CAMPX__Status__c != 'Rejected') {
                    sponsor.CAMPX__Status__c = STATUS_PENDING;
                } else {
                    System.debug('This should remain the same.');
                }
            }
        }
    }

    public static void setEmailRequirement(List<CAMPX__Sponsor__c> newRecords) {
        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if(String.isBlank(sponsor.CAMPX__Email__c)) {
                sponsor.addError('A sponsor can not be created without an email address');
            }
        }
    }

    public static void setTierLevel(List<CAMPX__Sponsor__c> newRecords) {
        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if(sponsor.CAMPX__ContributionAmount__c == null || sponsor.CAMPX__ContributionAmount__c <= 0) {
                sponsor.CAMPX__Tier__c = null;  // No tier if the amount is null or zero
            } else if(sponsor.CAMPX__ContributionAmount__c > 0 && sponsor.CAMPX__ContributionAmount__c < 1000) {
                sponsor.CAMPX__Tier__c = 'Bronze';
            } else if(sponsor.CAMPX__ContributionAmount__c >= 1000 && sponsor.CAMPX__ContributionAmount__c < 5000) {
                sponsor.CAMPX__Tier__c = 'Silver';
            } else if(sponsor.CAMPX__ContributionAmount__c >= 5000) {
                sponsor.CAMPX__Tier__c = 'Gold';
            }
        }
        
    }
}