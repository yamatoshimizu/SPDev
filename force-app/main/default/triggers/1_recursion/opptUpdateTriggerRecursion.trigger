trigger opptUpdateTriggerRecursion on Opportunity (after update) {
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            OpportunityTriggerRecursionHandler handler = new OpportunityTriggerRecursionHandler();
            handler.handleAfterUpdate(Trigger.new);
        }
    }
}