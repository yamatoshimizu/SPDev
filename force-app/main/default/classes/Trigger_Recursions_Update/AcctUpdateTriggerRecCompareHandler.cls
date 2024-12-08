public with sharing class AcctUpdateTriggerRecCompareHandler {
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
            If (
                //更新前の割引率と更新後の割引率を比較
                acc.Discount_Percentage__c != null &&
                (acc.Discount_Percentage__c !=
                oldAccountsMap.get(acc.Id).Discount_Percentage__c)
            ) {
                mapAccountIdByAccount.put(acc.Id, acc);
            }
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
    }
}