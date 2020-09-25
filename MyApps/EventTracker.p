PROGRAM EventTracker;

USES
    SegLoad, Quickdraw, Fonts, Windows, Events, AppleEvents,
    Menus, Dialogs, TextEdit, OSUtils, ToolUtils, Desk;

CONST
    kBaseID = 128; {base resource ID}
    rWind = kBaseID; kSleep = 100;
    kLeftMargin = 4; kRowStart = 285; kFontSize = 9;
    kRowHeight = kFontSize+2; kHOffset = 0;

VAR gDone: Boolean;

{$S Main}
PROCEDURE AlertUser;
VAR i: Integer;
BEGIN
    SysBeep(10); {system cycles to get sound}
    FOR i:=1 TO 20 DO SystemTask;
    ExitToShell
END; {AlertUser}

FUNCTION DoOpenApp(event, reply: AppleEvent; refCon: LongInt): OSErr;
BEGIN DrawString('Apple event: open app')
END;

FUNCTION DoOpenDoc(event, reply: AppleEvent; refCon: LongInt): OSErr;
BEGIN DrawString('Apple event: open doc')
END;

FUNCTION DoQuitApp(event, reply: AppleEvent; refCon: LongInt): OSErr;
BEGIN DrawString('Apple event: quit app')
END;

{$S Init}
PROCEDURE Init;
VAR wnd: WindowPtr; err: OSErr;
BEGIN
    InitGraf(@thePort); {initialize QuickDraw}
    InitFonts;      {initialize Font Manager}
    InitWindows;    {initialize Window Manager}
    InitMenus;      {initialize Menu Manager}
    TEInit;         {initialize TextEdit Manager}
    InitDialogs(NIL);   {initialize Dialog Manager}
    InitCursor;     {initialize the cursor to an arrow}
    
    gDone := FALSE;
    wnd := GetNewWindow(rWind, NIL, WindowPtr(-1));
    IF wnd = NIL THEN AlertUser;
    SetPort(wnd); TextSize(kFontSize); ShowWindow(wnd);
    
    {ignore err}
    err := AEInstallEventHandler(kCoreEventClass, kAEOpenApplication,
        EventHandlerProcPtr(@DoOpenApp), 0, FALSE);
    err := AEInstallEventHandler(kCoreEventClass, kAEOpenDocuments,
        EventHandlerProcPtr(@DoOpenDoc), 0, FALSE);
    err := AEInstallEventHandler(kCoreEventClass, kAEQuitApplication,
        EventHandlerProcPtr(@DoQuitApp), 0, FALSE)

END; {Init}

PROCEDURE _DataInit; EXTERNAL; {MPW runtime in A5Init segment}

{$S Main}
PROCEDURE HandleMouseDown(VAR event: EventRecord);
VAR
    wnd: WindowPtr; thePart: Integer;
BEGIN
    thePart := FindWindow(event.where, wnd);
    CASE thePart OF
        inSysWindow: SystemClick(event, wnd);
        inDrag: DragWindow(wnd, event.where, screenBits.bounds);
        inGoAway: IF TrackGoAway(wnd, event.where) THEN gDone := TRUE
    END {CASE}
END; {HandleMouseDown}

PROCEDURE EventStr(str: String);
VAR wnd: WIndowPtr; tmpRgn: RgnHandle;
BEGIN
    wnd := FrontWindow;
    tmpRgn := NewRgn;
    ScrollRect(wnd^.portRect, KHOffset, -kRowHeight, tmpRgn);
    DisposeRgn(tmpRgn);
    MoveTo(kLeftMargin, kRowStart);
    DrawString(str)
END; {EventStr}

PROCEDURE DoUpdate(VAR event: EventRecord);
VAR wnd: WindowPtr;
BEGIN
    wnd := WindowPtr(event.message);
    BeginUpdate(wnd);
    EndUpdate(wnd)
END; {DoUpdate}

PROCEDURE DoEvent(VAR event: EventRecord);
VAR wnd: WindowPtr; err: OSErr;
BEGIN
    CASE event.what OF
        kHighLevelEvent: BEGIN EventStr('High level event: ');
            err := AEProcessAppleEvent(event)
        END ;
        mouseDown: BEGIN EventStr('mouseDown'); HandleMouseDown(event) END ;
        mouseUp: EventStr('mouseUp');
        keyDown: EventStr('keyDown');
        keyUp:   EventStr('keyUp');
        autoKey: EventStr('autoKey');
        updateEvt: BEGIN DoUpdate(event); EventStr('updateEvt') END ;
        diskEvt: EventStr('diskEvt');
        activateEvt: EventStr('activateEvt');
        networkEvt: EventStr('networkEvt');
        driverEvt: EventStr('driverEvt');
        app1Evt: EventStr('app1Evt');
        app2Evt: EventStr('app2Evt');
        app3Evt: EventStr('app3Evt');
        osEvt: BEGIN EventStr('osEvt: ');
            IF BAnd(event.message, suspendResumeMessage) = resumeFlag THEN
                DrawString('Resume event')
            ELSE DrawString('Suspend event')
        END
    END {CASE}
END; {DoEvent}

PROCEDURE EventLoop;
VAR event: EventRecord;
BEGIN
    REPEAT
        IF WaitNextEvent(everyEvent, event, kSleep, NIL) THEN
            DoEvent(event)
        ELSE EventStr('nullEvent')
    UNTIL gDone
END; {EventLoop}

BEGIN
    UnloadSeg(@_DataInit);  {note that _DataInit must not be in Main!}
    Init;
    UnloadSeg(@Init);   {note that Init must not be in Main!}
    EventLoop
END.
