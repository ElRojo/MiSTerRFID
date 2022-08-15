#include <MFRC522.h>
#include <SPI.h>

#define SS_PIN 10
#define RST_PIN 9

MFRC522 rfid(SS_PIN, RST_PIN);

MFRC522::MIFARE_Key key;

int codeRead = 0;
int cardBeenRead = 0;
bool writeCardPresent = 0;
uint32_t lastCardRead = 0;
uint32_t writeCard = 0;
int waitForIt = 0;
String uidString;
void cardLogic(String, uint32_t, bool);
void setup() {
  Serial.begin(9600);
  SPI.begin(); // Init SPI bus
  rfid.PCD_Init(); // Init MFRC522
  rfid.PCD_SetRegisterBitMask(rfid.RFCfgReg, (0x03 << 4));
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
void cardLogic(String fname, uint32_t cardid, bool writeCardBool) {
  digitalWrite(LED_BUILTIN, HIGH); 
  Serial.print(fname);
  Serial.println(cardid);
  lastCardRead = cardid;
  delay(1000); 
  digitalWrite(LED_BUILTIN, LOW);
  writeCardPresent = writeCardBool;
}

void readRFID()
{
  String fname;
  writeCard = 3817941294;
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

  if (writeCardPresent) {
    cardLogic(". rfid_write.sh ", cardid, 0);
  }
  else if (cardid == writeCard && cardid != lastCardRead) {
    cardLogic("writecard ", cardid, 1);
  }
  else if (cardid != writeCard && writeCardPresent == 0 && cardid != lastCardRead ) {
    cardLogic(". rfid_process.sh ", cardid, 0);
  }


  // Halt PICC
  rfid.PICC_HaltA();

  // Stop encryption on PCD
  rfid.PCD_StopCrypto1();
}