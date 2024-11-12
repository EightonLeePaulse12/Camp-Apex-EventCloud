trigger CampSponsorTrigger on CAMPX__Sponsor__c (before insert, after insert, before update, after update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            SponsorTriggerHandler.OnBeforeInsert(Trigger.new);
        }
    } else {
        // if(Trigger.isInsert || Trigger.isUpdate) {
        //     SponsorTriggerHandler.onAfterInsertAndUpdate(Trigger.new, Trigger.oldMap);
        // }
    }
}