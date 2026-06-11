#include <Arduino.h>
#include <WiFi.h>
#include "http/http.h"
#include "wifi/wifi.h"

#define SENSOR_PIN 4
#define LED_PIN 2

bool lastState = false;

void setup()
{
  Serial.begin(115200);

  connect();

  pinMode(SENSOR_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
}

void loop()
{
  bool open = (digitalRead(SENSOR_PIN) == LOW);

  digitalWrite(LED_PIN, open ? HIGH : LOW);

  // solo envía si cambia estado
  if (open != lastState)
  {
    sendEvent(open);
    lastState = open;
  }

  delay(50);
}