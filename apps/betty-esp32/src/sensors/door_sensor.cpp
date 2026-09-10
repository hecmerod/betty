#include "config.h"
#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include "http/http.h"

#define SENSOR_PIN 4

bool lastState = false;

void detectChanges()
{
    bool open = (digitalRead(SENSOR_PIN) == LOW);

    // digitalWrite(LED_PIN, open ? HIGH : LOW);

    if (open != lastState)
    {
        Serial.println(open ? "Puerta abierta" : "Puerta cerrada");
        sendEvent(open, String("door_claraboyas"));
        lastState = open;
    }
}