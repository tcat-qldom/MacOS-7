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

Source files were converted with,

	$ sed -i s/\\r/\\n/g [file]

replacing CR line ending with LF, so they can be viewed right in GIT browser. Archive contains source texts along with binaries and resources compressed in Stuff-It.


# Venn Diagrammer

Have you ever fancied classic Mac programming? Here is how - this is a functional application documented in `Inside Macintosh - Overview' book. It evaluates syllogism in Venn circles, based on the figure and mood. While the book's main focus is on user interface coding, some parts are left undefined. Fortunattely there are usefull hints given inside, that make it possible to code those missing parts. 

Not beeing a 'logician' nor 'mathematician' apologies for any typos [bugs] in the code :-) 

![RGB](Syllogism.png??raw=true "Venn diagrams")


# Tour de MacBug

![RGB](MacBug.png??raw=true "User Break")

