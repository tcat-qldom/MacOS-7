Libs =  "{Libraries}"Interface.o  �
        "{Libraries}"Runtime.o  �
        "{PLibraries}"Paslib.o

EventTracker �� EventTracker.p.o
    Link EventTracker.p.o {Libs} �
    -o EventTracker

EventTracker �� EventTracker.r
    Rez EventTracker.r -a -o EventTracker

EventTracker.p.o � EventTracker.p
    Pascal EventTracker.p
