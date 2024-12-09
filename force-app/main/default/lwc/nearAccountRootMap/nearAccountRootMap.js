import { LightningElement, track } from 'lwc';
import { getLocationService } from 'lightning/mobileCapabilities';
import findNearbyAccounts from '@salesforce/apex/GeoLocationController.findNearbyAccounts';

export default class GeoMap extends LightningElement {
    @track currentLocation = null;
    @track error = null;
    map;
    currentLocationMarker;
    directionsService;
    directionsRenderer;

    locationService = getLocationService();
    isGoogleMapsLoaded = false;

    renderedCallback() {
        if (!this.map && !this.isGoogleMapsLoaded) {
            this.loadGoogleMapsApi();
        }
    }

    loadGoogleMapsApi() {
        this.isGoogleMapsLoaded = true;
        const script = document.createElement('script');
        script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyDVvBKXs4OMaxCgjDGjZXmKzZtCCS1IZYc'; // 必ず適切なAPIキーを設定
        script.async = true;
        script.defer = true;

        script.onload = () => {
            this.initializeMap();
        };

        script.onerror = () => {
            this.error = 'Failed to load Google Maps API.';
            console.error('Google Maps API failed to load.');
        };

        document.head.appendChild(script);
    }

    initializeMap() {
        const mapElement = this.template.querySelector('#map');
        if (!mapElement) {
            console.error('Map element not found in the DOM.');
            return;
        }

        this.map = new google.maps.Map(mapElement, {
            center: { lat: 0, lng: 0 },
            zoom: 12
        });

        this.directionsService = new google.maps.DirectionsService();
        this.directionsRenderer = new google.maps.DirectionsRenderer();
        this.directionsRenderer.setMap(this.map);
    }

    async getCurrentLocation() {
        if (!this.locationService.isAvailable()) {
            this.error = 'Location Service is not available on this device.';
            return;
        }

        try {
            const location = await this.locationService.getCurrentPosition();
            const { latitude, longitude } = location.coords;

            this.currentLocation = { latitude, longitude };
            this.setMapCenter(latitude, longitude);
            await this.fetchNearbyAccounts(latitude, longitude);
        } catch (error) {
            this.error = `Error retrieving location: ${error.message}`;
        }
    }

    setMapCenter(lat, lng) {
        const location = { lat, lng };
        this.map.setCenter(location);

        if (this.currentLocationMarker) {
            this.currentLocationMarker.setMap(null);
        }

        this.currentLocationMarker = new google.maps.Marker({
            position: location,
            map: this.map,
            title: 'Your Location'
        });
    }

    async fetchNearbyAccounts(lat, lng) {
        try {
            const accounts = await findNearbyAccounts({ latitude: lat, longitude: lng });
            this.displayAccountsOnMap(accounts);
        } catch (error) {
            this.error = `Error fetching nearby accounts: ${error.message}`;
        }
    }

    displayAccountsOnMap(accounts) {
        if (!accounts || accounts.length === 0) {
            console.log('No nearby accounts found.');
            return;
        }

        accounts.forEach((account) => {
            const marker = new google.maps.Marker({
                position: { lat: account.Latitude__c, lng: account.Longitude__c },
                map: this.map,
                title: account.Name
            });

            marker.addListener('click', () => {
                this.displayRouteToAccount(account.Latitude__c, account.Longitude__c);
            });
        });
    }

    displayRouteToAccount(lat, lng) {
        const origin = this.currentLocationMarker.getPosition();
        const destination = { lat, lng };

        const request = {
            origin,
            destination,
            travelMode: google.maps.TravelMode.DRIVING
        };

        this.directionsService.route(request, (result, status) => {
            if (status === google.maps.DirectionsStatus.OK) {
                this.directionsRenderer.setDirections(result);
            } else {
                this.error = `Could not display route: ${status}`;
            }
        });
    }
}
