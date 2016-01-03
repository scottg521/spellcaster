# spellcaster
Processing code to implement John Fairfield's Spellcaster

Processing is a visually-oriented Java-based language developed by 
Casey Reas and Ben Fry. It is open source and available from processing.org.

Spellcaster was originally developed on Apple 2e by John Fairfield in 1984, 
and ported to Commodore 64 by Scott Gilkeson. It was published with a tutorial 
and a book to get you started casting spells.

Spellcaster starts with a dot in the middle of the screen. Each letter key is a 
command that acts on that dot--to move it one step, change the direction,
change the color, or change the location (teleport). You can test whether the
color you are stepping onto matches the current pen color, and branch based
on the result. You can name a series of commands (create a spell) which you
can then cast and include in other spells.

Spellcaster commands:
'A' (AKA): cycle to next color
'B' (BO): move one step in the current direction, leaving current pen color
'D' (DI): reverse direction
'E': expose (set) teleporter (next character is teleporter name)
'F': felt (return to) teleporter (next character is the name)
'G' (GO): move one step in current direction
'H' (HI): turn to point upwards
'I' (IX): if - exit if matched (pen color and color stepped on)
'J' (JO): move one step in the current direction
'K': set pen color (next character is A,E,I,O,U - see note about numbers)
'L' (LI): turn left
'M': repeat (must be the beginning of word, next character is A,E,I,O,U number)
'N' (NU): repeat indefinitely (must be the beginning of word)
'O' (OX): if not - exit if unmatched (pen color and color stepped on)
'P' (PU): left paren (start new spell/word)
'Q' (QUSH): toggle sound (no sound in this version currently)
'R' (RI): turn right
'S' (SPELLS TU): name a spell
'T' (TU): begin spell name
'V' (VUZIM): like W, but doesn't wait - looks for one key spell
'W' (WU): request input until ZIM
'X' (XEN): else (MUST BE AT VERY BEGINNING OF WORD)
'Y' (Y): toggle mirror
'Z' (ZIM): right paren (ends PU or WU phrase, or TU spellname)
' ': ends word, UNLESS INSIDE A PU OR WU
'!': clears screen and resets everything

mouse click saves named spells currently in memory to disk file spells.txt

TODO: I don't think VU and WU work correctly, and there may be some problems 
with PU and spaces (it has been a while since I wrote this and I don't remember
all the issues).

Spellcaster had the ability to use arrow keys to back up and go forward, and
could pre-load spells into the key buffer, which was very useful for tutorials.