trigger CampSponsorTrigger on CAMPX__Sponsor__c (before insert, after insert, before update, after update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            SponsorTriggerHandler.handleBeforeInsert(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isUpdate) {
            SponsorTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}