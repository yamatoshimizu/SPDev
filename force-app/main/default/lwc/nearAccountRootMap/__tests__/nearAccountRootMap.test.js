import { createElement } from 'lwc';
import GeoMap from 'c/geoMap';
import findNearbyAccounts from '@salesforce/apex/GeoLocationController.findNearbyAccounts';
import { getLocationService } from 'lightning/mobileCapabilities';

// モック化
jest.mock('@salesforce/apex/GeoLocationController.findNearbyAccounts', () => {
    return {
        default: jest.fn()
    };
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

describe('c-geo-map', () => {
    afterEach(() => {
        // DOMをクリーンアップ
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders map container', () => {
        // コンポーネントの作成
        const element = createElement('c-geo-map', {
            is: GeoMap
        });
        document.body.appendChild(element);

        // 地図の要素が存在することを確認
        const mapContainer = element.shadowRoot.querySelector('.map-container');
        expect(mapContainer).not.toBeNull();
    });

    it('fetches nearby accounts when getCurrentLocation is called', async () => {
        // モックされたレスポンス
        findNearbyAccounts.mockResolvedValue([
            {
                Id: '0011x000002fWvLAAU',
                Name: 'Nearby Account',
                Latitude__c: 37.7749,
                Longitude__c: -122.4194
            }
        ]);

        // コンポーネントの作成
        const element = createElement('c-geo-map', {
            is: GeoMap
        });
        document.body.appendChild(element);

        // ボタンのクリックをシミュレート
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        // 非同期処理の完了を待つ
        await Promise.resolve();

        // Apexメソッドが正しい引数で呼び出されたか確認
        expect(findNearbyAccounts).toHaveBeenCalledWith({ latitude: 37.7749, longitude: -122.4194 });

        // エラーが発生していないことを確認
        const errorMessage = element.shadowRoot.querySelector('.error');
        expect(errorMessage).toBeNull();
    });

    it('handles location service unavailability', async () => {
        // Location Serviceを利用不可に設定
        getLocationService.mockReturnValueOnce({
            isAvailable: jest.fn(() => false)
        });

        // コンポーネントの作成
        const element = createElement('c-geo-map', {
            is: GeoMap
        });
        document.body.appendChild(element);

        // ボタンのクリックをシミュレート
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        // 非同期処理の完了を待つ
        await Promise.resolve();

        // エラーが表示されていることを確認
        const errorMessage = element.shadowRoot.querySelector('.error');
        expect(errorMessage.textContent).toBe('Location Service is not available on this device.');
    });

    it('handles Apex errors gracefully', async () => {
        // Apexエラーをシミュレート
        findNearbyAccounts.mockRejectedValue(new Error('Apex error occurred'));

        // コンポーネントの作成
        const element = createElement('c-geo-map', {
            is: GeoMap
        });
        document.body.appendChild(element);

        // ボタンのクリックをシミュレート
        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        // 非同期処理の完了を待つ
        await Promise.resolve();

        // エラーが表示されていることを確認
        const errorMessage = element.shadowRoot.querySelector('.error');
        expect(errorMessage.textContent).toBe('Error fetching nearby accounts: Apex error occurred');
    });
});
