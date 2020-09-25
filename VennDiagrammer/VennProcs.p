UNIT VennProcs;                         {Routines evaluating syllogism}
INTERFACE                               {this is the application logic}
    USES
        QuickDraw, Types, ToolUtils, Windows, Dialogs, Resources, Memory,
        Global, Utilities;

    {                       Figure
                    1       2       3       4
        Premise 1   M-P     P-M     M-P     P-M
                2   S-M     S-M     M-S     M-S
        Conclusion      <->     S-P     <->
                
        (P)redicate, (M)middle, (S)ubject - terms
        
        AI - Affirmo, EO - Nego

        A - All (S) are (P)         Quantifier: All, No, Some   
        E - No (S) are (P)          Copula: are[is], are not
        I - Some (S) are (P)
        O - Some (S) are not (P)
    }

    CONST
        rSyllogismType = 'SLGM';
        rSyllogismID = 1001;
        kNumValidSyllogism = 24;
        kNumTerms = 13;
        A = 1; E = 2; I = 3; O = 4;
        P = 1; S = 2; M = 3;
        
    TYPE
        MySyllogismEntry = RECORD
            fig: Byte;                      {figure}
            md: PACKED ARRAY[1..3] OF Byte; {moods}
            name: String[9];
            pre: SET OF 1..7(*8*);          {premise}
            con: SET OF 1..3(*4*);          {conclusion}
            ex: SET OF 0..7;                {exist. import}
        END;
        MySyllogism = ARRAY[1..kNumValidSyllogism] OF MySyllogismEntry;
        MySyllogismPtr = ^MySyllogism;
        MySyllogismHnd = ^MySyllogismPtr;

    PROCEDURE DoVennCheck(myWindow: WindowPtr);
    PROCEDURE DoVennAnswer(myWindow: WindowPtr);
    PROCEDURE DoVennClear(myWindow: WindowPtr);
    PROCEDURE DoVennNext(myWindow: WindowPtr);
    PROCEDURE DoVennAssess(myWindow: WindowPtr);
    PROCEDURE DoGetRandomTerms(myWindow: WindowPtr);
    PROCEDURE DoCalcAnswer(myWindow: WindowPtr);
    PROCEDURE DoVennIdle(myWindow: WindowPtr);
    
