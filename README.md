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

Have you ever fancied classic Mac programming? Here is how - this is a functional application documented in 'Inside Macintosh - Overview' book. It evaluates syllogism in Venn circles, based on the figure and mood. While the book's main focus is on user interface coding, some parts are left undefined. Fortunattely there are usefull hints given inside, that make it possible to code those missing parts. 

Not beeing a 'logician' nor 'mathematician' apologies for any typos [bugs] in the code :-) 

![RGB](Syllogism.png??raw=true "Venn diagrams")


# Tour de MacsBug

HD (Heap Dump)  and HT (Heap Total) commands show allocation in the heap.

![RGB](MacsBug.png??raw=true "User Break")

MacsBug is a low level debugger, It is an indispensable tool for every Mac and progarmmer. It can catch most if not all exceptions, allows user debug output messages, debug low mem conditions, help finding dangling pointers, sensible app segment strategy, and much more.

Here it is used to determine low mem conditions, and appropriate segment strategy for Venn Diagrammer. The minimum breathing room for app to run is some 5000-6200 bytes in the heap with the application partition set to 44K. That must accomodate both data and resources.

Generally all segments and resources are purgable, making it possible for the resource and memory managers to reuse space when needed. The only segment locked is 'Main', this is where event loop is executed.
On startup 'Init', and '%A5Init' segments are unloaded as they are used only during initilisation. 

'Preferences' segment is used only on startup, or when user saves their settings in the dialog. Else is unloaded.

Available memory is inquired in two places. When a new window is created, or 'Preferences' dialog displayed.

If the dialog is not showing and user requests another window, while memory is running low, the dialog is disposed of and the whole 'Dialog' segment unloaded.

When there is still less than 5000 bytes total free, user is alerted of low memory condition.

The strategy is not perfect, but shows the idea how segmented code works on Mac.

