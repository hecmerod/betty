#include "http.h"
#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>

const char *serverUrl = "http://192.168.1.232:3000/api/sensors/door_claraboyas/trigger";

void sendEvent(bool closed)
{
    if (WiFi.status() != WL_CONNECTED)
        return;

    HTTPClient http;

    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/json");

    String payload = String("{\"state\":\"") + (closed ? "CLOSED" : "OPENED") + "\"}";

    int code = http.POST(payload);

    http.end();
}