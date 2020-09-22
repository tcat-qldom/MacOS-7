#define SystemSevenOrLater true

#include "Types.r"
#include "SysTypes.r"
#include "Global.h"

#define kMinSize	44			/* application's minimum size (in K) */
#define kPrefSize	46			/* application's preferred size (in K) */

Include "PAT.rsrc";				/* include empty PATterns made in ResEdit */
Include "DITL.rsrc";			/* include DLOG items made in ResEdit */
Include "ICON.rsrc";			/* include ICONs made in ResEdit */

Resource 'MBAR' (rMenuBar, preload) {
	{
		mApple, mFile, mEdit, mVennD
	}
};

Resource 'MENU' (mApple, preload) {
	mApple,
	textMenuProc,
	allEnabled,
	enabled,
	Apple,
	{
		/* [1] */
		"About Venn Diagrammer…", noIcon, noKey, noMark, plain,
		/* [2] */
		"-", noIcon, noKey, noMark, plain
	}
};

Resource 'MENU' (mFile, preload) {
	mFile,
	textMenuProc,
	0b1011,
	enabled,
	"File",
	{
		/* [1] */
		"New", noIcon, "N", noMark, plain,
		/* [2] */
		"Close", noIcon, "W", noMark, plain,
		/* [3] */
		"-", noIcon, noKey, noMark, plain,
		/* [4] */
		"Quit", noIcon, "Q", noMark, plain
	}
};

Resource 'MENU' (mEdit, preload) {
	mEdit,
	textMenuProc,
	0x0,
	disabled,
	"Edit",
	{
		/* [1] */
		"Undo", noIcon, "Z", noMark, plain,
		/* [2] */
		"-", noIcon, noKey, noMark, plain,
		/* [3] */
		"Cut", noIcon, "X", noMark, plain,
		/* [4] */
		"Copy", noIcon, "C", noMark, plain,
		/* [5] */
		"Paste", noIcon, "V", noMark, plain,
		/* [6] */
		"Clear", noIcon, noKey, noMark, plain
	}
};

Resource 'MENU' (mVennD, preload) {
	mVennD,
	textMenuProc,
	0b1011111,
	enabled,
	"Venn",
	{
		/* [1] */
		"Check", noIcon, "K", noMark, plain,
		/* [2] */
		"Show Solution", noIcon, "G", noMark, plain,
		/* [3] */
		"Clear", noIcon, "B", noMark, plain,
		/* [4] */
		"Get Next Settings", noIcon, noKey, noMark, plain,
		/* [5] */
		"Asses Validity", noIcon, noKey, noMark, plain,
		/* [6] */
		"-", noIcon, noKey, noMark, plain,
		/* [7] */
		"Preferences", noIcon, "Y", noMark, plain
	}
};

Resource 'PRFN' (kPrefResID, purgeable) {
	/* autoDiag, showName, isImport, isRandom, emptyInd, existInd */
		true, 	  true, 	false,	  false,	  1, 		1
};
 
Resource 'DLOG' (rVennDPrefsDial, purgeable) {																		/*dialog resource*/
	{84, 82, 264, 362},
	noGrowDocProc,
	visible,
	goAway,
	0x0,
	rVennDPrefsDial,
	"Venn Diagram Preferences",
	noAutoCenter
};
 
Resource 'DLOG' (rAboutDial, purgeable) {																		/*dialog resource*/
	{40, 20, 40+188, 20+308},
	dBoxProc,
	visible,
	noGoAway,
	0x0,
	rAboutDial,
	"",
	noAutoCenter
};
 
Resource 'ALRT' (rErrorAlert, purgeable) {																		/*dialog resource*/
	{80, 40, 80+108, 40+394},
	rErrorAlert,
	{
		OK, visible, sound1,
		OK, visible, sound1,
		OK, visible, sound1,
		OK, visible, sound1
	},
	noAutoCenter
};

Resource 'DITL' (rErrorAlert, purgeable) {
	{
		/* [1] */ 
		{72, 165, 92, 235}, 
		Button {enabled, "OK"},
		/* [2] */ 
		{7, 70, 58, 400}, 
		StaticText {disabled, "^0"}
	}
};

