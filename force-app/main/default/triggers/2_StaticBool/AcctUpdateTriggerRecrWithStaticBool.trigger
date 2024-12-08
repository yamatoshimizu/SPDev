trigger AcctUpdateTriggerRecrWithStaticBool on Account (after update) {
    system.debug('取引先トリガ実行');
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            if(
                //静的変数を確認。trueのときだけ実行する
                AcctUpdateTriggerWithStaticBoolHandler.runAccountUpdateTriggerOnce
            ) {
                //実行時、静的変数をfalseに変える
                AcctUpdateTriggerWithStaticBoolHandler.runAccountUpdateTriggerOnce = false;
                AcctUpdateTriggerWithStaticBoolHandler handler = new AcctUpdateTriggerWithStaticBoolHandler();
                handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
}