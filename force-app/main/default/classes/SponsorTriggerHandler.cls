public with sharing class SponsorTriggerHandler {
    
    private static final string STATUS_PENDING = 'Pending';
    private static final string STATUS_ACCEPTED = 'Accepted';
    private static final string STATUS_REJECTED = 'Rejected';
    private static final string STATUS_CANCELLED = 'Cancelled';
    private static final Decimal BRONZE = 0;
    private static final Decimal SILVER = 1000;
    private static final Decimal GOLD = 5000;
    
    public static  void handleBeforeInsert(List<CAMPX__Sponsor__c> newRecords, Map<Id, CAMPX__Sponsor__c> oldRecords) {
        // SponsorTriggerHandler.OnBeforeInsert(newRecords);
        SponsorTriggerHandler.onBeforeInsertAndUpdate(newRecords, oldRecords);
    }
    
    public static void handleBeforeUpdate(List<CAMPX__Sponsor__c> newRecords, Map<Id, CAMPX__Sponsor__c> oldRecords) {
        System.debug('Trigger - before update');
        SponsorTriggerHandler.onBeforeInsertAndUpdate(newRecords, oldRecords);
    }
    
    public static void OnBeforeInsert(List<CAMPX__Sponsor__c> newRecords) {
        setDefaultStatus(newRecords);
        setEmailRequirement(newRecords);
    }
    
    public static void onBeforeInsertAndUpdate(List<CAMPX__Sponsor__c> newRecords, Map<Id, CAMPX__Sponsor__c> oldRecords) {
        setTierLevel(newRecords);
        preventAcceptedWithoutEvent(newRecords);
        setGrossRevenue(newRecords);
        handleSponsorChanges(newRecords, oldRecords);
    }
    
    public static void setDefaultStatus(List<CAMPX__Sponsor__c> newRecords) {
        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if(!isStatusAcceptedOrRejected(sponsor.CAMPX__Status__c)) {
                sponsor.CAMPX__Status__c = STATUS_PENDING;
            }
        }
    }
    
    private static Boolean isStatusAcceptedOrRejected(String status) {
        return status == STATUS_REJECTED || status == STATUS_ACCEPTED;
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
            sponsor.CAMPX__Tier__c = getSponsorTier(sponsor.CAMPX__ContributionAmount__c);
        }
    }
    
    private static String getSponsorTier(Decimal contributionAmount) {
        if (contributionAmount == null || contributionAmount <= BRONZE) {
            return null;  // No tier if the amount is null or zero
        } else if (contributionAmount < SILVER) {
            return 'Bronze';
        } else if (contributionAmount < GOLD) {
            return 'Silver';
        } else {
            return 'Gold';
        }
    }
    
    public static void preventAcceptedWithoutEvent(List<CAMPX__Sponsor__c> newRecords) {
        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if(shouldPreventAcceptedWithoutEvent(sponsor)) {
                sponsor.addError('A sponsor must be associated with an event before being Accepted.');
            } else if (sponsor.CAMPX__Event__c == null && sponsor.CAMPX__Status__c != STATUS_ACCEPTED) {
                sponsor.CAMPX__Event__c = null; // This would be a safe scenario for clearing the event
            }
        }
    }
    
    private static Boolean shouldPreventAcceptedWithoutEvent(CAMPX__Sponsor__c sponsor) {
        return sponsor.CAMPX__Status__c == STATUS_ACCEPTED && sponsor.CAMPX__Event__c == null;
    }
    
    public static void setGrossRevenue(List<CAMPX__Sponsor__c> newRecords) {
        Set<Id> eventIds = new Set<Id>();
        
        for(CAMPX__Sponsor__c sponsor: newRecords) {
            if(sponsor.CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__Event__c != null) {
                eventIds.add(sponsor.CAMPX__Event__c);
            }
        }
        
        Map<Id, CAMPX__Event__c> eventMap = new Map<Id, CAMPX__Event__c>(
            [SELECT Id, CAMPX__GrossRevenue__c FROM CAMPX__Event__c WHERE Id IN :eventIds]
            );
        
        for(CAMPX__Sponsor__c sponsor : newRecords) {
            if(sponsor.CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__Event__c != null) {
                Id eventId = sponsor.CAMPX__Event__c;
                CAMPX__Event__c event = eventMap.get(eventId);
                
                event.CAMPX__GrossRevenue__c = (event.CAMPX__GrossRevenue__c != null ? event.CAMPX__GrossRevenue__c : 0) + sponsor.CAMPX__ContributionAmount__c;
            }
        }
        
        update eventMap.values();
    }
    
    public static void handleSponsorChanges(List<CAMPX__Sponsor__c> newRecords, Map<Id, CAMPX__Sponsor__c> oldRecords) {
        Set<Id> eventIds = new Set<Id>();
    
        // Identify affected events
        for (CAMPX__Sponsor__c sponsor : newRecords) {
            CAMPX__Sponsor__c oldRecord = oldRecords != null ? oldRecords.get(sponsor.Id) : null;
    
            if (oldRecord != null) {
                if (sponsor.CAMPX__Status__c != oldRecord.CAMPX__Status__c || sponsor.CAMPX__Event__c != oldRecord.CAMPX__Event__c) {
                    eventIds.add(sponsor.CAMPX__Event__c);
                    eventIds.add(oldRecord.CAMPX__Event__c);
                }
            } else {
                eventIds.add(sponsor.CAMPX__Event__c);
            }
        }
    
        Map<Id, Decimal> amountMap = new Map<Id, Decimal>();
    
        // Recalculate gross revenue for each affected event
        if (!eventIds.isEmpty()) {
            List<CAMPX__Sponsor__c> relatedSponsors = [
                SELECT CAMPX__Event__c, CAMPX__ContributionAmount__c
                FROM CAMPX__Sponsor__c
                WHERE CAMPX__Event__c IN :eventIds AND CAMPX__Status__c = 'Accepted'
            ];
    
            for (CAMPX__Sponsor__c sponsor : relatedSponsors) {
                if (amountMap.containsKey(sponsor.CAMPX__Event__c)) {
                    amountMap.put(sponsor.CAMPX__Event__c, amountMap.get(sponsor.CAMPX__Event__c) + sponsor.CAMPX__ContributionAmount__c);
                } else {
                    amountMap.put(sponsor.CAMPX__Event__c, sponsor.CAMPX__ContributionAmount__c);
                }
            }
        }
    
        // Prepare updates for events
        List<CAMPX__Event__c> eventUpdates = new List<CAMPX__Event__c>();
        for (Id eventId : eventIds) {
            Decimal newGrossRevenue = amountMap.containsKey(eventId) ? amountMap.get(eventId) : 0;
            eventUpdates.add(new CAMPX__Event__c(Id = eventId, CAMPX__GrossRevenue__c = newGrossRevenue));
        }
    
        if (!eventUpdates.isEmpty()) {
            update eventUpdates;
        }
    }
    
}