public with sharing class AcctUpdateTriggerRecursionHandler {
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
            //処理対象をマップに投入
            mapAccountIdByAccount.put(acc.Id, acc);
        }
        //取引先の子商談を抽出してループ
        for (Opportunity opp : [
            SELECT Amount, AccountId
            FROM Opportunity
            WHERE AccountId IN :mapAccountIdByAccount.keySet()
        ]) {
            //割引率をもとに金額を再計算
            Decimal discountPercentage = mapAccountIdByAccount.get(opp.AccountId).Discount_Percentage__c;
            Decimal discountAmount = opp.Amount * discountPercentage/100;
            opp.Amount = opp.Amount - discountAmount;
            LstOppToUpdate.add(opp);
        }
        //商談を更新
        update LstOppToUpdate;
    }
}