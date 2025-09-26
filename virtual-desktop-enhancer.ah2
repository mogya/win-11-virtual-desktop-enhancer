#SingleInstance Force
#WinActivateForce
A_HotkeyInterval := 20
A_MaxHotkeysPerInterval := 20000
A_MenuMaskKey := "vk07"
#UseHook
#Requires AutoHotkey v2.0
Persistent

#Include libraries\read-ini.ah2
#Include libraries\desktop-names.ah2
#Include libraries\wallpaper.ah2
#Include libraries\hotkeys.ah2
#Include libraries\tooltip.ah2
#Include libraries\logger.ah2

InitializeGlobals() {
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

    global taskbarPrimaryID := 0
    global taskbarSecondaryID := 0
    global previousDesktopNo := 0
    global doFocusAfterNextSwitch := 0
    global hasSwitchedDesktopsBefore := 1

    global defaultIconPath := A_ScriptDir . "\icons\+.ico"
}

InitializeDllFunctions() {
    try {
        global VDA_PATH := A_ScriptDir . ".\libraries\VirtualDesktopAccessor.dll"
        if (!FileExist(VDA_PATH)) {
            LogError("VirtualDesktopAccessor.dll not found at: " . VDA_PATH)
            throw Error("VirtualDesktopAccessor.dll not found")
        }

        global hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")
        if (!hVirtualDesktopAccessor) {
            LogError("Failed to load VirtualDesktopAccessor.dll")
            throw Error("Failed to load VirtualDesktopAccessor.dll")
        }

        global GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr",
            "GetDesktopCount",
            "Ptr")
        global GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr",
            "GoToDesktopNumber", "Ptr")
        global GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr",
            "GetCurrentDesktopNumber", "Ptr")
        global MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr",
            "MoveWindowToDesktopNumber", "Ptr")
        global IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr",
            "IsWindowOnDesktopNumber", "Ptr")
        global IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow",
            "Ptr")
        global PinWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinWindow", "Ptr")
        global UnPinWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinWindow",
            "Ptr")
        global IsPinnedAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedApp",
            "Ptr")
        global PinAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinApp", "Ptr")
        global UnPinAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinApp", "Ptr")
        global GetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopName",
            "Ptr")
        global SetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "SetDesktopName",
            "Ptr")
        global RegisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr",
            "RegisterPostMessageHook", "Ptr")
        global UnregisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr",
            "UnregisterPostMessageHook", "Ptr")
    } catch as e {
        MsgBox("Failed to initialize DLL functions. Error: " . e.Message, "Error", "Icon!")
        ExitApp(1)
    }
}

SetupDesktopSwitchHook() {
    DetectHiddenWindows(true)
    global hwnd := WinGetID("ahk_pid " . DllCall("GetCurrentProcessId", "UInt"))
    hwnd += 0x1000 << 32

    DllCall(RegisterPostMessageHookProc, "Int", hwnd, "Int", 0x1400 + 30)
    OnMessage(0x1400 + 30, VWMess)
}

VWMess(wParam, lParam, msg, hwnd) {
    OnDesktopSwitch(lParam + 1)
}

OnDesktopSwitch(desktopNumber) {
    UpdateTrayIcon(desktopNumber)

    if (TooltipsEnabled) {
        if (TooltipsOnEveryMonitor) {
            TooltipManager.ShowTooltipOnAllMonitors(DesktopNamesManager.GetName(desktopNumber))
        } else {
            TooltipManager.ShowTooltipOnMonitor(1, DesktopNamesManager.GetName(desktopNumber))
        }
    }

    wallpaper := WallpaperManager.GetWallpaper(desktopNumber)
    if (wallpaper != "") {
        WallpaperManager.SetDesktopWallpaper(wallpaper)
    }
}

MoveWindowToDesktop(num) {
    hwnd := WinGetID("A")
    MoveWindowToDesktopNumber(hwnd, num)
}

MoveWindowAndSwitchToDesktop(num) {
    MoveToDesktop(num)
    SwitchToDesktop(num)
}

OpenDesktopManager() {
    Send("#{Tab}")
}

TogglePinWindow() {
    hwnd := WinGetID("A")
    if (IsPinnedWindow(hwnd)) {
        UnPinWindow(hwnd)
    } else {
        PinWindow(hwnd)
    }
}

TogglePinApp() {
    hwnd := WinGetID("A")
    if (IsPinnedApp(hwnd)) {
        UnPinApp(hwnd)
    } else {
        PinApp(hwnd)
    }
}

PinWindow(hwnd) {
    DllCall(PinWindowProc, "Ptr", hwnd, "Int")
}

