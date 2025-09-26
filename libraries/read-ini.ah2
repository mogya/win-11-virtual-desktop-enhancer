#Requires AutoHotkey v2.0
#Include logger.ah2

global GeneralDesktopWrapping := 1
global TooltipsEnabled := 1
global TooltipsLifespan := 750
global TooltipsFadeOutAnimationDuration := 100
global TooltipsPositionX := "CENTER"
global TooltipsPositionY := "CENTER"
global TooltipsOnEveryMonitor := 1
global TooltipsFontSize := 11
global TooltipsFontInBold := 700
global TooltipsFontColor := "0xFFFFFF"
global TooltipsBackgroundColor := "0x1F1F1F"
global GeneralUseNativePrevNextDesktopSwitchingIfConflicting := false

; キーボードショートカットの設定
global KeyboardShortcuts := Map()

ReadIni(iniPath) {
    if (!FileExist(iniPath)) {
        LogError("INI file not found: " . iniPath)
        return false
    }

    try {
        currentSection := ""
        loop read, iniPath {
            line := Trim(A_LoopReadLine)
            if (line = "")
                continue
            if (RegExMatch(line, "^\[(.+)\]$", &match)) {
                currentSection := match[1]
            } else if (RegExMatch(line, "^(.+)=(.+)$", &match)) {
                key := match[1]
                value := match[2]
                if (currentSection = "General") {
                    switch key {
                        case "DesktopWrapping":
                            global GeneralDesktopWrapping := Integer(value)
                    }
                } else if (currentSection = "Tooltips") {
                    switch key {
                        case "Enabled":
                            global TooltipsEnabled := Integer(value)
                        case "Lifespan":
                            global TooltipsLifespan := Integer(value)
                        case "FadeOutAnimationDuration":
                            global TooltipsFadeOutAnimationDuration := Integer(value)
                        case "PositionX":
                            global TooltipsPositionX := value
                        case "PositionY":
                            global TooltipsPositionY := value
                        case "OnEveryMonitor":
                            global TooltipsOnEveryMonitor := Integer(value)
                        case "FontSize":
                            global TooltipsFontSize := Integer(value)
                        case "FontInBold":
                            global TooltipsFontInBold := Integer(value)
                        case "FontColor":
                            global TooltipsFontColor := value
                        case "BackgroundColor":
                            global TooltipsBackgroundColor := value
                    }
                } else if (currentSection = "KeyboardShortcuts") {
                    global KeyboardShortcuts
                    KeyboardShortcuts[key] := value
                }
            }
        }
        return true
    } catch as e {
        LogError("Failed to read INI file. Error: " . e.Message . " File: " . iniPath)
        return false
    }
}

