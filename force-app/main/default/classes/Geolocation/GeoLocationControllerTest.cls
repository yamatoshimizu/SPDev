@isTest
public class GeoLocationControllerTest {
    @isTest
    static void testFindNearbyAccounts() {
        // テストデータの作成
        Account nearbyAccount = new Account(
            Name = 'Nearby Account',
            Location__Latitude__s = 37.7749, // サンフランシスコの緯度
            Location__Longitude__s = -122.4194 // サンフランシスコの経度
        );
        insert nearbyAccount;

        Account farAccount = new Account(
            Name = 'Far Account',
            Location__Latitude__s = 34.0522, // ロサンゼルスの緯度
            Location__Longitude__s = -118.2437 // ロサンゼルスの経度
        );
        insert farAccount;

        // テスト対象のメソッド呼び出し
        Test.startTest();
        List<Account> results = GeoLocationController.findNearbyAccounts(37.7749d, -122.4194d); // サンフランシスコの位置
        Test.stopTest();

        // アサーション: 結果に近いアカウントのみ含まれていることを確認
        System.assertEquals(1, results.size(), 'There should be only one nearby account.');
        System.assertEquals('Nearby Account', results[0].Name, 'The nearby account should be returned.');
    }

    @isTest
    static void testFindNearbyAccountsNullInputs() {
        // テスト: null値が渡された場合の例外処理
        try {
            Test.startTest();
            GeoLocationController.findNearbyAccounts(null, null);
            Test.stopTest();
            System.assert(false, 'An exception should have been thrown for null inputs.');
        } catch (Exception e) {
            System.assertEquals('Latitude and Longitude must not be null.', e.getMessage(), 'The exception message should match.');
        }
    }
}
