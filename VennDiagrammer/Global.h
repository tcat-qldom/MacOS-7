#define     kNameID                     4000        /* resource ID of 'STR#' with filename */
#define     kPrefResType                'PRFN'      /* type of preferences resource */
#define     kPrefResID                  259         /* resource ID of preferences resource */

        /* menu constants (resource IDs and menu command numbers) */

#define         rMenuBar                128         /* menu bar resource ID */

#define         mApple                  128         /* resource ID of Apple menu */
#define         iAbout                  1           /* our About... dialog */

#define         mFile                   129         /* resource ID of File menu */
#define         iNew                    1
#define         iClose                  2
#define         iQuit                   4

#define         mEdit                   130         /* resource ID of Edit menu */
#define         iUndo                   1
#define         iCut                    3
#define         iCopy                   4
#define         iPaste                  5
#define         iClear                  6

#define         mVennD                  131         /* resource ID of Venn menu */
#define         iCheckVenn              1
#define         iDoVenn                 2
#define         iClearVenn              3
#define         iNextTask               4
#define         iCheckArg               5
#define         iGetVennPrefs           7

#define         kNumTools               5

#define         rVennD                  mVennD      /* resource ID of Venn diagram window */
    
        /* dialog boxes and their associated items */
#define         rAboutDial              7000        /* resource ID of About dialog */
#define         iOK                     1           /* OK button */
#define         iCancel                 2           /* Cancel button */

#define         rVennDPrefsDial         3040        /* resource ID of Preferences dialog */
#define         iEmpty1Radio            1           /* dialog item numbers */
#define         iEmpty2Radio            2
#define         iEmpty3Radio            3
#define         iEmpty4Radio            4
#define         iEmpty1Icon             5
#define         iEmpty2Icon             6
#define         iEmpty3Icon             7
#define         iEmpty4Icon             8
#define         iExist1Radio            9
#define         iExist2Radio            10
#define         iExist3Radio            11
#define         iExist4Radio            12
#define         iExist1Icon             13
#define         iExist2Icon             14
#define         iExist3Icon             15
#define         iExist4Icon             16
#define         iGetNextRandomly        19
#define         iAutoAdjust             20
#define         iShowSchoolNames        21
#define         iUseExistImport         22
#define         iSaveVennPrefs          23
#define         kVennPrefsItemCount     23

#define         kCntlActivate           0           /* enabled control's hilite state */
#define         kCntlDeactivate         $FF         /* disabled control's hilite state */

#define         kToolsIconStart         1000        /* base resource ID of tools icons */
#define         kExistID                2000        /* first (of four) icons showing existence */
#define         kEmptyID                3000        /* first (of four) patterns showing emptiness */
#define         kFigIconStart           4000
#define         kMoodIconStart          kFigIconStart + 4
#define         rVennRectID             rVennD      /* resource ID of general 'REC#' Ind resource */

        /* Text strings printed in a Venn diagram window. */

#define         rVennTerms              1000        /* resource ID of 'STR#' for terms */
#define         rSyllogism              rVennTerms + 1
#define         rMiscStrings            1004        /* resource ID of 'STR#' for text items */
#define         kShowAnswerText         1           /* in Venn menu */
#define         kShowUserText           2           /* in Venn menu */
#define         kAllText                3
#define         kNoText                 4
#define         kSomeText               5
#define         kAreText                6
#define         kAreNotText             7
#define         kFigureText             8
#define         kMoodText               9

        /* Venn Diagram window status messages: 'STR#' resource ID rVennD */

#define         eDiagramCorrect         1
#define         eDiagramIncorrect       2
#define         eHereIsSolution         3
#define         eHereIsYourWork         4
#define         eCannotEditAnswer       5
#define         eCannotEraseAnswer      6
#define         eArgIsValid             7
#define         eArgNotValid            8
#define         eExistNotPossible       9

#define         rErrorAlert             129         /* res ID of 'ALRT' resource for error mesgs */
#define         kErrorStrings           1005        /* res ID of 'STR#' resource for error mesgs */
#define         eCantFindMenus          1           /* can't read menu bar resource */
#define         eNotEnoughMemory        2           /* insufficient memory for operation */

        /* Venn Diagrammer custom resource types */

Type 'PRFN' {                           /* preferences resource definition */
    /*bitstring[7] = 0;
    boolean;       autoDiag */          /* bool as LSB of byte */
    byte;       /* autoDiag */          /* bools used as bytes */
    byte;       /* showName */
    byte;       /* isImport */
    byte;       /* isRandom */
    integer;    /* emptyInd */
    integer;    /* existInd */
};

Type 'REC#' {                           /* rectangles defining window content areas */
    integer = $$Countof(RectArray);
    array RectArray {
            Rect;
    };
};

        /* Premise 7, conclusion 3 - regions */ 

#define     none    0   /*regions*/
#define     unused  1   /*[0] 2^0*/
#define     P       2   /*[1] 2^1*/
#define     SP      4   /*[2]*/
#define     S       8   /*[3]*/
#define     MP      16  /*[4]*/
#define     SMP     32  /*[5]*/
#define     SM      64  /*[6]*/
#define     M       128 /*[7]*/

Type 'SLGM' {                           /* resource to keep 24 valid syllogism */
    array Syllogism {                   /*  and answer graphs with existence */
        fill byte;
        byte;           /* figure */
        array[3] {      /* mood */
            byte A = 1, E, I, O;
        };
        align word;
        pstring[9];     /* mnemonic [scholatic] name */
        bitstring[8];   /* premise [P, S, M, ..] */
        fill nibble;
        bitstring[4];   /* conclusion [P, S, SP] */
        bitstring[8];   /* exist. import [P, S, M, ..] */
        fill byte;
    };
};