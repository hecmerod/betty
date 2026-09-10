#include <Arduino.h>
#include <WiFi.h>
#include "http/http.h"
#include "wifi/wifi.h"
#include "sensors/movement_sensor.h"
#include "sensors/door_sensor.h"

#define SENSOR_PIN 4
#define MOVEMENT_SENSOR_PIN 5
#define LED_PIN 2

void setup()
{
  Serial.begin(115200);

  connect();

  pinMode(SENSOR_PIN, INPUT_PULLUP);
  pinMode(MOVEMENT_SENSOR_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
}

void loop()
{
  detectMovement();
  detectChanges();

  delay(50);
}