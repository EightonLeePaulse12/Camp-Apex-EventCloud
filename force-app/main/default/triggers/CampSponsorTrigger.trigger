trigger CampSponsorTrigger on CAMPX__Sponsor__c (before insert, after insert, before update, after update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            SponsorTriggerHandler.OnBeforeInsert(Trigger.new);
            SponsorTriggerHandler.onBeforeInsertAndUpdate(Trigger.new);
        } else if(Trigger.isUpdate) {
            SponsorTriggerHandler.onBeforeInsertAndUpdate(Trigger.new);
        }
    }
}