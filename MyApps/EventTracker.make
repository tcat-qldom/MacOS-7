Libs =	"{Libraries}"Interface.o  ¶
		"{Libraries}"Runtime.o  ¶
		"{PLibraries}"Paslib.o

EventTracker ÄÄ EventTracker.p.o
	Link EventTracker.p.o {Libs} ¶
	-o EventTracker

EventTracker ÄÄ EventTracker.r
	Rez EventTracker.r -a -o EventTracker

EventTracker.p.o Ä EventTracker.p
	Pascal EventTracker.p
