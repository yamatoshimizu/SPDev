trigger AcctUpdateTriggerRecursion on Account (after update) {
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            AcctUpdateTriggerRecursionHandler handler = new AcctUpdateTriggerRecursionHandler();
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}