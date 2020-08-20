# MacOS-7.1

**System 7 events**

System7 introducing MultiFinder and task switching, the concept of foreground and background process running. Applications are event driven, with 'Hollywood' principle, "don't call us, we will call you".

Events passed to the app, are controlled by SIZE resource ID of -1.

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

**Background**

![RGB](OS71-Events-bg.png??raw=true "System7 events")

**Foreground**

![RGB](OS71-Events.png??raw=true "System7 events")

To view source files in MyApps folder on ux* systems,

	$ sed s/\\r/\\n/g [file] | less

replacing CR line ending with LF, a suitable text editor will convert with whatever needed for your OS.
