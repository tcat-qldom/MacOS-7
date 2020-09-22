PROGRAM VennDiagrammer;
{
	Tutorial application described in new Inside Macintosh - Overview
	book. Lets a user to evaluate syllogism based on the figure and mood.
	User graphs the information into Venn Circles.
	
	(c) 2020 tcat <thomas.kral@email.cz>
		recoded all known source from the book, making MPW project
		programmed undefined portions of the code in the book
}

USES
	{System Units}
	SegLoad, Quickdraw, Fonts, Windows, Menus, Events, TextEdit, Dialogs,
	Memory, Resources, OSUtils, ToolUtils, DiskInit, Desk,(* Packages,*)
	
	{Application Units}
	Global, Dialog, Preferences, Utilities, VennProcs;
	
{$S Main}
FUNCTION DoCreateWindow: WindowPtr; FORWARD;

{$S Init}
PROCEDURE DoInitManagers;
BEGIN
	(*MaxApplZone;*)						{extend heap zone to limit}
	(*MoreMasters;*)						{get 64 more master pointers}

	InitGraf(@thePort);						{initialize QuickDraw}
	InitFonts;								{initialize Font Manager}
	InitWindows;							{initialize Window Manager}
	InitMenus;								{initialize Menu Manager}
	TEInit;									{initialize TextEdit}
	InitDialogs(NIL);						{initialize Dialog Manager}

	GetDateTime(randSeed);					{initialize random seed with time}

	(*FlushEvents(everyEvent, 0);*)			{clear event queue}
	InitCursor;								{initialize cursor to arrow}
END; {DoInitManagers}

{$S Init}
PROCEDURE DoSetupMenus;
	VAR
		menuBar:				Handle;
BEGIN
	menuBar := GetNewMBar(rMenuBar);
	IF menuBar = NIL THEN DoBadError(eCantFindMenus);

	SetMenuBar(menuBar);
	DisposeHandle(menuBar);
	AddResMenu(GetMHandle(mApple), 'DRVR');
	DrawMenuBar
END;

{$S Init}
{Renamed from MyGetIndCircleRect to handle general 'REC#' Ind resource}
FUNCTION MyGetIndRect(ind: Integer): Rect;
	CONST
		kVennRectType = 'REC#';
		rVennRectID = rVennD;
	VAR
		rectHnd: Handle; myRect: Rect;
BEGIN
	rectHnd := Get1Resource(kVennRectType, rVennRectID);

	IF rectHnd <> NIL THEN
		myRect := RectPtr(ORD(rectHnd^) + 8*(ind - 1) + 2)^
	ELSE
		SetRect(myRect, 0, 0, 0, 0);

	MyGetIndRect := myRect
END; {MyGetIndRect}

{$S Init}
PROCEDURE DoSetupCircleRegions;
{	Circle numbers:
	1		2
		3			4	5
}
VAR count: Integer;
BEGIN
	FOR count := 1 TO 5 DO
	BEGIN
		gGeometry^^.circleRgns[count] := NewRgn;
		OpenRgn;
		FrameOval(gGeometry^^.circleRects[count]);
		CloseRgn(gGeometry^^.circleRgns[count]);
	END;
END; {DoSetupCircleRegions}

{$S Init}
PROCEDURE DoSetupOverlapRegions;
{ 		Premises and numbers:		Conclusion and numbers:

		P[1]	SP[2]	S[3]
				SMP[5]				P[1]	SP[2]	S[3]
			MP[4]	SM[6]
				M[7]
}
VAR
	tmpRgn:	RgnHandle;	{a scratch region}
	count:	Integer;
