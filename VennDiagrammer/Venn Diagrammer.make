App = 'Venn Diagrammer'
Objs = Global.p.o Utilities.p.o Preferences.p.o Dialog.p.o VennProcs.p.o

Libs =  "{Libraries}"Interface.o  �
        "{Libraries}"Runtime.o  �
        "{PLibraries}"Paslib.o

{App} �� {App}.p.o {Objs}
    Link {App}.p.o {Objs} {Libs} �
    -o {Targ}

{App} �� {App}.r Global.h DITL.rsrc PAT.rsrc ICON.rsrc
    Rez {App}.r -a -o {Targ}

{App}.p.o � {App}.p Global.p
    Pascal {App}.p