Resource 'STR#' (kNameID, purgeable) {
	{
	/*[1]*/ "Venn Diagrammer Prefs"
	}
};

Resource 'STR#' (kErrorStrings, purgeable) {
	{
	/*[1]*/ "Cannot find application resources.\n"
			"This copy of the application might be corrupt.\n"
			"Try replacing it with a back up copy.",
	/*[2]*/ "There is not enough memory to run\n"
			"the application.\n"
			"Try increasing application size partition.",
	/*[3]*/ "There is not enough memory to complete\n"
			"the operation.\n"
			"You may have too many windows open."
	}
};

Resource 'STR#' (rVennTerms, purgeable) {
	{	/* (P)redicate, (S)ubject, (M)iddle term */
	/*[1]*/ "logicians", "mathematicians", "philosophers",
	/*[2]*/ "mortals", "Greeks", "men",
	/*[3]*/ "oaks", "maples", "trees",
	/*[4]*/ "properties", "qualities", "characteristics",
	/*[5]*/ "men", "Greeks", "mortals",
	/*[6]*/ "fur", "snakes", "reptiles",
	/*[7]*/ "fur", "pets", "rabbits",
	/*[8]*/ "fun", "reading", "homeworks",
	/*[9]*/ "cats", "pets", "mammals",
	/*[10]*/ "pets", "mammals", "cats",
	/*[11]*/ "horses", "humans", "hooves",
	/*[12]*/ "animals", "plants", "flowers",
	/*[13]*/ "rectangles", "rhombs", "squares"
	}
};

Resource 'SLGM' (rSyllogism, purgeable) {
	{	/* figure, mood[3], name[9], premise[P,S,M,..], conclusion[P,S,SP], exist[..] */
		/* full set P | SP | S | MP | SMP | SM | M */
	/*[1]*/
		1, {A, A, A}, "Barbara", SP | S | SM | M, S, none,
		1, {E, A, E}, "Celarent", SP | S | MP | SMP, SP, none,
		1, {A, I, I}, "Darii", SMP | SM | M, SP, unused,
		1, {E, I, O}, "Ferio", MP | SMP | SM, S, unused,
		1, {A, A, I}, "Barbari", SP | S | SM | M, SP, SMP,
		1, {E, A, O}, "Celaront", SP | S | MP | SMP, S, SM,
	/*[7]*/
		2, {E, A, E}, "Cesare", SP | S | MP | SMP, SP, none,
		2, {A, E, E}, "Camestres", P | SP | SMP | SM, SP, none,
		2, {E, I, O}, "Festino", MP | SMP | SM, S, unused,
		2, {A, O, O}, "Baroco", P | SP | S, S, unused,
		2, {E, A, O}, "Cesaro", SP | S | MP | SMP, S, SM,
		2, {A, E, O}, "Camestros", P | SP | SMP | SM, S, S,
	/*[13]*/
		3, {A, I, I}, "Datisi", SMP | SM | M, SP, unused,
		3, {I, A, I}, "Disamis", MP | SMP | M, SP, unused,
		3, {E, I, O}, "Ferison", MP | SMP | SM, S, unused,
		3, {O, A, O}, "Bocardo", MP | SM | M, S, unused,
		3, {E, A, O}, "Felapton", MP | SMP | M, S, SM,
		3, {A, A, I}, "Darapti", MP | SM | M, SP, SMP,
	/*[19]*/
		4, {A, E, E}, "Calemes", P | SP | SMP | SM, SP, none,
		4, {I, A, I}, "Dimatis", MP | SMP | M, SP, unused,
		4, {E, I, O}, "Fresison", MP | SMP | SM, S, unused,
		4, {A, E, O}, "Calemos", P | SP | SMP | SM, S, S,
		4, {E, A, O}, "Fesapo", MP | SMP | M, S, SM,
		4, {A, A, I}, "Bamalip", P | SP | MP | M, SP, SMP
	/*[25]*/
	}
};

