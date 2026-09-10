#include "config.h"
#include "http.h"
#include "jwt.h"
#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>

const char *serverUrl = SERVER_URL;

void sendEvent(bool state, String sensor)
{
    if (WiFi.status() != WL_CONNECTED)
        return;

    HTTPClient http;

    http.begin(serverUrl + String("sensors/") + sensor + String("/trigger"));
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Authorization", String("Bearer ") + createJwt());

    String payload = String("{\"state\":\"") + (state ? "CLOSED" : "OPENED") + "\"}";

    int code = http.POST(payload);

    Serial.println(code);
    http.end();
}