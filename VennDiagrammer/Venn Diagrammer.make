App = 'Venn Diagrammer'
Objs = Global.p.o Utilities.p.o Preferences.p.o Dialog.p.o VennProcs.p.o

Libs =  "{Libraries}"Interface.o  ¶
        "{Libraries}"Runtime.o  ¶
        "{PLibraries}"Paslib.o

{App} ÄÄ {App}.p.o {Objs}
    Link {App}.p.o {Objs} {Libs} ¶
    -o {Targ}

{App} ÄÄ {App}.r Global.h DITL.rsrc PAT.rsrc ICON.rsrc
    Rez {App}.r -a -o {Targ}

{App}.p.o Ä {App}.p Global.p
    Pascal {App}.p