IMPLEMENTATION
{$S VennProcs}

    PROCEDURE DoVennCheck(myWindow: WindowPtr);
        VAR myHandle: MyDocRecHnd; myStr, myMesg: Str255;
            count: Integer;
    BEGIN
        myHandle := MyDocRecHnd(GetWRefCon(myWindow));
        WITH myHandle^^ DO
            IF (userSolution.premise = realSolution.premise) AND
                    (userSolution.conc = realSolution.conc) THEN
                IF gGiveImport THEN
                    WITH realSolution DO
                    BEGIN

                        {Show existential import to subject.}
                        FOR count := 1 TO 7 DO
                            IF count IN exist THEN
                                DoPlotIcon(gGeometry^^.exPreRects[count],
                                    gExistIcons[gExistIndex], myWindow, srcOr);

                        {Existential import not possible.}
                        IF exist = [] THEN
                            BEGIN
                                GetIndString(myMesg, rVennD, eDiagramCorrect);
                                GetIndString(myStr, rVennD, eExistNotPossible);
                                myMesg := ConCat(myMesg, ' (', myStr, ')');
                                DoStatusText(myWindow, myMesg)
                            END
                        ELSE
                            DoStatusMesg(myWindow, eDiagramCorrect)
                    END {WITH}
                ELSE {NOT gGiveImport}
                    DoStatusMesg(myWindow, eDiagramCorrect)
            ELSE
                DoStatusMesg(myWindow, eDiagramIncorrect)
    END; {DoVennCheck}
    
    PROCEDURE DoVennAnswer(myWindow: WindowPtr);
        VAR count: Integer; myHandle: MyDocRecHnd;
    BEGIN
        myHandle := MyDocRecHnd(GetWRefCon(myWindow));
        WITH myHandle^^ DO
            BEGIN
                isAnswerShowing := NOT isAnswerShowing;
    
                IF isAnswerShowing THEN
                    DoStatusMesg(myWindow, eHereIsSolution)
                ELSE
                    DoStatusMesg(myWindow, eHereIsYourWork)
            END;

        FOR count := 1 TO 5 DO
            InvalRect(gGeometry^^.circleRects[count])       
    END; {DoVennAnswer}
    
    PROCEDURE DoVennClear(myWindow: WindowPtr);
        VAR
            count: Integer; myHandle: MyDocRecHnd;
    BEGIN
        myHandle := MyDocRecHnd(GetWRefCon(myWindow));
        WITH myHandle^^ DO
            IF isAnswerShowing THEN
                    DoStatusMesg(myWindow, eCannotEraseAnswer)
            ELSE
                BEGIN
                    DoStatusText(myWindow, '');
                    userSolution.premise := [];     {Reset to empty sets.}
                    userSolution.conc := [];
            
                    FOR count := 1 TO 5 DO          {Force redraw of the circles.}
                        InvalRect(gGeometry^^.circleRects[count])
                END
    END; {DoVennClear}

    PROCEDURE DoVennNext(myWindow: WindowPtr);
        VAR count: Integer;
            myHandle: MyDocRecHnd;
            myStr: Str255;
    BEGIN
        myHandle := MyDocRecHnd(GetWRefCon(myWindow));
        IF gStepRandom THEN
            DoGetRandomTerms(myWindow)
        ELSE
            WITH myHandle^^ DO
                BEGIN
                    currTerm := currTerm + 3;
                    IF currTerm > (kNumTerms - 1) * 3 THEN currTerm := 0;
                    FOR count := 1 TO 3 DO
                        BEGIN
                            GetIndString(myStr, rVennTerms, currTerm + count);
                            terms[count] := myStr
                        END     
                END;

        DoCalcAnswer(myWindow);
        InvalRect(myWindow^.portRect)
    END; {DoVennNext}

    PROCEDURE DoVennAssess(myWindow: WindowPtr);
        VAR
            valid: Boolean; myName: Str15; myMesg: Str255;
            myHandle: MyDocRecHnd; slgmHnd: MySyllogismHnd;
            count: Integer;
    BEGIN
        valid := FALSE; myName := '';

        myHandle := MyDocRecHnd(GetWRefCon(myWindow));
        slgmHnd := MySyllogismHnd(Get1Resource(rSyllogismType, rSyllogismID));

        IF slgmHnd = NIL THEN Exit(DoVennAssess);

        {Look up valid syllogism for current figure and mood.}
        FOR count := 1 TO kNumValidSyllogism DO
            WITH myHandle^^, slgmHnd^^[count] DO
                BEGIN
                    valid := (figure = fig) AND 
                        (mood[1] = md[1]) AND (mood[2] = md[2]) AND (mood[3] = md[3]);
                    IF valid THEN BEGIN myName := name; Leave END
                END;

        IF valid THEN
            BEGIN
                IF gShowNames THEN  {Show names of valid syllogisms?}
                    BEGIN
                        GetIndString(myMesg, rVennD, eArgIsValid);
                        (*DoGetName(myWindow, myName);*) {not used}
                        myMesg := ConCat(myMesg, ' (', myName, ')');
                        DoStatusText(myWindow, myMesg);
                    END
                ELSE
                    DoStatusMesg(myWindow, eArgIsValid);
            END
        ELSE
            DoStatusMesg(myWindow, eArgNotValid);
    END; {DoVennAssess}

    PROCEDURE DoGetRandomTerms(myWindow: WindowPtr);
        VAR count: Integer;
            myHandle: MyDocRecHnd;
            myStr: Str255;
    BEGIN
        myHandle := MyDocRecHnd(GetWRefCon(myWindow));
        WITH myHandle^^ DO
            currTerm := MyRandom(kNumTerms - 1) * 3;

        WITH myHandle^^ DO
            FOR count := 1 TO 3 DO
                BEGIN
                    GetIndString(myStr, rVennTerms, currTerm + count);
                    terms[count] := myStr
                END     
    END; {DoGetRandomTerms}
    
    PROCEDURE DoCalcArgument(myHandle: MyDocRecHnd);
        TYPE
            Str8 = String[8];
        VAR
            count: Integer;
            All, No, Some, Are, AreNot, Quantifier, Copula: Str8;
            myStr: Str255;
    BEGIN
        GetIndString(myStr, rMiscStrings, kAllText); All := myStr;
        GetIndString(myStr, rMiscStrings, kNoText); No := myStr;
        GetIndString(myStr, rMiscStrings, kSomeText); Some := myStr;
        GetIndString(myStr, rMiscStrings, kAreText); Are := myStr;
        GetIndString(myStr, rMiscStrings, kAreNotText); AreNot := myStr;

        WITH myHandle^^ DO
            BEGIN
            
                {Major premise - 1}
                CASE mood[1] OF
                    A: BEGIN Quantifier := All; Copula := Are END;
                    E: BEGIN Quantifier := No; Copula := Are END;
                    I: BEGIN Quantifier := Some; Copula := Are END;
                    O: BEGIN Quantifier := Some; Copula := AreNot END
                END;
    
                CASE figure OF
                    1,3: texts[1] := ConCat(Quantifier, ' ',
                            terms[M], ' ', Copula, ' ', terms[P], '.');
                    2,4: texts[1] := ConCat(Quantifier, ' ',
                            terms[P], ' ', Copula, ' ', terms[M], '.')
                END;

                {Minor premise - 2}
                CASE mood[2] OF
                    A: BEGIN Quantifier := All; Copula := Are END;
                    E: BEGIN Quantifier := No; Copula := Are END;
                    I: BEGIN Quantifier := Some; Copula := Are END;
                    O: BEGIN Quantifier := Some; Copula := AreNot END
                END;
        
                CASE figure OF
                    1,2: texts[2] := ConCat(Quantifier, ' ',
                            terms[S], ' ', Copula, ' ', terms[M], '.');
                    3,4: texts[2] := ConCat(Quantifier, ' ',
                            terms[M], ' ', Copula, ' ', terms[S], '.')
                END;

                {Conclusion - 3}
                CASE mood[3] OF
                    A: BEGIN Quantifier := All; Copula := Are END;
                    E: BEGIN Quantifier := No; Copula := Are END;
                    I: BEGIN Quantifier := Some; Copula := Are END;
                    O: BEGIN Quantifier := Some; Copula := AreNot END
                END;
        
                texts[3] := ConCat(Quantifier, ' ',
                        terms[S], ' ', Copula, ' ', terms[P], '.')
            END {WITH}
    END; {DoCalcArgument}
    
    PROCEDURE DoCalcAnswer(myWindow: WindowPtr);
        VAR
            found: Boolean;
            myHandle: MyDocRecHnd; slgmHnd: MySyllogismHnd;
            count: Integer;
    BEGIN
        myHandle := MyDocRecHnd(GetWRefCon(myWindow));
        DoCalcArgument(myHandle);

        found := FALSE;
        slgmHnd := MySyllogismHnd(Get1Resource(rSyllogismType, rSyllogismID));

        IF slgmHnd = NIL THEN Exit(DoCalcAnswer);

        FOR count := 1 TO kNumValidSyllogism DO
            WITH myHandle^^, slgmHnd^^[count] DO
                BEGIN
                    found := (figure = fig) AND 
                        (mood[1] = md[1]) AND (mood[2] = md[2]) AND (mood[3] = md[3]);
                    IF found THEN Leave
                END;

        IF found THEN
            WITH myHandle^^.realSolution, slgmHnd^^[count] DO
                BEGIN
                    premise := pre;
                    conc := con;
                    exist := ex
                END
    END; {DoCalcAnswer}

    PROCEDURE DoVennIdle(myWindow: WindowPtr);
        VAR myHandle: MyDocRecHnd;
    BEGIN
        myHandle := MyDocRecHnd(GetWRefCon(myWindow));
        LoadResource(Handle(gEmptyPats[gEmptyIndex]));
        HLock(Handle(gEmptyPats[gEmptyIndex]));
        
        {Update regions, ambigious for placing existence symbol or marking as empty.}
        WITH myHandle^^ DO
        BEGIN
            needsAdjusting := FALSE;
            IF userSolution.premise >= [5,6] THEN   {Update regions SMP or SM.}
                {Darii, Datisi}
                IF (figure IN [1,3]) & (mood[1] = A) & (mood[2] = I) & (mood[3] = I) THEN
                    FillRgn(gGeometry^^.premiseRgns[6], gEmptyPats[gEmptyIndex]^^)
                {Ferio, Festino, Ferison, Fresison.}
                ELSE IF (figure IN [1..4]) & (mood[1] = E) & (mood[2] = I) & (mood[3] = O) THEN
                    FillRgn(gGeometry^^.premiseRgns[5], gEmptyPats[gEmptyIndex]^^)
        END;
        HUnlock(Handle(gEmptyPats[gEmptyIndex]))
    END; {DoVennIdle}

END. {UNIT VennProcs}