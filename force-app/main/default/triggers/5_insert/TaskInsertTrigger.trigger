trigger TaskInsertTrigger on Task (after insert) {
    switch on Trigger.OperationType {
        when AFTER_INSERT {
            TaskInsertTriggerHandler handler = new TaskInsertTriggerHandler();
            handler.handleAfterInsert(Trigger.new);
        }
    }
}