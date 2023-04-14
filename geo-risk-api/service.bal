import ballerina/http;
import ballerina/log;

type RiskRequest record {
    string ip;
};

type ipGeolocationResp record {
    string countryCode;
};

// API key from ipgeolocation.io
configurable string GEO_API_KEY = ?;
configurable string SAFE_COUNTRY_CODE = ?;

service / on new http:Listener(8090) {
    resource function post risk(@http:Payload RiskRequest req) returns http:Response|error? {

        string ip = req.ip;

        // Log the IP address
        log:printInfo(string`### DEBUG - Checking risk for IP: ${ip}`);

        http:Client ipGeolocation = check new ("http://ip-api.com");
        ipGeolocationResp geoResponse = check ipGeolocation->get(string `/json/${ip}?fields=countryCode`);

        // Log the country code
        log:printInfo(string`### DEBUG - Country code: ${geoResponse.countryCode}`);

        http:Response response = new ;
        response.setJsonPayload({hasRisk: geoResponse.countryCode != SAFE_COUNTRY_CODE});
        response.statusCode = 200;

        return response;
    }
}