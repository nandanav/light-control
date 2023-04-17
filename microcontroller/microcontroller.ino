#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <Adafruit_NeoPixel.h>

#define RED strip.Color(255, 0, 0)
#define GREEN strip.Color(0, 255, 0)
#define BLUE strip.Color(0, 0, 255)
#define WHITE strip.Color(255, 255, 255)
#define BLACK strip.Color(0, 0, 0)

#define LED_PIN 10
#define LED_COUNT 30
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);


#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer *pServer;

void show(uint32_t color) {
  strip.fill(color, 0, 29);
  strip.show();
}

void showLED(uint8_t led, uint32_t color) {
  strip.setPixelColor(led, color);
  strip.show();
}

class MyCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    // raw data packet: 
    std::string value = pCharacteristic->getValue();
    if (value.length() > 0) {
      if (value == "on") {
        show(WHITE);
      } else if (value == "red") {
        show(RED);
      } else if (value == "off") {
        show(BLACK);
      } else if (value.substr(0, 6) == "setAll") {
        Serial.println("Setting custom color");

        Serial.println(std::stoi(value.substr(7, 2), 0, 16));        
        
        uint8_t red = std::stoi(value.substr(7, 2), 0, 16);
        uint8_t green = std::stoi(value.substr(9, 2), 0, 16);
        uint8_t blue = std::stoi(value.substr(11, 2), 0, 16);

        show(strip.Color(red, green, blue));
      } else if (value.substr(0, 3) == "set") {
        uint8_t red = std::stoi(value.substr(4, 2), 0, 16);
        uint8_t green = std::stoi(value.substr(6, 2), 0, 16);
        uint8_t blue = std::stoi(value.substr(8, 2), 0, 16);

        uint8_t led = std::stoi(value.substr(11, 2));
        showLED(led, strip.Color(red, green, blue));
      }
      Serial.println("*******");
      Serial.print("New Value: ");
      for (int i = 0; i < value.length(); i++) {
        Serial.print(value[i]);
      }

      Serial.println();
      Serial.println("*******");
    }
  }
};

class ServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer, esp_ble_gatts_cb_param_t* param) {
    // std::map<uint16_t, conn_status_t> clients = pServer->getPeerDevices(true);
    // Serial.println(">> New Connection");

    // for (std::map<uint16_t, conn_status_t>::iterator it = clients.begin(); it != clients.end(); ++it) {
    //   Serial.printf("Device: %s %s\n", it->first, it->second);
    // }
    for (int i = 0; i < 3; i++) {
      show(GREEN);
      sleep(1);
      show(BLACK);
      sleep(1);
    }
    Serial.println("<< New Connection");
  }

  void onDisconnect(BLEServer* pServer) {
    Serial.println(">> Disconnected");
    for (int i = 0; i < 3; i++) {
      show(RED);
      sleep(1);
      show(BLACK);
      sleep(1);      
    }
    Serial.println("<< Disconnected");
  }
};

void setup() {
  // put your setup code here, to run once:
  strip.begin();
  strip.show();
  Serial.begin(115200);

  BLEDevice::init("Light Control");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                        );

  pCharacteristic->setCallbacks(new MyCallbacks());

  pCharacteristic->setValue("Hello, World!");
  pService->start();

  BLEAdvertising *pAdvertising = pServer->getAdvertising();

  BLEAdvertisementData advertisementData = BLEAdvertisementData();
  advertisementData.setName("Light Control");

  pAdvertising->setScanResponseData(advertisementData);

  pAdvertising->start();
  
}

void loop() {
  // put your main code here, to run repeatedly:
  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  BLEAdvertisementData advertisementData = BLEAdvertisementData();
  advertisementData.setName("Light Control");

  pAdvertising->setScanResponseData(advertisementData);

  if (pServer->getConnectedCount() == 0) {
    pAdvertising->start();
  }
  
  delay(2000);
}