ValidateSettings() {
    global GeneralDesktopWrapping
    global TooltipsEnabled
    global TooltipsLifespan
    global TooltipsFadeOutAnimationDuration
    global TooltipsPositionX
    global TooltipsPositionY
    global TooltipsOnEveryMonitor
    global TooltipsFontSize
    global TooltipsFontInBold
    global TooltipsFontColor
    global TooltipsBackgroundColor
    global GeneralUseNativePrevNextDesktopSwitchingIfConflicting
    global KeyboardShortcuts

    if !(GeneralDesktopWrapping ~= "^[01]$")
        GeneralDesktopWrapping := 1
    if !(TooltipsEnabled ~= "^[01]$")
        TooltipsEnabled := 1
    if !(TooltipsLifespan ~= "^\d+$")
        TooltipsLifespan := 750
    if !(TooltipsFadeOutAnimationDuration ~= "^\d+$")
        TooltipsFadeOutAnimationDuration := 100
    if !(TooltipsPositionX == "LEFT" || TooltipsPositionX == "CENTER" || TooltipsPositionX == "RIGHT")
        TooltipsPositionX := "CENTER"
    if !(TooltipsPositionY == "TOP" || TooltipsPositionY == "CENTER" || TooltipsPositionY == "BOTTOM")
        TooltipsPositionY := "CENTER"
    if !(TooltipsOnEveryMonitor ~= "^[01]$")
        TooltipsOnEveryMonitor := 1
    if !(TooltipsFontSize ~= "^\d+$")
        TooltipsFontSize := 11
    if !(TooltipsFontInBold ~= "^[01]$")
        TooltipsFontInBold := 0
    TooltipsFontInBold := TooltipsFontInBold ? 700 : 400
    if !(TooltipsFontColor ~= "^0x[0-9A-Fa-f]{1,6}$")
        TooltipsFontColor := "0xFFFFFF"
    if !(TooltipsBackgroundColor ~= "^0x[0-9A-Fa-f]{1,6}$")
        TooltipsBackgroundColor := "0x1F1F1F"
    if !(GeneralUseNativePrevNextDesktopSwitchingIfConflicting ~= "^[01]$")
        GeneralUseNativePrevNextDesktopSwitchingIfConflicting := false

    ; キーボードショートカットのデフォルト値設定
    if !KeyboardShortcuts.Has("SwitchDesktop")
        KeyboardShortcuts["SwitchDesktop"] := "Ctrl,Win"
    if !KeyboardShortcuts.Has("MoveWindowToDesktop")
        KeyboardShortcuts["MoveWindowToDesktop"] := "Ctrl,Shift,Win"
    if !KeyboardShortcuts.Has("MoveWindowAndSwitchToDesktop")
        KeyboardShortcuts["MoveWindowAndSwitchToDesktop"] := "Ctrl,Alt,Win"
    if !KeyboardShortcuts.Has("NextTenDesktops")
        KeyboardShortcuts["NextTenDesktops"] := "Alt"
    if !KeyboardShortcuts.Has("PreviousDesktop")
        KeyboardShortcuts["PreviousDesktop"] := "Left"
    if !KeyboardShortcuts.Has("NextDesktop")
        KeyboardShortcuts["NextDesktop"] := "Right"
    if !KeyboardShortcuts.Has("Desktop1")
        KeyboardShortcuts["Desktop1"] := "1"
    if !KeyboardShortcuts.Has("Desktop2")
        KeyboardShortcuts["Desktop2"] := "2"
    if !KeyboardShortcuts.Has("Desktop3")
        KeyboardShortcuts["Desktop3"] := "3"
    if !KeyboardShortcuts.Has("Desktop4")
        KeyboardShortcuts["Desktop4"] := "4"
    if !KeyboardShortcuts.Has("Desktop5")
        KeyboardShortcuts["Desktop5"] := "5"
    if !KeyboardShortcuts.Has("Desktop6")
        KeyboardShortcuts["Desktop6"] := "6"
    if !KeyboardShortcuts.Has("Desktop7")
        KeyboardShortcuts["Desktop7"] := "7"
    if !KeyboardShortcuts.Has("Desktop8")
        KeyboardShortcuts["Desktop8"] := "8"
    if !KeyboardShortcuts.Has("Desktop9")
        KeyboardShortcuts["Desktop9"] := "9"
    if !KeyboardShortcuts.Has("Desktop10")
        KeyboardShortcuts["Desktop10"] := "0"
    if !KeyboardShortcuts.Has("OpenDesktopManager")
        KeyboardShortcuts["OpenDesktopManager"] := "Ctrl,Win,D"
    if !KeyboardShortcuts.Has("TogglePinWindow")
        KeyboardShortcuts["TogglePinWindow"] := "Ctrl,Win,P"
    if !KeyboardShortcuts.Has("TogglePinApp")
        KeyboardShortcuts["TogglePinApp"] := "Ctrl,Shift,Win,P"
    if !KeyboardShortcuts.Has("PinWindow")
        KeyboardShortcuts["PinWindow"] := "Ctrl,Win,Shift,P"
    if !KeyboardShortcuts.Has("UnPinWindow")
        KeyboardShortcuts["UnPinWindow"] := "Ctrl,Win,Alt,P"
    if !KeyboardShortcuts.Has("PinApp")
        KeyboardShortcuts["PinApp"] := "Ctrl,Win,Shift,A"
    if !KeyboardShortcuts.Has("UnPinApp")
        KeyboardShortcuts["UnPinApp"] := "Ctrl,Win,Alt,A"

    DesktopNamesManager.ValidateNames()
}