BEGIN
	FOR count := 1 TO 7(*8*) DO								{create new, empty regions}
		gGeometry^^.premiseRgns[count] := NewRgn;

	tmpRgn := NewRgn;										{create a scratch region}

	{Calculate the overlap regions in the premises diagram.}
	HLock(Handle(gGeometry));								{lock the handle}
	WITH gGeometry^^ DO
	BEGIN
		DiffRgn(circleRgns[1], circleRgns[2], tmpRgn);
		DiffRgn(tmpRgn, circleRgns[3], premiseRgns[1]);

		SectRgn(circleRgns[1], circleRgns[2], tmpRgn);
		DiffRgn(tmpRgn, circleRgns[3], premiseRgns[2]);

		DiffRgn(circleRgns[2], circleRgns[1], tmpRgn);
		DiffRgn(tmpRgn, circleRgns[3], premiseRgns[3]);

		SectRgn(circleRgns[1], circleRgns[3], tmpRgn);
		DiffRgn(tmpRgn, circleRgns[2], premiseRgns[4]);

		SectRgn(circleRgns[1], circleRgns[2], tmpRgn);
		SectRgn(tmpRgn, circleRgns[3], premiseRgns[5]);

		SectRgn(circleRgns[2], circleRgns[3], tmpRgn);
		DiffRgn(tmpRgn, circleRgns[1], premiseRgns[6]);

		DiffRgn(circleRgns[3], circleRgns[1], tmpRgn);
		DiffRgn(tmpRgn, circleRgns[2], premiseRgns[7]);
	END;

	{Calculate the overlap regions in the conclusion diagram.}
	FOR count := 1 TO 3(*4*) DO								{create new, empty regions}
		gGeometry^^.concRgns[count] := NewRgn;

	WITH gGeometry^^ DO
	BEGIN
		DiffRgn(circleRgns[4], circleRgns[5], concRgns[1]);
		SectRgn(circleRgns[4], circleRgns[5], concRgns[2]);
		DiffRgn(circleRgns[5], circleRgns[4], concRgns[3])
	END;

	HUnlock(Handle(gGeometry));								{unlock the handle}
	DisposeRgn(tmpRgn);										{dispose scratch region}
END; {DoSetupOverlapRegions}

