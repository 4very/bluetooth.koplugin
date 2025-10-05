
# Bluetooth Page Turner Support for Kobo

This plugin allows the user to turn Bluetooth on/off and connect a Bluetooth device to be connected on Kobo devices.

## How it Works

This plugin adds the menu "Gear > Network > Bluetooth" which includes:
* Bluetooth On
* Bluetooth Off

On Bluetooth On, the system will turn on WiFi (which is required for Bluetooth) and Bluetooth, then attempt to establish a connection to an input device previously paired on `/dev/input/event3`.

The initial pairing can be done either using Nickel's native Bluetooth menu, or via SSH/bluetoothctl.

The plugin will also add the `uhid.ko` kernel patch, which is a requirement for certain Bluetooth devices to be recognized.

## New Actions

### Refresh Device Input
**Description:** This command allows the device to start listening to input from connected devices again if the connection was lost and then automatically re-established. This is useful in situations where the Kobo device loses connection but reconnects automatically, and input events aren't being recognized.

### Connect to Device
**Description:** Sometimes Kobo devices do not automatically initiate the connection to an available Bluetooth device (e.g., 8bitdo micro). This command sends a connection request from the Kobo to the Bluetooth device. It requires the `connect.sh` script to be configured with your device’s MAC address, which can be obtained using the `bluetoothctl info` command.

## New Passive Features

With the current version of the code, there should be no reason to restart KOReader.

### Gesture Integration
All commands can now be triggered using taps and gestures. This enhances the user experience by allowing easy access to commands through customizable gestures. *Recommendation:* Bind the reconnect and relisten events to swipe gestures or similar actions for quick access.

### Automatic Listening
Once a device establishes a connection, it will now be automatically listened to without the need to reboot the device. This eliminates the previous requirement of restarting KOReader after enabling Bluetooth.

## Bank System

The plugin now features a **Bank System** that allows you to use the same physical buttons for different functions by switching between banks. This is perfect for controllers with limited buttons.

### How the Bank System Works:
- **BTAction1-14**: Universal action mapping that changes based on the current bank
- **Bank Navigation**: Use F2/F3 keys to switch between banks
- **Bank Persistence**: Current bank is remembered across sessions
- **Configuration**: Banks are defined in `bank_config.txt`

### Bank 1: Core Navigation & Reading
- **BTAction1**: BTIterateRotation (R) - Rotate screen 90 degrees
- **BTAction2**: BTIncreaseFontSize (I) - Increase font size
- **BTAction3**: BTLeft (P) - Previous page
- **BTAction4**: BTDecreaseFontSize (D) - Decrease font size
- **BTAction5**: BTToggleNightMode (L) - Toggle night mode
- **BTAction6**: BTGotoPrevChapter (X) - Previous chapter
- **BTAction7**: BTGotoNextChapter (C) - Next chapter
- **BTAction8**: BTToggleBookmark (B) - Toggle bookmark
- **BTAction9**: BTRight (N) - Next page
- **BTAction10**: BTToggleStatusBar (Up arrow) - Toggle status bar
- **BTAction11**: BTPrevBookmark (Left arrow) - Previous bookmark
- **BTAction12**: BTNextBookmark (Right arrow) - Next bookmark
- **BTAction13**: BTLastBookmark (Down arrow) - Last bookmark
- **BTAction14**: BTBluetoothOff (Page Down) - Turn off Bluetooth

### Bank 2: Font & Display Controls
- **BTAction1**: BTCycleFontHinting (R) - Cycle font hinting (off→native→auto)
- **BTAction2**: BTCycleFontKerning (I) - Cycle font kerning (off→fast→good→best)
- **BTAction3**: BTCycleWordSpacing (P) - Cycle word spacing (small→medium→large)
- **BTAction4**: BTCycleWordExpansion (D) - Cycle word expansion (none→some→more)
- **BTAction5**: BTIncreaseFontWeight (L) - Increase font weight
- **BTAction6**: BTDecreaseFontWeight (X) - Decrease font weight
- **BTAction7**: BTIncreaseLineSpacing (C) - Increase line spacing
- **BTAction8**: BTDecreaseLineSpacing (B) - Decrease line spacing
- **BTAction9**: BTIncreaseBrightness (N) - Increase brightness
- **BTAction10**: BTDecreaseBrightness (Up arrow) - Decrease brightness
- **BTAction11**: BTIncreaseWarmth (Left arrow) - Increase warmth
- **BTAction12**: BTDecreaseWarmth (Right arrow) - Decrease warmth
- **BTAction13**: BTNone (Down arrow) - No action
- **BTAction14**: BTNone (Page Down) - No action

