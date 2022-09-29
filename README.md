![MiSTer connected to a MiSTerCade and RFID scanner](./B3953F61-7AEA-49E9-952C-9B12067D3B29.jpeg)

Forked from: [javiwwweb/MisTerRFID](https://github.com/javiwwweb/MisTerRFID)
Most of the ReadMe below is copy/paste from javiwwweb. I have added some notes for my changes.

:heavy_exclamation_mark: ~~This code is built for use with games in the \_Arcade folder. I may expand this further at a later date.~~

Update 09/25/2022: This code _can_ be used to run games other than Arcade cores, but you cannot use the write_card on a game that has been booted using an mgl file. You must boot through the menu core.

Below are the currently supported file extensions/cores:

| Core    | Extension(s) |
| ------- | ------------ |
| PSX     | .cue .chd    |
| SNES    | .sfc .smc    |
| NES     | .nes         |
| NeoGeo  | .neo         |
| Genesis | .md .gen     |
| Arcade  | .mra         |

There may be bugs. Please report them as an issue if you run into any.
:heavy_exclamation_mark:

# Table of Contents

- [TL;DR Instructions](#tldr)
- [Hardware Needed](#hardware-needed)
- [Arduino Hardware Setup](#arduino-hardware-setup)
- [Write Card Setup](#write-card-setup)
- [MiSTer Setup](#mister-setup) -[Manually Adding Cores](#manually-adding-cores)
- [Use](#use)
  - [Assigning Games to Cards](#assigning-games-to-cards)
- [Known Issues](#known-issues)
- [Troubleshooting](#troubleshooting)

# MisTerRFID

Enables RFID card launching of games for MiSTer FPGA. Launches games without any menu being display using the MiSTer Game Launcher files (MGL) method. Must use a version of MiSTer from Feb 24, 2022 or after to support this method of launching.

_This version allows you to assign games to cards without needing to edit the `rfid_process.sh` file._

## Hardware Needed

- Arduino Nano V3.0
- RC522 RFID Card Reader Module Board (3.3V)
- Mi-fare door access cards
- MiSTer FPGA with the extra USB ports board.

## Arduino Hardware Setup

| RC522 Module Pin | Arduino Pin |
| ---------------- | ----------- |
| RST              | D9          |
| SDA              | D10         |
| MOSI             | D11         |
| MISO             | D12         |
| SCK              | D13         |
| VCC              | 3.3V        |
| GRD              | GRD         |

## Arduino Software Setup

- Download Arduino software
- Connect Arduino Nano
- Open misterrfid.ino
- Go to Tools -> Manage Libraries and search for MFRC522
- Install MFRC522
- Verify Installation and Upload

On your computer, attach the serial monitor to your Arduino and you should see it repeating `. rfid_process.sh noscan` about every second. As soon as your scan a RFID card, it should output `. rfid_process.sh 12345678`. The number is that card's unique ID. The reader will not scan the same card two times in a row. Make note of the card's unique id.

:warning: Skipping steps below will cause your code to not function! :warning:

If you find out that that you would like to extend the distance the card is picked up, You can adjust the receiver gain by editing line `21` of the `misterrfid.ino` and upload the code.

```
    rfid.PCD_SetRegisterBitMask(rfid.RFCfgReg, (0x03<<4)); // RFID Gain
```

The HEX 0x03 control the gain. In my case that was the value that would penetrate the wooden bezel and the glass at the perfect distance. You may need to adjust this value set the receiver's gain to your desired level

| Gain Values in HEX |
| ------------------ |
| 0x01 = 23 dB HEX   |
| 0x02 = 18 dB HEX   |
| 0x03 = 23 dB HEX   |
| 0x04 = 33 dB HEX   |
| 0x05 = 38 dB HEX   |
| 0x06 = 43 dB HEX   |
| 0x07 = 48 dB HEX   |

On your computer, attach the serial monitor to your Arduino and you should see it repeating `. rfid_process.sh noscan` about every second. As soon as your scan a RFID card, it should output `. rfid_process.sh 12345678`. The number is that card's unique ID. The reader will not scan the same card two times in a row, but you can scan another card, and then the original in order to see a card's number again.

### Write Card Setup

As you are gathering numbers from your cards or RFID tags, choose an RFID device that you'd like to use as a `write card` This card acts as a trigger to put your Arduino code into a loop that will run the `rfid_write.sh` file. The number of this RFID device needs to be replace `12346789` in `misterrfid.ino` at line `58`. After you have done this, overwrite your Arduino with the new code. Set that card aside for later.

```
  const uint32_t wCard = 123456789;

```

## MiSTer Setup

Copy the files to your MiSTer SD card based on the structure of this repo. ATTENTION: Make sure you don't overwrite user-startup.sh if you have other services running like Favorites, Super Attract Mode or TTY2OLED. If you use TTY2OLED, make sure you assign the right ttydev to the right device.

### Manually Adding Cores

Although the preferred method for adding games is by using the `write card`, you can manually add games to `game_list_rfid.conf` for unsupported files or if you find it easier/quicker.

- Gather card numbers using the arduino serial monitor
- If the game is an arcade core (.mra extension):
  - use the absolute path for the .mra file. Please see the example below.
- If the game is _not_ an arcade core:
  - create an [mgl file](https://mister-devel.github.io/MkDocs_MiSTer/advanced/mgl/) for the game
  - You can create these almost anywhere, but I recommend creating them the same place that `rfid_write.sh` would, which is: `/media/fat/games/CORE/GameFolder/Game.extension.mgl` An example MGL is shown below.
- Starting on line 4 of `game_list_rfid.conf` add games using the following format. Please be advised that the space between `CARDNUMBER` and `echo` is a TAB, not spaces.

### Manual Console Core Example

```
CARDNUMBER	echo load_core "/absolute/path/to/.ext.mgl" > /MiSTer_cmd
1452135431	echo load_core "/media/fat/games/PSX/Crash Bandicoot/Crash Bandicoot.cue.mgl" > /MiSTer_cmd
```

### Manual Arcade Core Example

```
CARDNUMBER	echo load_core "/absolute/path/to/arcade/.mra" > /MiSTer_cmd
5132153135	echo load_core "/media/fat/_Arcade/1942.mra" > /MiSTer_cmd
```

### MGL Example

The filename of this example would be: `Crash Bandicoot.cue.mgl`
The absolute filepath of this example would be: `/media/fat/games/PSX/Crash Bandicoot/Crash Bandicoot.cue.mgl`

```
<mistergamedescription>
<rbf>_Console/PSX</rbf>
<file delay="2" type="f" index="0" path="../../games/PSX/Crash Bandicoot/Crash Bandicoot.cue"/>
</mistergamedescription>
```

## Use

After editing the `rfid_process.sh` script, turn off your MiSTer. Plug your Arduino into an available USB port on your USB board module and turn on your MiSTer. Depending on how many scripts you have running, it can take up to 30 seconds from first turning on the power to the RFID reader becoming available. Once the RFID is available, you can start lunching games (if you added cases to the `rfid_process.sh` file), or begin [Assigning Games to Cards](#Assigning-Games-to-Cards)

Note: This can be combined with MisTer.ini option bootcore= to automatically launch an arcade core (MRA file) upon starting up your MisTer. The `rfid_process.sh` will run in the background waiting for a card to be presented.

## Assigning Games to Cards

First, launch a game using the core menu. Once the game has booted, scan your `write card`. This will tell the Arduino that it needs to run the `rfid_write.sh` file on the next card scan. Scan a new (or already assigned) card. The card will be programaticaly added to `rfid_process.sh` and the next time you scan that card, it will boot the game. Remember that you cannot scan the same card twice, though. Scan a different card before scanning the just-written one in order to test it.

_Cards can be overwritten. If you attempt to scan a card that is already added to the `rfid_process.sh` file, the entry will be deleted and then reassigned to the new game. You can do this as often as you'd like._

## Known Issues

~~Games with two spaces in the name are having one of the spaces removed as the game name is passed through the string manipulation logic.~~
~~E.g.~~

```
Street Fighter II'  Champion Edition -World 920513- -> Street Fighter II' Champion Edition -World 920513-
```

~~This makes the MiSTer unable to find the rbf file. Some regex will probably fix this. I'll revisit it soon.~~

This seems to be fixed.

NeoGeo games do not currently work. They can be manually added, though.

## Troubleshooting

- If your cards don't seem to be scanning in MiSTer, make sure that `serial_listen.sh` actually started. I have had issues with that not booting in the past. Re-imaging my SD card takes care of this if nothing else.
- If games aren't being added to the right spot, or being injected in odd places in `rfid_process.sh` make sure you didn't inadvertently move the `case` statement. Read [MiSTer Setup](#MiSTer-Setup).
- If your write card doesn't function. Make sure you added the card number to the Arduino code **and** re-uploaded after making that change.

## TL;DR

- Set up your Arduino and MFRC522

| RC522 Module Pin | Arduino Pin |
| ---------------- | ----------- |
| RST              | D9          |
| SDA              | D10         |
| MOSI             | D11         |
| MISO             | D12         |
| SCK              | D13         |
| VCC              | 3.3V        |
| GRD              | GRD         |

- Write the code to the Arduino
- Pick a card to be the `write card` and jot down the number
- Replace the value for `const uint32_t wCard` in `misterrfid.ino` with your card number
- Re-write to the arduino
- Add Scripts files to the `Scripts` folder on the MiSTer, as well as the linux file

### THANK YOU

_Thanks to illusion-pasture-program and javiwwweb for the initial code and ideas._
_Thanks to @[mrchrisster](https://github.com/mrchrisster) for their clarifications in the ReadMe and @[coded-with-claws](https://github.com/coded-with-claws) for their contribution for the new `rfid_process.sh` code!_
