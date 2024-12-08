trigger AcctUpdateTriggerRecComparingOldvsNew on Account (after update) {
    system.debug('取引先トリガ実行');
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            AcctUpdateTriggerRecCompareHandler handler = new AcctUpdateTriggerRecCompareHandler();
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}