UNIT Global;
INTERFACE
	USES
		QuickDraw, Dialogs;

	CONST
		{menu constants (resource IDs and menu command numbers)}
		rMenuBar				= 128;			{menu bar resource ID}

		mApple					= 128;			{resource ID of Apple menu}
		iAbout					= 1;			{our About... dialog}

		mFile					= 129;			{resource ID of File menu}
		iNew					= 1;
		iClose					= 2;
		iQuit					= 4;

		mEdit					= 130;			{resource ID of Edit menu}
		iUndo					= 1;
		iCut					= 3;
		iCopy					= 4;
		iPaste					= 5;
		iClear					= 6;

		mVennD					= 131;			{resource ID of Venn menu}
		iCheckVenn				= 1;
		iDoVenn					= 2;
		iClearVenn				= 3;
		iNextTask				= 4;
		iCheckArg				= 5;
		iGetVennPrefs			= 7;

		kNumTools				= 5;

		rVennD					= mVennD;		{resource ID of Venn diagram window}
	
		{dialog boxes and their associated items}
		rAboutDial				= 7000;			{resource ID of About dialog}
		iOK						= 1;			{OK button}
		iCancel					= 2;			{Cancel button}

		rVennDPrefsDial			= 3040;			{resource ID of Preferences dialog}
		iEmpty1Radio			= 1;			{dialog item numbers}
		iEmpty2Radio			= 2;
		iEmpty3Radio			= 3;
		iEmpty4Radio			= 4;
		iEmpty1Icon				= 5;
		iEmpty2Icon				= 6;
		iEmpty3Icon				= 7;
		iEmpty4Icon				= 8;
		iExist1Radio			= 9;
		iExist2Radio			= 10;
		iExist3Radio			= 11;
		iExist4Radio			= 12;
		iExist1Icon				= 13;
		iExist2Icon				= 14;
		iExist3Icon				= 15;
		iExist4Icon				= 16;
		iGetNextRandomly		= 19;
		iAutoAdjust				= 20;
		iShowSchoolNames		= 21;
		iUseExistImport			= 22;
		iSaveVennPrefs			= 23;
		kVennPrefsItemCount		= 23;

		kVisualDelay			= 8;			{ticks to invert a button to simulate press}
		kCntlActivate			= 0;			{enabled control's hilite state}
		kCntlDeactivate			= $FF;			{disabled control's hilite state}

		kToolHt					= 14;			{height of a tool icon}
		kToolWd					= 21;			{width of a tool icon}

		kToolsIconStart 		= 1000;			{base resource ID of tools icons}
		kExistID				= 2000;			{first (of four) icons showing existence}
		kEmptyID				= 3000;			{first (of four) patterns showing emptiness}
		kFigIconStart 			= 4000;			{first (of four) figure, mood icons}
		kMoodIconStart 			= kFigIconStart + 4;
		rVennRectID 			= rVennD;		{resource ID of general 'REC#' Ind resource}
		kFigRectStart			= 6;
		kMoodRectStart			= 10;
		kTextRectStart			= 22;
		kExPreRectStart			= 25;
		kExConRectStart			= 32;

		{Text strings printed in a Venn diagram window.}
		rVennTerms				= 1000;			{resource ID of 'STR#' for terms}
		rSyllogism				= rVennTerms + 1; {resource ID of 'SLGM' of valid syllogism}
		kFigure1				= 1;			{24 valid, 6 in each figure 1..4}
		kFigure2				= kFigure1 + 6;
		kFigure3				= kFigure1 + 12;
		kFigure4				= kFigure1 + 18;
		rMiscStrings			= 1004;			{resource ID of 'STR#' for text items}
		kShowAnswerText			= 1;			{in Venn menu}
		kShowUserText			= 2;			{in Venn menu}
		kAllText				= 3;
		kNoText					= 4;
		kSomeText				= 5;
		kAreText				= 6;
		kAreNotText				= 7;
		kFigureText				= 8;
		kMoodText				= 9;

		{Venn Diagram window status messages: 'STR#' resource ID = rVennD}
		eDiagramCorrect			= 1;
		eDiagramIncorrect		= 2;
		eHereIsSolution			= 3;
		eHereIsYourWork			= 4;
		eCannotEditAnswer		= 5;
		eCannotEraseAnswer		= 6;
		eArgIsValid				= 7;
		eArgNotValid			= 8;
		eExistNotPossible		= 9;

		rErrorAlert				= 129;			{res ID of 'ALRT' resource for error mesgs}
		kErrorStrings			= 1005;			{res ID of 'STR#' resource for error mesgs}
		eCantFindMenus			= 1;			{can't read menu bar resource}
		eNotEnoughMemory		= 2;			{insufficient memory to run application}
		eMemoryLow				= 3;			{low memory to complete operation}

		{constants defining several keyboard characters}
		kEnter					= Chr(3);		{the enter character}
		kReturn					= Chr(13);		{the return character}
		kEscape					= Chr(27);		{the escape character}
		kPeriod					= '.';			{the period character}

	TYPE 
		MyGeometryRec = RECORD
			circleRects: 	ARRAY[1..5] OF Rect;		{squares for the 5 circles}
			circleRgns:		ARRAY[1..5] OF RgnHandle;	{regions for the 5 circles}
			premiseRgns:	ARRAY[1..7(*8*)] OF RgnHandle;	{regions for premises}
			concRgns:		ARRAY[1..3(*4*)] OF RgnHandle;	{regions for conclusion}
			{fields omitted in the book}				{sqaures for ..}
			exPreRects:		ARRAY[1..7] OF Rect;			{7 (3 valid) existence symbols in premise}
			exConRects:		ARRAY[1..3] OF Rect;			{3 (2 valid) existence symbols in conclusion}
		END;
		MyGeometryPtr = ^MyGeometryRec;
		MyGeometryHnd = ^MyGeometryPtr;
		
		MyDiagramState = RECORD
			premise: SET OF 1..7(*8*);				{set of regions graphed by the user}
			conc: SET OF 1..3(*4*);					{premise, conlusion, and}
			exist: SET OF 0..7;						{existential import}
		END; {omitted in the book}
		
		MyDocRec = RECORD							{information for a document window}
			figure:			Integer;				{the figure of the syllogism}
			mood:			ARRAY[1..3] OF Integer;	{the moods of the statements}
			terms:			ARRAY[1..3] OF Str31;	{the three terms}
			texts: 			ARRAY[1..3] OF Str63;	{syllogism premises, concl. texts}
			statusText:		Str255;					{most recent status message}
			userSolution:	MyDiagramState;			{user's diagram state}
			realSolution:	MyDiagramState;			{answer's diagram state}
			isAnswerShowing: Boolean;				{is the answer showing?}
			isExistImport:	Boolean;				{stmts imply exists subject?}
			needsAdjusting:	Boolean;				{diagram needs adjusting?}
			currTerm:		Integer;				{current term settings}
		END;
		MyDocRecPtr = ^MyDocRec;
		MyDocRecHnd = ^MyDocRecPtr;	

	VAR
		gDone: Boolean;

		gNumDocWindows: 	Integer;				{the number of open document windows}
		gPrefsDialog:		DialogPtr;				{pointer to Preferences dialog window}
		gAppsResourceFile:	Integer;				{reference number of app's res file}
		gPreferencesFile:	Integer;				{reference number of app's prefs file}

		gGeometry:			MyGeometryHnd;					{handle to a geometry record}
		gToolsIcons:		ARRAY[1..kNumTools] OF Handle;	{handles to tools icons}
		gEmptyPats:			ARRAY[1..4] OF PatHandle;		{handles to emptiness patterns}
		gExistIcons:		ARRAY[1..4] OF Handle;			{handles to existence symbols}
		gMoodIcons:			ARRAY[1..4] OF Handle;			{handles to mood icons}
		gFigureIcons:		ARRAY[1..4] OF Handle;			{handles to figure icons}
		gFigureRects:		ARRAY[1..4] OF Rect;			{squares for the four figures}
		gMoodRects:			ARRAY[1..12] OF Rect;			{squares for the 12 moods}
		gTextBoxes:			ARRAY[1..3] OF Rect;			{squares for premise, concl. texts}

		gExistIndex:		Integer;				{rank of icon showing existence}
		gEmptyIndex:		Integer;				{rank of icon showing emptiness}
		gStepRandom:		Boolean;				{generate next setup randomly?}
		gAutoAdjust: 		Boolean;				{automatically adjust the diagram?}
		gGiveImport:		Boolean;				{do subjects have existential import?}
		gShowNames:			Boolean;				{do we show names of valid forms?}
		
IMPLEMENTATION
END. {UNIT Global}