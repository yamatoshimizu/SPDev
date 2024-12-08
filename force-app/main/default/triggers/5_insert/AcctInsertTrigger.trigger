trigger AcctInsertTrigger on Account (after insert) {
    system.debug('取引先トリガ実行');
    switch on Trigger.OperationType {
        when AFTER_INSERT {
            AcctInsertTrigerHandler handler = new AcctInsertTrigerHandler();
            handler.handleAfterInsert(Trigger.new);
        }
    }
}