### Bank Navigation Events
- **BTRemoteNextBank**: Switch to next bank (F2 key)
- **BTRemotePrevBank**: Switch to previous bank (F3 key)

## Font Control Events

### Font Cycling Events
- **BTCycleFontHinting**: Cycle through font hinting options (off → native → auto)
- **BTCycleFontKerning**: Cycle through font kerning options (off → fast → good → best)
- **BTCycleWordSpacing**: Cycle through word spacing options (small → medium → large)
- **BTCycleWordExpansion**: Cycle through word expansion options (none → some → more)

### Font Adjustment Events
- **BTIncreaseFontWeight**: Increase font weight by 0.5 units
- **BTDecreaseFontWeight**: Decrease font weight by 0.5 units
- **BTIncreaseLineSpacing**: Increase line spacing by 5%
- **BTDecreaseLineSpacing**: Decrease line spacing by 5%

## Core Navigation Events
- **BTGotoNextChapter**: Navigate to the next chapter
- **BTGotoPrevChapter**: Navigate to the previous chapter
- **BTDecreaseFontSize**: Reduce the font size by 2 units
- **BTIncreaseFontSize**: Increase the font size by 2 units
- **BTToggleBookmark**: Toggle bookmarks on and off
- **BTIterateRotation**: Rotate the screen orientation 90 degrees
- **BTBluetoothOff**: Turn off Bluetooth
- **BTRight**: Go to the next page
- **BTLeft**: Go to the previous page
- **BTPrevBookmark**: Navigate to the previous bookmark in the document
- **BTNextBookmark**: Navigate to the next bookmark in the document
- **BTLastBookmark**: Jump to the last bookmark by timestamp
- **BTToggleStatusBar**: Toggle the display of the status bar
- **BTToggleNightMode**: Toggle between dark mode (night mode) and light mode

## Display Control Events
- **BTIncreaseBrightness**: Increase the frontlight brightness by 10 units
- **BTDecreaseBrightness**: Decrease the frontlight brightness by 10 units
- **BTIncreaseWarmth**: Increase the warmth of the frontlight by 1 unit
- **BTDecreaseWarmth**: Decrease the warmth of the frontlight by 1 unit

*BTRight and BTLeft are recommended for page turning instead of the default actions, as these custom events will work with all screen orientations.*

## How to Install

1. Copy this folder into `koreader/plugins`.
2. Make sure your clicker is already paired with the Kobo device.
3. Make sure that your device is mapped to `/dev/input/event3` (this is not always guaranteed). If different, edit `main.lua` of this plugin to match the correct input device. (TODO: Automate)
4. Add `hasKeys = yes` to the device configuration. (TODO: Automate)
5. Add into `koreader/frontend/device/kobo/device.lua` a mapping of buttons to actions. This mapping is to be a button code (decimal number) to event name, events that you want your Bluetooth device to do. See an example below. My recommendation is to use the dedicated custom events, as most events mentioned before this update don't take orientation into account. (TODO: Automate)
6. Reboot KOReader if you haven't done so since installing the plugin.
7. (Optional) Greate Tap & Gesture shortcuts to various events.

## Bank System Configuration

The plugin uses a bank system with `bank_config.txt` to define button mappings. Here's how to configure it:

### bank_config.txt Structure
```
Bank1
BTAction1:BTIterateRotation
BTAction2:BTIncreaseFontSize
BTAction3:BTLeft
BTAction4:BTDecreaseFontSize
BTAction5:BTToggleNightMode
BTAction6:BTGotoPrevChapter
BTAction7:BTGotoNextChapter
BTAction8:BTToggleBookmark
BTAction9:BTRight
BTAction10:BTToggleStatusBar
BTAction11:BTPrevBookmark
BTAction12:BTNextBookmark
BTAction13:BTLastBookmark
BTAction14:BTBluetoothOff

Bank2
BTAction1:BTCycleFontHinting
BTAction2:BTCycleFontKerning
BTAction3:BTCycleWordSpacing
BTAction4:BTCycleWordExpansion
BTAction5:BTIncreaseFontWeight
BTAction6:BTDecreaseFontWeight
BTAction7:BTIncreaseLineSpacing
BTAction8:BTDecreaseLineSpacing
BTAction9:BTIncreaseBrightness
BTAction10:BTDecreaseBrightness
BTAction11:BTIncreaseWarmth
BTAction12:BTDecreaseWarmth
BTAction13:BTNone
BTAction14:BTNone
```

## Example device.lua Configuration

Below is an example of how you can map Bluetooth device events in your `device.lua` file using the bank system:

```lua
event_map = {
    -- Your existing mappings...
    
    -- Bank system mapping (BTAction1-14)
    [19]  = "BTAction1",   -- R for BTAction1
    [23]  = "BTAction2",   -- I for BTAction2
    [25]  = "BTAction3",   -- P for BTAction3
    [32]  = "BTAction4",   -- D for BTAction4
    [38]  = "BTAction5",   -- L for BTAction5
    [45]  = "BTAction6",   -- X for BTAction6
    [46]  = "BTAction7",   -- C for BTAction7
    [48]  = "BTAction8",   -- B for BTAction8
    [49]  = "BTAction9",   -- N for BTAction9
    [60]  = "BTRemoteNextBank",   -- F2 for Next Bank
    [61]  = "BTRemotePrevBank",   -- F3 for Previous Bank
    [103] = "BTAction10",  -- Up arrow for BTAction10
    [105] = "BTAction11",  -- Left arrow for BTAction11
    [106] = "BTAction12",  -- Right arrow for BTAction12
    [108] = "BTAction13",  -- Down arrow for BTAction13
    [109] = "BTAction14",  -- Page Down for BTAction14
}
```

### Bank System Benefits:
- **Same buttons, different functions**: Switch between banks to access different features
- **No button waste**: All 14 buttons work in both banks
- **Easy customization**: Edit `bank_config.txt` to change button functions
- **Persistent**: Current bank is remembered across sessions
- **Scalable**: Add more banks as needed


## Configuring connect.sh
To use the Connect to Device function, you need to modify the `connect.sh` script and add your device's MAC address. You can retrieve the MAC address using `bluetoothctl info`. Once configured, the script will be able to send connection requests from the Kobo device to your Bluetooth device.

## Device Specific Modifications

### Clara 2E
By default, all instructions are given for Clara 2E. No further modifications are needed apart from those documented in this description.

### Libra 2
MobileRead user **enji** provided instructions to adapt this plugin to Libra 2 by using `rtk_hciattach` instead of `hciattach`. *Thanks enji!* There are also previous cases of seeing `event4` being used instead of `event3`. In this case, please replace all instances of `event3` with `event4` in the scripts.

Replace `hciattach` with `rtk_hciattach` instructions:
- In *bluetooth.koplugin/on.sh*, change `hciattach -p ttymxc1 any 1500000 flow -t 20` to `/sbin/rtk_hciattach -s 115200 ttymxc1 rtk_h5`.
- In *bluetooth.koplugin/off.sh*, change `pkill hciattach` to `pkill rtk_hciattach`.

## Contributions

I have tested this only on a Clara 2E, but all contributions are welcome. Here are some reading materials on this topic:

- https://www.mobileread.com/forums/showthread.php?p=4444741#post4444741
- https://github.com/koreader/koreader/issues/9059
- MobileRead user **enji**'s comment on Libra 2: https://www.mobileread.com/forums/showpost.php?p=4447639&postcount=16

