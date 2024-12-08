trigger AcctUpdateTriggerRecrWithStaticSet on Account (after update) {
    system.debug('取引先トリガ実行');
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            AcctUpdateTriggerWithStaticSetHandler handler = new AcctUpdateTriggerWithStaticSetHandler();
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}