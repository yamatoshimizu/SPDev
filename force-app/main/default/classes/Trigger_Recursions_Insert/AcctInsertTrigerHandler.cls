public with sharing class AcctInsertTrigerHandler {

    public static Boolean isAccountInsertTriggerRunnningToCreateTask = false;

    public void handleAfterInsert(List<Account> newAccounts) {
        createFollowUpTask(newAccounts);
    }

    public void createFollowUpTask(List<Account> newAccounts){
        //静的変数がtrueの場合は処理を終了する
        if (AcctInsertTrigerHandler.isAccountInsertTriggerRunnningToCreateTask) {
            return;
        }
        //DML操作をする前に静的変数をtrueに変更する
        //これにより、タスクの作成後に取引先のトリガを起動しなくなる
        AcctInsertTrigerHandler.isAccountInsertTriggerRunnningToCreateTask = true;
        List<Task> newTasks = new List<Task>();
        for (Account acc : newAccounts) {
            String competitorName = acc.Competitor_Name__c ?? '';
            Task followUpTask = new Task();
            followUpTask.WhatId = acc.Id;
            followUpTask.Subject = acc.Name+'への電話';
            followUpTask.OwnerId = acc.OwnerId;
            followUpTask.ActivityDate = System.today().addDays(7);
            followUpTask.Status = 'Not Started';
            followUpTask.Account_Competitor_Name__c = competitorName;
            newTasks.add(followUpTask);
        }
        if (!newTasks.isEmpty()) {
            insert newTasks;
        }

        //静的変数をコードの最後でリセットする
        //これにより、次の200件のバッチでトリガが実行されるようになる
        AcctInsertTrigerHandler.isAccountInsertTriggerRunnningToCreateTask = false;
    }
}