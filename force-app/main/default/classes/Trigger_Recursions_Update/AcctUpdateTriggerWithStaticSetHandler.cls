public with sharing class AcctUpdateTriggerWithStaticSetHandler {

    public static Set<Id> setExecutedRecord = new Set<Id>();//静的セットを初期化

    public void handleAfterUpdate(
        List<Account> newAccounts,
        Map<Id, Account> oldAccountsMap
    ) {
        updateOpportunityAmountAfterDiscount(newAccounts, oldAccountsMap);
    }

    public void updateOpportunityAmountAfterDiscount(
        List<Account> newAccounts,
        Map<Id, Account> oldAccountsMap
    ) {
        Map<Id,Account> mapAccountIdByAccount = new Map<Id,Account>();
        List<Opportunity> LstOppToUpdate = new List<Opportunity>();
        for (Account acc : newAccounts) {
            //既に静的セットに取引先のIdが入っている場合は、トリガ対象に入れない
            if (!AcctUpdateTriggerWithStaticSetHandler.setExecutedRecord.contains(acc.Id)) {
                mapAccountIdByAccount.put(acc.Id, acc);
            }
            //実行した取引先のIdを静的セットに投入する
            AcctUpdateTriggerWithStaticSetHandler.setExecutedRecord.add(
                acc.Id
            );
        }
        for (Opportunity opp : [
            SELECT Amount, AccountId
            FROM Opportunity
            WHERE AccountId IN :mapAccountIdByAccount.keySet()
        ]) {
            Decimal discountPercentage = mapAccountIdByAccount.get(opp.AccountId).Discount_Percentage__c;
            //割引率をもとに金額を再計算
            Decimal discountAmount = opp.Amount * discountPercentage/100;
            opp.Amount = opp.Amount - discountAmount;
            LstOppToUpdate.add(opp);
        }
        update LstOppToUpdate;

        
        //for (Integer i = 0; i < 140; i++) {
          //  Account acc = new Account(Name = 'Test Account ' + i, Discount_Percentage__c = 0);
            //insert acc;
            //system.debug('DML発行'+(i+1) +'回目');
        //}
        
    }
}