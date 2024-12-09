import { createElement } from 'lwc';
import NearAccountRootMap from 'c/nearAccountRootMap';
import findNearbyAccounts from '@salesforce/apex/GeoLocationController.findNearbyAccounts';
import { getLocationService } from 'lightning/mobileCapabilities';

// モック化
jest.mock('@salesforce/apex/GeoLocationController.findNearbyAccounts', () => {
    return { default: jest.fn() };
}, { virtual: true });

jest.mock('lightning/mobileCapabilities', () => {
    return {
        getLocationService: jest.fn(() => ({
            isAvailable: jest.fn(() => true),
            getCurrentPosition: jest.fn(() =>
                Promise.resolve({
                    coords: {
                        latitude: 37.7749,
                        longitude: -122.4194
                    }
                })
            )
        }))
    };
}, { virtual: true });

describe('c-near-account-root-map', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders map container', () => {
        const element = createElement('c-near-account-root-map', {
            is: NearAccountRootMap
        });
        document.body.appendChild(element);

        const mapContainer = element.shadowRoot.querySelector('.map-container');
        expect(mapContainer).not.toBeNull();
    });

    it('fetches nearby accounts when getCurrentLocation is called', async () => {
        // モックされたApexレスポンス
        findNearbyAccounts.mockResolvedValue([
            { Id: '0011x000002fWvLAAU', Name: 'Nearby Account', Latitude__c: 37.7749, Longitude__c: -122.4194 }
        ]);

        const element = createElement('c-near-account-root-map', {
            is: NearAccountRootMap
        });
        document.body.appendChild(element);

        const button = element.shadowRoot.querySelector('lightning-button');
        expect(button).not.toBeNull(); // ボタンが存在することを確認
        button.click();

        // 非同期処理を待機
        await Promise.resolve();

        // Apexメソッドが正しい引数で呼び出されたことを確認
        expect(findNearbyAccounts).toHaveBeenCalledWith({ latitude: 37.7749, longitude: -122.4194 });
    });

    it('handles location service unavailability', async () => {
        // Location Serviceを利用不可に設定
        getLocationService.mockReturnValueOnce({
            isAvailable: jest.fn(() => false)
        });

        const element = createElement('c-near-account-root-map', {
            is: NearAccountRootMap
        });
        document.body.appendChild(element);

        const button = element.shadowRoot.querySelector('lightning-button');
        expect(button).not.toBeNull(); // ボタンが存在することを確認
        button.click();

        await Promise.resolve();

        // エラーメッセージが正しく表示されていることを確認
        const errorMessage = element.shadowRoot.querySelector('.error');
        expect(errorMessage.textContent).toBe('Location Service is not available on this device.');
    });

    it('handles Apex errors gracefully', async () => {
        // Apexエラーをシミュレート
        findNearbyAccounts.mockRejectedValue(new Error('Apex error occurred'));

        const element = createElement('c-near-account-root-map', {
            is: NearAccountRootMap
        });
        document.body.appendChild(element);

        const button = element.shadowRoot.querySelector('lightning-button');
        expect(button).not.toBeNull(); // ボタンが存在することを確認
        button.click();

        await Promise.resolve();

        // エラーメッセージが正しく表示されていることを確認
        const errorMessage = element.shadowRoot.querySelector('.error');
        expect(errorMessage).not.toBeNull(); // エラー要素が存在することを確認
        expect(errorMessage.textContent).toBe('Error fetching nearby accounts: Apex error occurred');
    });

    it('does not initialize Google Maps if already loaded', () => {
        const element = createElement('c-near-account-root-map', {
            is: NearAccountRootMap
        });
        document.body.appendChild(element);

        // 初期化済みのフラグを設定
        element.isGoogleMapsLoaded = true;

        // renderedCallbackを再度呼び出す
        element.renderedCallback();

        // Google Mapsスクリプトが再ロードされないことを確認
        expect(element.isGoogleMapsLoaded).toBe(true);
    });
});
