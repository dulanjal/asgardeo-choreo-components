import ballerina/http;
import ballerina/log;
import ballerina/time;

type RiskRequest record {
    string ip;
    string allowedCountryCode;
};

type ipGeolocationResp record {
    string countryCode;
};

service / on new http:Listener(8090) {
    resource function post risk(@http:Payload RiskRequest req) returns http:Response|error? {

        string ip = req.ip;
        string allowedCountryCode = req.allowedCountryCode;

        // Log the IP address and allowed country code
        log:printInfo(string`### DEBUG - Checking risk for IP: ${ip}`);
        log:printInfo(string`### DEBUG - Allowed country code for users: ${allowedCountryCode}`);

        time:Utc t1 = time:utcNow();

        http:Client ipGeolocation = check new ("http://ip-api.com");
        ipGeolocationResp geoResponse = check ipGeolocation->get(string `/json/${ip}?fields=countryCode`);
        
        time:Utc t2 = time:utcNow();
        log:printInfo(string`### DEBUG - Time taken to call the external API: ${time:utcDiffSeconds(t2, t1)}`);

        // Log the country code
        log:printInfo(string`### DEBUG - Country code returned from Geolocation Service ip-api.com: ${geoResponse.countryCode}`);

        boolean hasRisk = geoResponse.countryCode != allowedCountryCode;
        // Log risk status
        log:printInfo(string`### DEBUG - Has risk? ${hasRisk}`);

        http:Response response = new ;
        response.setJsonPayload({hasRisk});
        response.statusCode = 200;

        return response;
    }
}