@isTest
private class AccountTriggerTest {
    @isTest static void testRecursiveControl() {

        Decimal DISCOUNT_PERCENTAGE = 10;
        Decimal OPPORTUNITY_AMOUNT = 1000;

        List<Account> accounts = new List<Account>();
        // 取引先300件の作成
        for (Integer i = 0; i < 300; i++) {
            Account acc = new Account(Name = 'Test Account ' + i, Discount_Percentage__c = 5);
            accounts.add(acc);
        }
        insert accounts;

        // 各取引先に紐づく商談を1件ずつ作成
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Account acc : accounts) {
            Opportunity opp = new Opportunity(Name = acc.Name + ' Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30), AccountId = acc.Id, Amount = OPPORTUNITY_AMOUNT);
            opportunities.add(opp);
        }
        insert opportunities;

        Test.startTest();

        // 取引先のDiscount_Persentage__cを更新
        for (Account acc : accounts) {
            acc.Discount_Percentage__c = DISCOUNT_PERCENTAGE; // 例として10%の割引率を設定
        }
        update accounts;

        Test.stopTest();

        // 検証: 取引先が正しく更新され、関連する商談が影響を受けていないことを確認
        Decimal expectedDiscountAmount = OPPORTUNITY_AMOUNT * DISCOUNT_PERCENTAGE / 100;
        Decimal expectedUpdateAmount = OPPORTUNITY_AMOUNT - expectedDiscountAmount;

        for (Opportunity updatedOpportunity : [SELECT Amount FROM Opportunity WHERE Id IN :opportunities]) {
            System.Assert.areEqual(expectedUpdateAmount, updatedOpportunity.Amount, '金額が正しく更新されていません');
        } 
    }
}