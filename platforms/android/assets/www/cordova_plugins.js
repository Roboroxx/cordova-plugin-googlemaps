cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/plugin.google.maps/www/googlemaps-cdv-plugin.js",
        "id": "plugin.google.maps.phonegap-googlemaps-plugin",
        "clobbers": [
            "plugin.google.maps"
        ]
    },
    {
        "file": "plugins/plugin.google.maps.experimental/www/marker-cluster.js",
        "id": "plugin.google.maps.experimental.markercluster",
        "clobbers": [
            "plugin.experimental"
        ]
    },
    {
        "file": "plugins/plugin.http.request/www/http-request.js",
        "id": "plugin.http.request.phonegap-http-requst",
        "clobbers": [
            "cordova.plugins.http-request"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "plugin.google.maps": "1.2.6",
    "plugin.google.maps.experimental": "0.1",
    "org.apache.cordova.console": "0.2.13",
    "plugin.http.request": "1.0.4",
    "com.google.playservices": "23.0.0"
}
// BOTTOM OF METADATA
});