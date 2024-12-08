public with sharing class AcctUpdateTriggerWithStaticBoolHandler {

    public static Boolean runAccountUpdateTriggerOnce = true;

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
            mapAccountIdByAccount.put(acc.Id, acc);
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