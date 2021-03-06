#include "Types.r"
#include "SysTypes.r"
#define kMinSize    16      /* application's minimum size (in K) */
#define kPrefSize   16      /* application's preferred size (in K) */
#define kBaseID     128     /* base resource ID */
#define rWind   kBaseID

resource 'WIND' (rWind, purgeable) {
    {40, 5, 40+295, 5+240},
    noGrowDocProc, invisible, goAway, 0x0, "OS Events"
};

resource 'SIZE' (-1) {
    reserved,
    acceptSuspendResumeEvents,
    reserved,
    canBackground,
    multiFinderAware,
    backgroundAndForeground,
    dontGetFrontClicks,
    /*getFrontClicks,*/
    ignoreChildDiedEvents,
    not32BitCompatible,
    ishighLevelEventAware,
    onlyLocalHLEvents,
    notStationeryAware,
    dontUseTextEditServices,
    reserved,
    reserved,
    reserved,
    kPrefSize * 1024,
    kMinSize * 1024
};