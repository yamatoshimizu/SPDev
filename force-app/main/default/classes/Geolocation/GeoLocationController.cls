public with sharing class GeoLocationController {
    @AuraEnabled(cacheable=true)
    public static List<Account> findNearbyAccounts(Double latitude, Double longitude) {
        // Radius in kilometers
        Double radius = 10.0;

        // Check for null inputs to prevent query issues
        if (latitude == null || longitude == null) {
            throw new IllegalArgumentException('Latitude and Longitude must not be null.');
        }

        // Query accounts within the specified radius
        List<Account> nearbyAccounts = [
            SELECT Id, Name, Location__Latitude__s, Location__Longitude__s
            FROM Account
            WHERE DISTANCE(Location__c, GEOLOCATION(:latitude, :longitude), 'km') < :radius
        ];

        return nearbyAccounts;
    }
}