{$S Init}
PROCEDURE DoInitGeometry;
VAR count: Integer;
BEGIN
	{Allocate the memory needed to hold the diagram's geometry.}
	gGeometry := MyGeometryHnd(NewHandleClear(sizeof(MyGeometryRec)));

	IF gGeometry = NIL THEN									{make sure we have the memory}
		DoBadError(eNotEnoughMemory);						{see Listing 9-5 on page 178}

	{Set up the rectangles that define the circles.}
	FOR count := 1 TO 5 DO
		gGeometry^^.circleRects[count] := MyGetIndRect(count);

	{Set up the rectangles that define the existence symbols.}
	FOR count := 1 TO 7 DO
		gGeometry^^.exPreRects[count] := MyGetIndRect(kExPreRectStart + (count - 1));
	FOR count := 1 TO 3 DO
		gGeometry^^.exConRects[count] := MyGetIndRect(kExConRectStart + (count - 1));

	{Set up the regions that the circles define.}
	DoSetupCircleRegions;

	{Set up the overlapping regions within the circles.}
	DoSetupOverlapRegions;
END; {DoInitGeometry}

{$S Init}
PROCEDURE DoVennInit;
VAR count: Integer; wp: WindowPtr;
BEGIN
	{Get handles to empty patterns.}
	SetResLoad(FALSE);
	FOR count := 1 TO 4 DO
		gEmptyPats[count] := GetPattern(kEmptyID + (count-1));
		
	{Get handles to tool icons.}
	FOR count := 1 TO kNumTools DO
		gToolsIcons[count] := GetResource('ICON', kToolsIconStart + (count-1));
	
	{Get handles to available existence-indicating icons.}
	FOR count := 1 TO 4 DO
		gExistIcons[count] := GetResource('ICON', kExistID + (count-1));
	
	{Get handles to mood icons.}
	FOR count := 1 TO 4 DO
		gMoodIcons[count] := GetResource('ICON', kMoodIconStart + (count-1));
	
	{Get handles to figure icons.}
	FOR count := 1 TO 4 DO
		gFigureIcons[count] := GetResource('ICON', kFigIconStart + (count-1));
	SetResLoad(TRUE);

	{Set up the rectangles that define the figures.}
	FOR count := 1 TO 4 DO
		gFigureRects[count] := MyGetIndRect(kFigRectStart + (count-1));

	{Set up the rectangles that define the moods.}
	FOR count := 1 TO 12 DO
		gMoodRects[count] := MyGetIndRect(kMoodRectStart + (count-1));

	{Set up the rectangles that define premises and conclusion texts.}
	FOR count := 1 TO 3 DO
		gTextBoxes[count] := MyGetIndRect(kTextRectStart + (count-1));

	DoInitGeometry;	wp := DoCreateWindow
END; {DoVennInit}

PROCEDURE _DataInit; EXTERNAL;

{$S Main}
FUNCTION DoCreateWindow: WindowPtr;
	CONST kMinTotal = 5000;
	VAR
		myPointer:	Ptr;
		myWindow:	WindowPtr;
		myHandle:	MyDocRecHnd;
		total, contig: LongInt;
BEGIN

	{Inquire available total mem after purging.}
	{Minimum memory of kMinTotal is required on the heap.}
	
	PurgeSpace(total, contig);
	IF total < kMinTotal THEN
	
		{Dispose of Preferences Dialog, when it is not showing,
		{and unload code segment to make more room in the heap.}
		
		IF (gPrefsDialog <> NIL) & NOT WindowPeek(gPrefsDialog)^.visible THEN
			BEGIN
				CloseDialog(gPrefsDialog);
				DisposePtr(Ptr(gPrefsDialog));
				gPrefsDialog := NIL;
				UnloadSeg(@DoModelessDialog)
			END;

	PurgeSpace(total, contig);	{Do we get enouigh room?}
	IF total < kMinTotal THEN
		BEGIN
			DoAlertUser(eMemoryLow); Exit(DoCreateWindow)
		END;

	myPointer := NewPtr(SizeOf(WindowRecord));
	IF myPointer = NIL THEN Exit(DoCreateWindow);

	myWindow := GetNewWindow(rVennD, myPointer, WindowPtr(-1));
	IF myWindow <> NIL THEN
		BEGIN
			SetPort(myWindow);
			myHandle := MyDocRecHnd(NewHandleClear(SizeOf(MyDocRec)));

			IF myHandle <> NIL THEN
				BEGIN
					HLockHi(Handle(myHandle));				{lock the data high in the heap}
					SetWRefCon(myWindow, LongInt(myHandle));
															{attach handle to window record}
					DoSetWindowTitle(myWindow);				{set the window title}

					{Define initial window settings.}
					WITH myHandle^^ DO
						BEGIN
							figure := 1;
							mood[1] := 1;
							mood[2] := 1;
							mood[3] := 1;
							isAnswerShowing := FALSE;
							isExistImport := gGiveImport;
						END;
					DoGetRandomTerms(myWindow);
					DoCalcAnswer(myWindow);

					{Position the window and display it.}
					DoPositionWindow(myWindow);
					ShowWindow(myWindow);

				END {IF myHandle <> NIL}
			ELSE
				BEGIN										{couldn't get a data record}
					CloseWindow(myWindow);				
					DisposePtr(Ptr(myWindow));						
					myWindow := NIL;						{so pass back NIL}
				END;
		END;
	DoCreateWindow := myWindow;
END; {DoCreateWindow}

{$S Main}
PROCEDURE DoVennClick(myWindow: WindowPtr; VAR myPoint: Point);
	VAR
		count, row:	Integer;
		myHandle:	MyDocRecHnd;(* numStr: Str255;*)
BEGIN
	myHandle := MyDocRecHnd(GetWRefCon(myWindow));
	WITH myHandle^^ DO
		IF isAnswerShowing THEN
			BEGIN
				DoStatusMesg(myWindow, eCannotEditAnswer);
				Exit(DoVennClick)
			END;
	
	{Look for a click in one of the four figures.}
	FOR count := 1 TO 4 DO
		IF PtInRect(myPoint, gFigureRects[count]) THEN
			IF myHandle^^.figure <> count THEN				{new rect differ from prev?}
				BEGIN
					InvalRect(gFigureRects[myHandle^^.figure]);
					myHandle^^.figure := count;
					InvalRect(gFigureRects[myHandle^^.figure]);
					InvalRect(gTextBoxes[1]);				{invalidate premises}
					InvalRect(gTextBoxes[2]);
					DoCalcAnswer(myWindow);					{update the current answer}
					DoStatusText(myWindow, '');				{remove any existing message}
					Leave
				END;

	{Look for a click in one of the four moods in each row.}
	FOR row := 1 TO 3 DO
		FOR count := 1 TO 4 DO
			IF PtInRect(myPoint, gMoodRects[count + (row - 1) * 4]) THEN
				IF myHandle^^.mood[row] <> count THEN		{new rect differ from prev?}
					BEGIN
						InvalRect(gMoodRects[myHandle^^.mood[row] + (row - 1) * 4]);
						myHandle^^.mood[row] := count;
						InvalRect(gMoodRects[myHandle^^.mood[row] + (row - 1) * 4]);
						InvalRect(gTextBoxes[row]);			{invalidate row of text}
						DoCalcAnswer(myWindow);				{update the current answer}
						DoStatusText(myWindow, '');			{remove any existing message}
						Leave
					END;

	{Look for a click in one of the seven premises regions.}
	FOR count := 1 TO 7 DO
		IF PtInRgn(myPoint, gGeometry^^.premiseRgns[count]) THEN
			WITH myHandle^^.userSolution DO
				IF NOT (count IN premise) THEN
					BEGIN
						InvalRgn(gGeometry^^.premiseRgns[count]);
						premise := premise + [count]; {add clicked region to set}
						myHandle^^.needsAdjusting := TRUE;
						(*NumToString(count, numStr); {debug - show region numbers}
						DoStatusText(myWindow, numStr);*)
						Leave
					END;

	{Look for a click in one of the 3 conclusion regions.}
	FOR count := 1 TO 3 DO
		IF PtInRgn(myPoint, gGeometry^^.concRgns[count]) THEN
			WITH myHandle^^.userSolution DO
				IF NOT (count IN conc) THEN
					BEGIN
						InvalRgn(gGeometry^^.concRgns[count]);
						conc := conc + [count]; {add clicked region to set}
						(*NumToString(count, numStr); {debug - show region numbers}
						DoStatusText(myWindow, numStr);*)
						Leave
					END;

END; {DoVennClick}

{$S Main}
PROCEDURE DoDrag (myWindow: WindowPtr; mouseloc: Point);
	VAR
		dragBounds: Rect;
BEGIN
	dragBounds := GetGrayRgn^^.rgnBBox;
	DragWindow(myWindow, mouseloc, dragBounds);
END; {DoDrag}

{$S Main}
PROCEDURE DoCloseDocWindow (myWindow: WindowPtr);
	VAR
		myHandle: MyDocRecHnd;
BEGIN
	IF myWindow = NIL THEN
		Exit(DoCloseDocWindow)								{ignore NIL windows}
	ELSE
		BEGIN
			myHandle := MyDocRecHnd(GetWRefCon(myWindow));
			DisposeHandle(Handle(myHandle));
			CloseWindow(myWindow);							{close the window}
			DisposePtr(Ptr(myWindow));						{and release the storage}
		END;
END; {DoCloseDocWindow}

{$S Main}
PROCEDURE DoCloseWindow (myWindow: WindowPtr);
BEGIN
	IF myWindow <> NIL THEN
		IF IsDialogWindow(myWindow) THEN													{this is a dialog window}
			 HideWindow(myWindow)
		ELSE IF IsDAccWindow(myWindow) THEN													{this is a DA window}
			CloseDeskAcc(WindowPeek(myWindow)^.windowKind)
		ELSE IF IsAppWindow(myWindow) THEN													{this is a document window}
			DoCloseDocWindow(myWindow);
END; {DoCloseWindow}

{$S Main}
PROCEDURE DoGoAwayBox (myWindow: WindowPtr; mouseloc: Point);
BEGIN
	IF TrackGoAway(myWindow, mouseloc) THEN
		DoCloseWindow(myWindow)
END; {DoGoAwayBox}

{$S Main}
PROCEDURE DoDiskEvent (myEvent: EventRecord);
	VAR
		myResult:	Integer;
		myPoint:	Point;
BEGIN
	IF HiWord(myEvent.message) <> noErr THEN
		BEGIN
			SetPt(myPoint, 100, 100);
			myResult := DIBadMount(myPoint, myEvent.message);
		END;
END; {DoDiskEvent}

{$S Main}
PROCEDURE DoVennDraw (myWindow: WindowPtr);
	VAR
		count: Integer; myHandle: MyDocRecHnd; state: MyDiagramState; 
		myRect: Rect; myStr: Str255;
BEGIN
	myHandle := MyDocRecHnd(GetWRefCon(myWindow));	

	{Draw Venn circles.}
	FOR count := 1 TO 5 DO
		FrameOval(gGeometry^^.circleRects[count]);

	{Plot Figure Icons.}
	FOR count := 1 TO 4 DO
		DoPlotIcon(gFigureRects[count], gFigureIcons[count], myWindow, srcCopy);
	
	myRect := gFigureRects[myHandle^^.figure];
	InsetRect(myRect, 1, 1); InvertRect(myRect);

	{Plot Mood  Icons.}
	FOR count := 1 TO 12 DO
		DoPlotIcon(gMoodRects[count], gMoodIcons[(count - 1) MOD 4 + 1], 
			myWindow, srcCopy);
	
	FOR count := 1 TO 3 DO
		BEGIN
			myRect := gMoodRects[myHandle^^.mood[count] + 4 * (count - 1)];
			InsetRect(myRect, 1, 1); InvertRect(myRect)
		END;

	WITH myHandle^^ DO
		IF isAnswerShowing THEN
			state := realSolution	{Show real solution.}
		ELSE
			state := userSolution;	{Show user solution.}
	
	LoadResource(Handle(gEmptyPats[gEmptyIndex]));
	HLock(Handle(gEmptyPats[gEmptyIndex]));
	HLock(Handle(gGeometry));

	{Show diagrammer premise regions graphed by the user.}
	WITH myHandle^^, state DO
		FOR count := 1 TO 7 DO
			IF count in premise THEN
				BEGIN
					{Plot existence Icons in premise domain.}
					IF (count IN [3,5,6]) & ((mood[1] IN [3,4]) | (mood[2] IN [3,4])) THEN
						DoPlotIcon(gGeometry^^.exPreRects[count], gExistIcons[gExistIndex],
							myWindow, srcOr)
					ELSE {Fill premise regions.}
						FillRgn(gGeometry^^.premiseRgns[count], gEmptyPats[gEmptyIndex]^^)
				END;

	{Show diagrammer conclusion regions graphed by the user.}
	WITH myHandle^^, state DO
		FOR count := 1 TO 3 DO
			IF count in conc THEN
				IF (count IN [2,3]) & (mood[3] IN [3,4]) THEN
					{Plot existence Icons in conclusion domain.}
					DoPlotIcon(gGeometry^^.exConRects[count], gExistIcons[gExistIndex],
						myWindow, srcOr)
				ELSE {Fill conclusion regions.}
					FillRgn(gGeometry^^.concRgns[count], gEmptyPats[gEmptyIndex]^^);

	HUnlock(Handle(gGeometry));
	HUnlock(Handle(gEmptyPats[gEmptyIndex]));
	
	{Draw 'Figure', 'Mood' texts.}
	TextFont(systemFont); TextSize(12);
	GetIndString(myStr, rMiscStrings, kFigureText);
	MoveTo(20, 224); DrawString(myStr);

	GetIndString(myStr, rMiscStrings, kMoodText);
	MoveTo(94, 224); DrawString(myStr);
	
	{Draw terms text next to each circle in the diagram.}
	HLock(Handle(myHandle));
	TextFont(applFont); TextSize(10);
	WITH gGeometry^^ DO
		BEGIN
			MoveTo(circleRects[1].left + 20, circleRects[1].top - 3);
			DrawString(myHandle^^.terms[1]);
			
			MoveTo(circleRects[2].left + 20, circleRects[2].top - 3);
			DrawString(myHandle^^.terms[2]);
			
			MoveTo(circleRects[3].left + 20, circleRects[3].bottom + 10);
			DrawString(myHandle^^.terms[3]);
			
			MoveTo(circleRects[4].left + 20, circleRects[4].top - 3);
			DrawString(myHandle^^.terms[1]);
			
			MoveTo(circleRects[5].left + 20, circleRects[5].top - 3);
			DrawString(myHandle^^.terms[2])
		END;

	{Draw premise and conlusion texts.}
	TextFont(applFont); TextSize(12);
	WITH myHandle^^ DO
		FOR count := 1 TO 3 DO
			BEGIN
				MoveTo(gTextBoxes[count].left, gTextBoxes[count].bottom-3);
				DrawString(texts[count])
			END;
	HUnlock(Handle(myHandle));

END; {DoVennDraw}

{$S Main}
PROCEDURE DoUpdate (myWindow: WindowPtr);
	VAR
		myHandle:	MyDocRecHnd;
		myRect:		Rect;						{tool rectangle}
		origPort:	GrafPtr;
		origPen:	PenState;
		count:		Integer;
BEGIN
	GetPort(origPort);							{remember original drawing port}
	SetPort(myWindow);

	BeginUpdate(myWindow);						{clear update region}
	EraseRect(myWindow^.portRect);

	IF IsAppWindow(myWindow) THEN
		BEGIN
			{Draw two lines separating tools area from work area.}
			GetPenState(origPen);				{remember original pen state}
			PenNormal;							{reset pen to normal state}
			WITH myWindow^ DO
				BEGIN
					MoveTo(portRect.left, portRect.top + kToolHt);
					Line(portRect.right, 0);
					MoveTo(portRect.left, portRect.top + kToolHt + 2);
					Line(portRect.right, 0);
					MoveTo(150, 267); Line(300, 0)
				END;

			{Redraw the tools area in the window.}
			FOR count := 1 TO kNumTools DO
				BEGIN
					SetRect(myRect, kToolWd * (count - 1), 0, kToolWd * count,
								 kToolHt);
					DoPlotIcon(myRect, gToolsIcons[count], myWindow, srcCopy);
				END;

			{Redraw the status area in the window.}
			myHandle := MyDocRecHnd(GetWRefCon(myWindow));
			DoStatusText(myWindow, myHandle^^.statusText);

			{Draw the rest of the content region.}
			DoVennDraw(myWindow);							

			SetPenState(origPen);				{restore previous pen state}
		END; {IF IsAppWindow}

	EndUpdate(myWindow);
	SetPort(origPort);							{restore original drawing port}
END; {DoUpdate}

{$S Main}
PROCEDURE DoIdle (myEvent: EventRecord);
	VAR
		myWindow:	WindowPtr;
		myHandle:	MyDocRecHnd;
BEGIN
	myWindow := FrontWindow;
	IF IsAppWindow(myWindow) THEN
		IF gAutoAdjust THEN
			BEGIN
				myHandle := MyDocRecHnd(GetWRefCon(myWindow));
				IF myHandle^^.needsAdjusting THEN
					DoVennIdle(myWindow);
			END
END; {DoIdle}

{$S Main}
PROCEDURE DoActivate (myWindow: WindowPtr; myModifiers: Integer);
	VAR
		myState:	Integer;			{activation state}
		myControl:	ControlHandle;
BEGIN
	myState := BAnd(myModifiers, activeFlag);

	IF IsDialogWindow(myWindow) THEN
		BEGIN
			myControl := WindowPeek(myWindow)^.controlList;
			WHILE myControl <> NIL DO
				BEGIN
					HiliteControl(myControl, myState + 255 MOD 256);
					myControl := myControl^^.nextControl;
				END;
		END;
END; {DoActivate}

{$S Main}
PROCEDURE DoOSEvent (myEvent: EventRecord);
	VAR
		myWindow: WindowPtr;
BEGIN
	CASE BSr(myEvent.message, 24) OF
		mouseMovedMessage: 
			BEGIN
				DoIdle(myEvent);	{right now, do nothing}
			END;
		suspendResumeMessage: 
			BEGIN
				myWindow := FrontWindow;
				IF (BAnd(myEvent.message, resumeFlag) <> 0) THEN
					DoActivate(myWindow, activeFlag)		{activate window}
				ELSE
					DoActivate(myWindow, 1 - activeFlag);	{deactivate window}
			END;
		OTHERWISE
			;
	END
END; {DoOSEvent}

{$S Main}
FUNCTION MyModalFilter (myDialog: DialogPtr; VAR myEvent: EventRecord; 
									VAR myItem: Integer): Boolean;
	VAR
		myType:		Integer;
		myHand:		Handle;
		myRect:		Rect;
		myKey:		Char;
		myIgnore:	LongInt;
BEGIN
	MyModalFilter := FALSE;		{assume we don't handle the event}

	CASE myEvent.what OF
		updateEvt: 
				IF WindowPtr(myEvent.message) <> myDialog THEN
					DoUpdate(WindowPtr(myEvent.message));			
										{update the window behind}
		keyDown, autoKey: 
			BEGIN
				myKey := char(BAnd(myEvent.message, charCodeMask));

				{if Return or Enter pressed, do default button}
				IF (myKey = kReturn) OR (myKey = kEnter) THEN
					BEGIN
						GetDItem(myDialog, iOK, myType, myHand, myRect);
						HiliteControl(ControlHandle(myHand), 1);
										{make button appear to have been pressed}
						Delay(kVisualDelay, myIgnore);
						HiliteControl(ControlHandle(myHand), 0);
						MyModalFilter := TRUE;						
						myItem := iOK;
					END;

				{if Escape or Cmd-. pressed, do Cancel button}
				IF (myKey = kEscape)
					OR ((myKey = kPeriod)
							AND (BAnd(myEvent.modifiers, CmdKey) <> 0)) THEN
					BEGIN
						GetDItem(myDialog, iCancel, myType, myHand, myRect);
						HiliteControl(ControlHandle(myHand), 1);	
										{make button appear to have been pressed}
						Delay(kVisualDelay, myIgnore);
						HiliteControl(ControlHandle(myHand), 0);
						MyModalFilter := TRUE;
						myItem := iCancel;
					END;
			END;
		diskEvt: 
			BEGIN
				DoDiskEvent(myEvent);
				MyModalFilter := TRUE;	{show we've handled the event}
			END;
		OTHERWISE
			;
	END; {CASE}
END; {MyModalFilter}

{$S Main}
PROCEDURE DoAboutBox;
	VAR
		myWindow:	WindowPtr;
		myDialog:	DialogPtr;
		myItem:		Integer;
BEGIN
	myWindow := FrontWindow;
	IF myWindow <> NIL THEN
		DoActivate(myWindow, 1 - activeFlag);				

	myDialog := GetNewDialog(rAboutDial, NIL, WindowPtr(-1));
	IF myDialog <> NIL THEN
		BEGIN
			SetPort(myDialog);
			DoDefaultButton(myDialog);

			REPEAT
				ModalDialog(@MyModalFilter, myItem)
			UNTIL myItem = iOK;

			DisposeDialog(myDialog);
			SetPort(myWindow)
		END;
END; {DoAboutBox}

{$S Main}
PROCEDURE DoQuit;
	VAR
		myWindow:	WindowPtr;
BEGIN
	myWindow := FrontWindow;				{close all windows}
	WHILE myWindow <> NIL DO
		BEGIN
			DoUpdate(myWindow);				{force redrawing window}
			DoCloseWindow(myWindow);
			myWindow := FrontWindow
		END;
	gDone := TRUE							{set flag to exit main event loop}
END; {DoQuit}

{$S Main}
PROCEDURE DoMenuCommand (menuAndItem: LongInt);
	CONST kMinTotal = 6200;
	VAR
		myMenuNum:	Integer;
		myItemNum:	Integer;
		myResult:	Integer;
		myDAName:	Str255;
		myWindow:	WindowPtr;
		total, contig: LongInt;
BEGIN
	myMenuNum := HiWord(menuAndItem);
	myItemNum := LoWord(menuAndItem);
	GetPort(myWindow);

	CASE myMenuNum OF
		mApple: 
			CASE myItemNum OF
				iAbout:
					DoAboutBox;
				OTHERWISE
					BEGIN
						GetItem(GetMHandle(mApple), myItemNum, myDAName);
						myResult := OpenDeskAcc(myDAName);
					END;
			END;
		mFile: 
			BEGIN
				CASE myItemNum OF
					iNew: 
						myWindow := DoCreateWindow;
					iClose: 
						DoCloseWindow(FrontWindow);
					iQuit: 
						DoQuit;
					OTHERWISE
						;
				END;
			END;
		mEdit:
				IF NOT SystemEdit(myItemNum - 1) THEN
					;
		mVennD: 
			BEGIN
				myWindow := FrontWindow;
				CASE myItemNum OF
					iCheckVenn:
						DoVennCheck(myWindow);
					iDoVenn:
						DoVennAnswer(myWindow);
					iClearVenn:
						DoVennClear(myWindow);
					iNextTask: 
						DoVennNext(myWindow);
					iCheckArg:
						DoVennAssess(myWindow);
					iGetVennPrefs:
						BEGIN
							{At least kMinTotal is needed for the segment and data}
							{of the Preferences dialog to operate.}
							PurgeSpace(total, contig);
							IF (gPrefsDialog = NIL) AND (total < kMinTotal) THEN
								DoAlertUser(eMemoryLow)
							ELSE
								DoModelessDialog(rVennDPrefsDial, gPrefsDialog)
						END;
					OTHERWISE
						;
				END;
			END;

		OTHERWISE
			;
	END;
	HiliteMenu(0)
END; {DoMenuCommand}

{$S Main}
PROCEDURE DoContentClick (myWindow: WindowPtr; VAR myEvent: EventRecord);
	VAR
		myRect:	Rect;				{temporary rectangle}
		count:	Integer;
BEGIN
	IF NOT IsAppWindow(myWindow) THEN
		Exit(DoContentClick);				{make sure it's a document window}

	SetPort(myWindow);						{set port to our window}
	GlobalToLocal(myEvent.where);

	{See if the click is in the tools area.}
	SetRect(myRect, 0, 0, kToolWd * kNumTools, kToolHt);
	IF PtInRect(myEvent.where, myRect) THEN
		BEGIN								{if so, determine which tool was clicked}
			FOR count := 1 TO kNumTools DO
				BEGIN
					SetRect(myRect, (count - 1) * kToolWd, 0, 
									count * kToolWd, kToolHt);
					IF PtInRect(myEvent.where, myRect) THEN
						Leave;				{we found the right tool, so stop looking}
				END;
			IF DoTrackRect(myWindow, myRect) THEN
				DoMenuCommand(BSL(mVennD, 16) + 
							((kNumTools + 1) - count));	{handle tools selections}
			Exit(DoContentClick)
		END;

	{See if the click is in the status area.}
	SetRect(myRect, kToolWd * kNumTools, 0, myWindow^.portRect.right, kToolHt);
	IF PtInRect(myEvent.where, myRect) THEN
		Exit(DoContentClick);							

	{The click must be in somewhere in the rest of the window.}
	DoVennClick(myWindow, myEvent.where);
END; {DoContentClick}

{$S Main}
PROCEDURE DoMenuAdjust;
	VAR
		myWindow:	WindowPtr;
		myMenu:		MenuHandle;
		count:		Integer;
BEGIN
	myWindow := FrontWindow;

	IF myWindow = NIL THEN
		DisableItem(GetMenu(mFile), iClose)
	ELSE
		EnableItem(GetMenu(mFile), iClose);

	myMenu := GetMenu(mVennD);
	IF IsAppWindow(myWindow) THEN
		FOR count := 1 TO kNumTools DO
			EnableItem(myMenu, count)
	ELSE
		FOR count := 1 TO kNumTools DO
			DisableItem(myMenu, count);

	IF IsDAccWindow(myWindow) THEN
		EnableItem(GetMenu(mEdit), 0)
	ELSE
		DisableItem(GetMenu(mEdit), 0);
	DrawMenuBar
END; {DoMenuAdjust}

{$S Main}
PROCEDURE DoKeyDown(VAR event: EventRecord);
	VAR
		myKey:	char;
BEGIN
	myKey := Chr(BAnd(event.message, charCodeMask));
	IF (BAnd(event.modifiers, CmdKey) <> 0) THEN
		BEGIN
			DoMenuAdjust;
			DoMenuCommand(MenuKey(myKey));
		END
END; {DoKeyDown}

{$S Main}
PROCEDURE DoMouseDown(VAR event: EventRecord);
VAR
		myPart:		Integer;
		myWindow:	WindowPtr;
BEGIN
	myPart := FindWindow(event.where, myWindow);
	CASE myPart OF
		inMenuBar: 
			BEGIN
				DoMenuAdjust;
				DoMenuCommand(MenuSelect(event.where));
			END;
		InSysWindow: 
			SystemClick(event, myWindow);
		inDrag: 
			DoDrag(myWindow, event.where);
		inGoAway: 
			DoGoAwayBox(myWindow, event.where);
		inContent: 
			BEGIN
				IF myWindow <> FrontWindow THEN
					SelectWindow(myWindow)
				ELSE
					DoContentClick(myWindow, event);
			END;
		OTHERWISE
			;
	END;
END; {DoMouseDown}

{$S Main}
PROCEDURE DoMainEventLoop;
	VAR
		myEvent:	EventRecord;
		gotEvent, 
		dlgHandled:	Boolean;			{is returned event for me?}
BEGIN
	REPEAT
		gotEvent := WaitNextEvent(everyEvent, myEvent, 15, NIL);
		dlgHandled := FALSE;

		IF IsDialogEvent(myEvent) THEN
			dlgHandled := DoHandleDialogEvent(myEvent);
			
		IF gotEvent AND NOT dlgHandled THEN
			BEGIN
				CASE myEvent.what OF
					mouseDown: 
						DoMouseDown(myEvent);						{see page 120}
					keyDown, autoKey: 
						DoKeyDown(myEvent);							{see page 160}
					updateEvt: 
						DoUpdate(WindowPtr(myEvent.message));		{see page 124}
					diskEvt: 
						DoDiskEvent(myEvent);						{see page 77}
					activateEvt: 
						DoActivate(WindowPtr(myEvent.message),
										 myEvent.modifiers);		{see page 126}
					osEvt: 
						DoOSEvent(myEvent);							{see page 171}
					keyUp, mouseUp: 
						;
					nullEvent:
						DoIdle(myEvent);							{see page 173}
					OTHERWISE
						;
				END; {CASE}
			END
		ELSE
			DoIdle(myEvent);
	UNTIL gDone;					{loop until user quits}
END; {DoMainEventLoop}

{$S Main}
BEGIN
	UnloadSeg(@_DataInit);		{note that _DataInit must not be in Main!}
	DoInitManagers;				{initialize Toolbox managers}
	DoSetupMenus;				{initialize menus}
	
	gDone := FALSE;				{initialize global variables}
	gNumDocWindows := 0;		{initialize count of open doc windows}
	gPrefsDialog := NIL;		{initialize ptr to Preferences dialog}
	
	gAppsResourceFile := CurResFile;	{get refnum of the app's resource file}
	gPreferencesFile := -1;				{initialize res ID of preferences file}
	
	DoReadPrefs;						{read the user's preference settings}
	DoVennInit;
	UnloadSeg(@DoReadPrefs);	{note that DoReadPrefs, DoVennInit}
	UnloadSeg(@DoVennInit);		{must not be in Main!}

	DoMainEventLoop				{and then loop forever...}
END.
