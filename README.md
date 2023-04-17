# Light Control

Discovery project for my ECE 1100 class at Georgia Tech. It consists of two parts, the microcontroller code and the Flutter application.

## Microcontroller

- The Microcontroller code is designed for the XIAO ESP32C3 SeedStudio board and an AdaFruit NeoPixel Digital 30 LED Strip connected on DIO pin 10.
- It starts a Bluetooth server under the name Light Control.
- Once connected, there's one service that allows write characteristics.
- There are 4 commands available which the microcontroller expects as a string:
  - on - Turns all the LED lights on to white
  - off - Turns all the LED lights off to black
  - set afafaf 00 - Turns the LED at the specified index to the color
  - setAll afafaf - Turns all the LEDs to the specified color

## Phone Application

- Built with Flutter
- It is currently designed and built for iOS only