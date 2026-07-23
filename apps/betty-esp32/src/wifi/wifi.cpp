#include "wifi.h"
#include <Arduino.h>
#include <WiFi.h>

const char *ssid = "";
const char *password = "";

void connect()
{
    WiFi.mode(WIFI_STA);
    WiFi.setSleep(false);
    WiFi.disconnect(true);
    delay(1000);

    WiFi.begin(ssid, password);

    Serial.println("Conectando WiFi...");

    int retries = 0;

    while (WiFi.status() != WL_CONNECTED && retries < 20)
    {
        delay(500);
        Serial.print(".");
        retries++;
    }

    if (WiFi.status() == WL_CONNECTED)
    {
        Serial.println("\nWiFi connected!");
        Serial.println(WiFi.localIP());
    }
    else
    {
        Serial.println("\nWiFi FAILED");
        Serial.println(WiFi.status());
    }
}