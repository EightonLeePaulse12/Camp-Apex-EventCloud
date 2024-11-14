trigger CampEventTrigger on CAMPX__Event__c (before insert, after insert, before update, after update) {

    EventTriggerHandler updater = new EventTriggerHandler();

        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                EventTriggerHandler.onBeforeInsertAndUpdate(Trigger.new);
                EventTriggerHandler.onAfterInsertAndUpdate(Trigger.new, null);
            } 
            if(Trigger.isUpdate) {
                EventTriggerHandler.onBeforeInsertAndUpdate(Trigger.new);
                EventTriggerHandler.onAfterInsertAndUpdate(Trigger.new, null);
            }
        }
        if(Trigger.isAfter) {
            if(Trigger.isInsert || Trigger.isUpdate) {
                // EventTriggerHandler.onAfterInsertAndUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }