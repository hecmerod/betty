#include "config.h"
#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include "http/http.h"

#define MOVEMENT_SENSOR_PIN 5

int lastDetection;

void detectMovement()
{
    int currentDetection = digitalRead(MOVEMENT_SENSOR_PIN);

    if (lastDetection == currentDetection)
        return;

    if (currentDetection == HIGH)
    {
        lastDetection = HIGH;
        sendEvent(true, String("movement_sensor"));
    }
    else
    {
        lastDetection = LOW;
        sendEvent(false, String("movement_sensor"));
    }
}