UnPinWindow(hwnd) {
    DllCall(UnPinWindowProc, "Ptr", hwnd, "Int")
}

PinApp(hwnd) {
    DllCall(PinAppProc, "Ptr", hwnd, "Int")
}

UnPinApp(hwnd) {
    DllCall(UnPinAppProc, "Ptr", hwnd, "Int")
}

IsPinnedWindow(hwnd) {
    return DllCall(IsPinnedWindowProc, "Ptr", hwnd, "Int")
}

IsPinnedApp(hwnd) {
    return DllCall(IsPinnedAppProc, "Ptr", hwnd, "Int")
}

UpdateTrayIcon(desktopNumber) {
    iconPath := A_ScriptDir . "\icons\" . desktopNumber . ".ico"
    if (FileExist(iconPath)) {
        TraySetIcon(iconPath, 1)
    } else {
        TraySetIcon(defaultIconPath, 1)
    }
    A_IconTip := DesktopNamesManager.GetName(desktopNumber)
}

GetDesktopCount() {
    return DllCall(GetDesktopCountProc, "Int")
}

GetCurrentDesktopNumber() {
    return DllCall(GetCurrentDesktopNumberProc, "Int") + 1  ; DesktopNumber index is 0-based
}

GoToDesktopNumber(num) {
    try {
        result := DllCall(GoToDesktopNumberProc, "Int", num - 1, "Int")
        if (result = 0) {
            LogError("Failed to switch to desktop " . num)
            return false
        }
        return true
    } catch as e {
        LogError("Error in GoToDesktopNumber: " . e.Message)
        return false
    }
}

MoveWindowToDesktopNumber(hwnd, num) {
    try {
        result := DllCall(MoveWindowToDesktopNumberProc, "Ptr", hwnd, "Int", num - 1, "Int")
        if (result = 0) {
            LogError("Failed to move window to desktop " . num)
            return false
        }
        return true
    } catch as e {
        LogError("Error in MoveWindowToDesktopNumber: " . e.Message)
        return false
    }
}

SwitchToDesktop(num) {
    global GeneralDesktopWrapping, previousDesktopNo, doFocusAfterNextSwitch, hasSwitchedDesktopsBefore

    desktopCount := GetDesktopCount()
    if (GeneralDesktopWrapping) {
        if (num < 1)
            num := desktopCount
        else if (num > desktopCount)
            num := 1
    } else {
        if (num < 1 || num > desktopCount)
            return
    }

    previousDesktopNo := GetCurrentDesktopNumber()
    GoToDesktopNumber(num)
}

MoveToDesktop(num) {
    global GeneralDesktopWrapping, TooltipsEnabled
    desktopCount := GetDesktopCount()

    if (GeneralDesktopWrapping) {
        if (num < 1)
            num := desktopCount
        else if (num > desktopCount)
            num := 1
    } else {
        if (num < 1 || num > desktopCount)
            return
    }

    activeHwnd := WinGetID("A")
    MoveWindowToDesktopNumber(activeHwnd, num)

    if (TooltipsEnabled) {
        if (TooltipsOnEveryMonitor) {
            loop MonitorGetCount() {
                TooltipManager.ShowTooltipOnMonitor(A_Index, "Moved to " . DesktopNamesManager.GetName(num))
            }
        } else {
            TooltipManager.ShowTooltipOnMonitor(1, "Moved to " . DesktopNamesManager.GetName(num))
        }
    }
}

Main() {
    InitializeGlobals()
    InitializeDllFunctions()
    DesktopNamesManager.Initialize()
    WallpaperManager.Initialize()
    HotkeyManager.Initialize()
    TooltipManager.Initialize()
    ReadIni(A_ScriptDir . "\settings.ini")
    ValidateSettings()
    DesktopNamesManager.ValidateNames()

    A_TrayMenu.Delete()
    A_TrayMenu.Add("settings", (*) => Run("notepad.exe " . A_ScriptDir . "\settings.ini"))
    A_TrayMenu.Add("edit desktop names", (*) => DesktopNamesManager.ShowEditor())
    A_TrayMenu.Add("change wallpaper", (*) => WallpaperManager.ShowEditor())
    A_TrayMenu.Add("reload", (*) => Reload())
    A_TrayMenu.Add("exit", ExitAppHandler)

    SetupDesktopSwitchHook()
    UpdateTrayIcon(GetCurrentDesktopNumber())
    HotkeyManager.RegisterHotkeys()
}

ExitAppHandler(*) {
    try {
        DllCall(UnregisterPostMessageHookProc, "Int", hwnd)
    } catch as e {
        LogError("Failed to unregister post message hook. Error: " . e.Message)
    }
    ExitApp()
}

Main()
