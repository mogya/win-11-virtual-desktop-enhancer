#Requires AutoHotkey v2.0
#Include logger.ah2

class HotkeyManager {
    static keyboardShortcuts := Map()

    static Initialize() {
        this.Load()
    }

    static Load() {
        this.keyboardShortcuts := Map()
        if (FileExist(A_ScriptDir . "\settings.ini")) {
            currentSection := ""
            loop read, A_ScriptDir . "\settings.ini" {
                line := Trim(A_LoopReadLine)
                if (line = "")
                    continue
                if (RegExMatch(line, "^\[KeyboardShortcuts\]$", &match)) {
                    currentSection := "KeyboardShortcuts"
                } else if (currentSection = "KeyboardShortcuts" && RegExMatch(line, "^(.+)=([\s\S]*)$", &match)) {
                    this.keyboardShortcuts[match[1]] := match[2]
                }
            }
        }
    }

    static ConvertModifiers(modifiers) {
        modifiers := StrReplace(modifiers, "LAlt", "<!")
        modifiers := StrReplace(modifiers, "RAlt", ">!")
        modifiers := StrReplace(modifiers, "LCtrl", "<^")
        modifiers := StrReplace(modifiers, "RCtrl", ">^")
        modifiers := StrReplace(modifiers, "LShift", "<+")
        modifiers := StrReplace(modifiers, "RShift", ">+")
        modifiers := StrReplace(modifiers, "LWin", "<#")
        modifiers := StrReplace(modifiers, "RWin", ">#")
        modifiers := StrReplace(modifiers, "Ctrl", "^")
        modifiers := StrReplace(modifiers, "Alt", "!")
        modifiers := StrReplace(modifiers, "Shift", "+")
        modifiers := StrReplace(modifiers, "Win", "#")
        modifiers := StrReplace(modifiers, ",", "")
        return modifiers
    }

    static RegisterHotkeys() {
        try {
            switchModifier := this.ConvertModifiers(this.keyboardShortcuts["SwitchDesktop"])
            moveModifier := this.ConvertModifiers(this.keyboardShortcuts["MoveWindowToDesktop"])
            moveAndSwitchModifier := this.ConvertModifiers(this.keyboardShortcuts["MoveWindowAndSwitchToDesktop"])

            if (switchModifier != "") {
                Hotkey(switchModifier . this.keyboardShortcuts["PreviousDesktop"], (*) => SwitchToDesktop(
                    GetCurrentDesktopNumber() - 1))
                Hotkey(switchModifier . this.keyboardShortcuts["NextDesktop"], (*) => SwitchToDesktop(
                    GetCurrentDesktopNumber() + 1))

                loop 10 {
                    i := A_Index
                    Hotkey(switchModifier . this.keyboardShortcuts["Desktop" . i], ((desktopNum) => (*) =>
                        SwitchToDesktop(
                            desktopNum))(i))
                    Hotkey(switchModifier . this.keyboardShortcuts["DesktopAlt" . i], ((desktopNum) => (*) =>
                        SwitchToDesktop(
                            desktopNum))(i))
                }
            }

            if (moveModifier != "") {
                Hotkey(moveModifier . this.keyboardShortcuts["PreviousDesktop"], (*) => MoveWindowToDesktop(
                    GetCurrentDesktopNumber() - 1))
                Hotkey(moveModifier . this.keyboardShortcuts["NextDesktop"], (*) => MoveWindowToDesktop(
                    GetCurrentDesktopNumber() + 1))
                loop 10 {
                    i := A_Index
                    Hotkey(moveModifier . this.keyboardShortcuts["Desktop" . i], ((desktopNum) => (*) =>
                        MoveWindowToDesktop(
                            desktopNum))(i))
                }
            }

            if (moveAndSwitchModifier != "") {
                Hotkey(moveAndSwitchModifier . this.keyboardShortcuts["PreviousDesktop"], (*) =>
                    MoveWindowAndSwitchToDesktop(
                        GetCurrentDesktopNumber() - 1))
                Hotkey(moveAndSwitchModifier . this.keyboardShortcuts["NextDesktop"], (*) =>
                    MoveWindowAndSwitchToDesktop(
                        GetCurrentDesktopNumber() + 1))
                loop 10 {
                    i := A_Index
                    Hotkey(moveAndSwitchModifier . this.keyboardShortcuts["Desktop" . i], ((desktopNum) => (*) =>
                        MoveWindowAndSwitchToDesktop(desktopNum))(i))
                }
            }

            if (this.keyboardShortcuts["OpenDesktopManager"] != "") {
                Hotkey(this.ConvertModifiers(this.keyboardShortcuts["OpenDesktopManager"]), (*) => OpenDesktopManager())
            }
            if (this.keyboardShortcuts["TogglePinWindow"] != "") {
                Hotkey(this.ConvertModifiers(this.keyboardShortcuts["TogglePinWindow"]), (*) => TogglePinWindow())
            }
            if (this.keyboardShortcuts["TogglePinApp"] != "") {
                Hotkey(this.ConvertModifiers(this.keyboardShortcuts["TogglePinApp"]), (*) => TogglePinApp())
            }
            if (this.keyboardShortcuts["PinWindow"] != "") {
                Hotkey(this.ConvertModifiers(this.keyboardShortcuts["PinWindow"]), (*) => PinWindow(WinGetID("A")))
            }
            if (this.keyboardShortcuts["UnPinWindow"] != "") {
                Hotkey(this.ConvertModifiers(this.keyboardShortcuts["UnPinWindow"]), (*) => UnPinWindow(WinGetID("A")))
            }
            if (this.keyboardShortcuts["PinApp"] != "") {
                Hotkey(this.ConvertModifiers(this.keyboardShortcuts["PinApp"]), (*) => PinApp(WinGetID("A")))
            }
            if (this.keyboardShortcuts["UnPinApp"] != "") {
                Hotkey(this.ConvertModifiers(this.keyboardShortcuts["UnPinApp"]), (*) => UnPinApp(WinGetID("A")))
            }
        } catch as e {
            MsgBox("Failed to register hotkeys.`nError: " . e.Message . "`nLine: " . e.Line . "`nFile: " . e.File,
                "Error",
                "Icon!")
            return false
        }
        return true
    }
}
