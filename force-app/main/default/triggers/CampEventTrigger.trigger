trigger CampEventTrigger on CAMPX__Event__c (before insert, after insert, before update, after update) {

    EventTriggerHandler updater = new EventTriggerHandler();

        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                EventTriggerHandler.onBeforeInsert(Trigger.new);
            }
        } else {
            if(Trigger.isInsert || Trigger.isUpdate) {
                EventTriggerHandler.onAfterInsertAndUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }