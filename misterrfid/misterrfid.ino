#include <MFRC522.h>
#include <SPI.h>

#define SS_PIN 10
#define RST_PIN 9

MFRC522 rfid(SS_PIN, RST_PIN); // Instance of the class

MFRC522::MIFARE_Key key;

int codeRead = 0;
int cardBeenRead = 0;
int writeCardPresent = 0;
uint32_t lastCardRead = 0;
uint32_t writeCard = 0;
int waitForIt = 0;
String uidString;
void setup() {
  writeCard = 3817941294;
  Serial.begin(9600);
  SPI.begin(); // Init SPI bus
  rfid.PCD_Init(); // Init MFRC522
  rfid.PCD_SetRegisterBitMask(rfid.RFCfgReg, (0x05 << 4));
  pinMode(8, OUTPUT);
  pinMode(A0, OUTPUT);
  Serial.println("loaded");
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
}

void loop() {
  if ((waitForIt == 0) && (cardBeenRead == 0)) {
    Serial.println(". rfid_process.sh noscan");
  }

  waitForIt++;

  if (waitForIt >= 9) {
    waitForIt = 0;
  }

  if (  rfid.PICC_IsNewCardPresent())
  {
    readRFID();
  }
  delay(100);
}

void readRFID()
{
  rfid.PICC_ReadCardSerial();
  MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);

  if (piccType != MFRC522::PICC_TYPE_MIFARE_MINI &&
      piccType != MFRC522::PICC_TYPE_MIFARE_1K &&
      piccType != MFRC522::PICC_TYPE_MIFARE_4K) {
    //tag is a MIFARE Classic."
    return;
  }

  uint32_t cardid = rfid.uid.uidByte[0];
  cardid <<= 8;
  cardid |= rfid.uid.uidByte[1];
  cardid <<= 8;
  cardid |= rfid.uid.uidByte[2];
  cardid <<= 8;
  cardid |= rfid.uid.uidByte[3];
  
  cardBeenRead = 1;

  if (cardid == writeCard)
  {
    digitalWrite(LED_BUILTIN, HIGH);
    lastCardRead = cardid;
    writeCardPresent = 1;
    delay(1000);
    digitalWrite(LED_BUILTIN, LOW);
  }

  if (writeCardPresent == 1) {
  rfid.PICC_ReadCardSerial();
  MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);

  if (piccType != MFRC522::PICC_TYPE_MIFARE_MINI &&
      piccType != MFRC522::PICC_TYPE_MIFARE_1K &&
      piccType != MFRC522::PICC_TYPE_MIFARE_4K) {
    return;
  }

  uint32_t cardid = rfid.uid.uidByte[0];
  cardid <<= 8;
  cardid |= rfid.uid.uidByte[1];
  cardid <<= 8;
  cardid |= rfid.uid.uidByte[2];
  cardid <<= 8;
  cardid |= rfid.uid.uidByte[3];
  

    cardBeenRead = 1;
    
    if (cardid != lastCardRead) {
    digitalWrite(LED_BUILTIN, HIGH);   
    Serial.print(". rfid_write.sh ");
    Serial.println(cardid);
    lastCardRead = cardid;
    delay(1000);                       
    digitalWrite(LED_BUILTIN, LOW);   
    writeCardPresent = 0;
    }
  
  }

  if (cardid != lastCardRead) {
    digitalWrite(LED_BUILTIN, HIGH);   
    Serial.print(". rfid_process.sh ");
    Serial.println(cardid);
    lastCardRead = cardid;
    delay(1000);                       
    digitalWrite(LED_BUILTIN, LOW);   
  }


  rfid.PICC_HaltA();


  rfid.PCD_StopCrypto1();
}