Resource 'STR#' (rMiscStrings, purgeable) {
	{
	/*[1]*/ "Show answer",
	/*[2]*/ "Show user",
	/*[3]*/ "All",
	/*[4]*/ "No",
	/*[5]*/ "Some",
	/*[6]*/ "are",
	/*[7]*/ "are not",
	/*[8]*/ "Figure",
	/*[9]*/ "Mood"
	}
};

Resource 'STR#' (rVennD, purgeable) {
	{
	/*[1]*/ "Diagram is correct.",
	/*[2]*/ "Diagram is incorrect.",
	/*[3]*/ "Here is the solution.",
	/*[4]*/ "Here is your work.",
	/*[5]*/ "Cannot edit answer.",
	/*[6]*/ "Cannot erase answer.",
	/*[7]*/ "Argument is valid.",
	/*[8]*/ "Argument is not valid.",
	/*[9]*/ "Existence not possible"
	}
};

Resource 'REC#' (rVennRectID, purgeable) {
	{
	/*[1]*/ {32, 32, 132, 132}, 	/* circles */
	/*[2]*/ {32, 100, 132, 200},
	/*[3]*/ {90, 66, 190, 166},
	/*[4]*/ {32, 262, 132, 362},
	/*[5]*/ {32, 330, 132, 430},
	/*[6]*/ {228, 10, 244, 26},		/* figures */
	/*[7]*/ {228, 26-1, 244, 42-1},
	/*[8]*/ {228, 42-2, 244, 58-2},
	/*[9]*/ {228, 58-3, 244, 74-3},
	/*[10]*/ {228, 80, 244, 96},		/* moods row 1 */
	/*[11]*/ {228, 96-1, 244, 112-1},
	/*[12]*/ {228, 112-2, 244, 128-2},
	/*[13]*/ {228, 128-3, 244, 144-3},
	/*[14]*/ {248, 80, 264, 96},		/* moods row 2 */
	/*[15]*/ {248, 96-1, 264, 112-1},
	/*[16]*/ {248, 112-2, 264, 128-2},
	/*[17]*/ {248, 128-3, 264, 144-3},
	/*[18]*/ {268, 80, 284, 96},		/* moods row 3 */
	/*[19]*/ {268, 96-1, 284, 112-1},
	/*[20]*/ {268, 112-2, 284, 128-2},
	/*[21]*/ {268, 128-3, 284, 144-3},
	/*[22]*/ {230, 152, 230+15, 152+300},	/* premises texts */
	/*[23]*/ {250, 152, 250+15, 152+300},
	/*[24]*/ {270, 152, 270+15, 152+300},	/* conlusion texts */
	/*[25]*/ /*[1]*/ {0, 0, 0, 0},			/* existence in premise */
	/*[26]*/ /*[2]*/ {0, 0, 0, 0},
	/*[27]*/ /*[3]*/ {64, 160, 64+16, 160+16},
	/*[28]*/ /*[4]*/ {0, 0, 0, 0},
	/*[29]*/ /*[4]*/ {94, 108, 94+16, 108+16},
	/*[30]*/ /*[6]*/ {108, 133, 108+16, 133+16},
	/*[31]*/ /*[7]*/ {0, 0, 0, 0},
	/*[32]*/ /*[1]*/ {0, 0, 0, 0},			/* existence in conclusion */
	/*[33]*/ /*[2]*/ {74, 338, 74+16, 338+16},
	/*[34]*/ /*[3]*/ {74, 380, 74+16, 380+16}
	}
};

Resource 'WIND' (rVennD, purgeable) {
	{40, 5, 40+290, 5+460},
	noGrowDocProc, invisible, goAway, 0x0, "Venn Diagrammer", noAutoCenter
};

Resource 'SIZE' (-1) {
	reserved,
	acceptSuspendResumeEvents,
	reserved,
	canBackground,
	multiFinderAware,
	backgroundAndForeground,
	dontGetFrontClicks,
	ignoreChildDiedEvents,
	not32BitCompatible,
	notHighLevelEventAware,
	onlyLocalHLEvents,
	notStationeryAware,
	dontUseTextEditServices,
	reserved,
	reserved,
	reserved,
	kPrefSize * 1024,
	kMinSize * 1024
};