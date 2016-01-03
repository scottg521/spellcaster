/* 
 * Handle input from keyboard
 */

class Parser
{
  final static int ATOM = 0;
  final static int COLR = 1;
  final static int NUMB = 2;
  final static int SPEL = 3;
  final static int SPELCAST = 4;
  final static int TELEEXPO = 5;
  final static int TELEFELT = 6;
  int whichParser = ATOM;
  int accumulator = 0;
  int place = 0;
  boolean newParser = false;
  boolean expectingNumeral = false;
  boolean skipping = false;
  boolean repeating = false;
  boolean inPhrase = false;
  char[] spellName;
  int spellNameIndex = 0;
  int spellEndPoint;
  Buffer source;
  PhraseStack repeaters;

  Parser()
  {
    spellName = new char[50];
    repeaters = new PhraseStack();
  }

  // special debug routine
  String bufferContents(int loc, int len)
  {
    String out = "";
    for (int i = 0; i < len; i++) {
      out += source.tokenAt(loc + i);
    }
    return out;
  }

  void switchTo(int toParser)
  {
    whichParser = toParser;
    newParser = true;
  }

  void clear()
  {
    // reinitialize everything
    initialize();
    switchTo(ATOM);
    source.clear();
    repeaters.clear();
    skipping = false;
    repeating = false;
  }

  void endWord()
  {
    if (repeaters.repeatAgain(inPhrase)) {
      repeating = true;
      source.setPointer(repeaters.repeatPointer());
    }
    else {
      repeating = false;
    }
    skipping = false;
  }

  void parse(Buffer b)
  {
    char thisKey = b.pop();
    source = b;
    switch (whichParser) {
    case ATOM:
      parseAtom(thisKey);
      break;
    case COLR:
      parseColor(thisKey);
      break;
    case NUMB:
      parseNumber(thisKey);
      break;
    case SPEL:
    case SPELCAST:
      parseSpell(thisKey);
      break;
    case TELEEXPO:
    case TELEFELT:
      parseTeleporter(thisKey);
      break;
    }
  }


  void say(String what)
  {
    if (!source.isASpell && !this.repeating) {
      if (what.equals("!")) {
        println(" !");
      }
      else {
        print(what);
      }
    }
  }

  void redirectInputToKeyboard()
  {
  }

  void restoreInput()
  {
  }

  void parseTeleporter(char thisKey)
  {
    if (thisKey >= 'A' && thisKey <= 'Z') {
      if (whichParser == TELEEXPO) { // expose teleporter
        if (!skipping) teleporter.expose(thisKey);
        say("" + char(thisKey));
      }
      else {
        if (!skipping) teleporter.felt(thisKey);
        say("" + char(thisKey));
      }
      switchTo(ATOM);
    }
    else {
      // handle error - for now just keep going until a letter is encountered
    }
  }

  void accumulate(char thisKey)
  {
    int thisNumber = 0;

    switch (thisKey) {
    case 'O':
      break;
    case 'A':
      thisNumber = 1;
      break;
    case 'E':
      thisNumber = 2;
      break;
    case 'I':
      thisNumber = 3;
      break;
    case 'U':
      thisNumber = floor(random(4));
      break;
    case 'X':
      thisNumber = spell.colorNowOn();
      break;
    default:
      // not a recognizable number
      // MUST HANDLE ERROR
      return;
    }
    accumulator *= place;
    place *= 4;
    accumulator += thisNumber;
  }

  void parseColor(char thisKey)
  {
    // when this is first called, a K has been recognized
    // colors can be any sequence of Kn, where n is O,A,E,I,U or X
    if (newParser) {
      accumulator = 0;
      place = 1;
      expectingNumeral = true;
      newParser = false;
    }
    if (expectingNumeral) {
      accumulate(thisKey);
      say("K" + char(thisKey));
      expectingNumeral = false;
    } 
    else {
      // either a K or end of color spec
      if (thisKey == int('K')) {
        expectingNumeral = true;
      } 
      else {
        if (!skipping) spell.setPenColor(accumulator);
        switchTo(ATOM);
        source.backUpOne();
      }
    }
  }

  void parseNumber(char thisKey)
  {
    // when this is called, a M has been recognized
    // numbers can be any sequence of Mn, where n is O,A,E,I,U or X
    if (newParser) {
      accumulator = 0;
      place = 1;
      expectingNumeral = true;
      newParser = false;
    }
    if (expectingNumeral) {
      accumulate(thisKey);
      say("M" + char(thisKey));
      expectingNumeral = false;
    } 
    else {
      // either a M or end of number
      if (thisKey == 'M') {
        expectingNumeral = true;
      } 
      else {
        if (!skipping) repeaters.setRepeat(source.marker(-1), accumulator, inPhrase);
        switchTo(ATOM);
        source.backUpOne();
      }
    }
  }

  void cast(String thisSpell)
  {
    if (!skipping) {
      String spellText = spellBook.lookUpSpell(thisSpell);
      if (spellText.equals("")) {
        print(" There is no spell named " + thisSpell + " ");
      }
      else {
        debugProcessing('/');
        Buffer x = new Buffer(spellText);
        while (!x.empty ()) {
          parse(x);
        }
      }
    }
  }

  void parseSpell(char thisKey)
  {
    // when this is called, a S has been recognized
    // any alphabetic characters except Z can be used
    // Z ends the name; a spell can have 0 characters
    if (newParser) {
      spellNameIndex = 0;
      spellEndPoint = source.marker(-2);
      newParser = false;
    }
    if (thisKey == 'Z') {  // end of the name
      say("ZIM");
      String thisSpell = new String(spellName, 0, spellNameIndex); // could be ""
      if (whichParser == SPELCAST) {
        switchTo(ATOM);
        cast(thisSpell);
      }
      else {
        // store the spell
        spellBook.write(new String(spellName, 0, spellNameIndex), source.getQ(spellEndPoint));
        this.clear();
        say("!");
      }
    }
    else {
      if (spellNameIndex < spellName.length) {
        spellName[spellNameIndex] = char(thisKey);
        spellNameIndex++;
        say("" + char(thisKey));
      }
    }
  }

  void parseAtom(char thisKey)
  {
    // println("Main parser key " + char(thisKey));
    switch (thisKey) {
    case 'A':
      if (!skipping) spell.decrementPenColor();
      say("AKA");
      break;
    case 'B':
      if (!skipping) spell.makeMove(thisKey);
      say("BO");
      break;
    case 'C':
      // unused
      break;
    case 'D':
      if (!skipping) spell.turn(dirREVERSE);
      say("DI");
      break;
    case 'E':
      // expose teleporter
      switchTo(TELEEXPO);
      say("E");
      break;
    case 'F':
      // felt teleporter
      switchTo(TELEFELT);
      say("FE");
      break;
    case 'G':
      if (!skipping) spell.makeMove(thisKey);
      say("GO");
      break;
    case 'H':
      if (!skipping) spell.turn(dirUP);
      say("HI");
      break;
    case 'I':
      // exit if matched
      if (!skipping && spell.colorMatched()) {
        skipping = true;
        // need to exit a repeater?
        repeaters.skipOut(inPhrase);
      }
      say("IX");
      break;
    case 'J':
      if (!skipping) spell.makeMove(thisKey);
      say("JO");
      break;
    case 'K':
      // set pen color
      switchTo(COLR);
      break;
    case 'L':
      if (!skipping) spell.turn(dirLEFT);
      say("LI");
      break;
    case 'M':
      // repeat
      // MUST BE BEGINNING OF WORD
      switchTo(NUMB);
      break;
    case 'N':
      // repeat indefinitely
      // MUST BE BEGINNING OF WORD
      if (!skipping) repeaters.setRepeat(source.marker(0), -1, inPhrase);
      say("NU");
      break;
    case 'O':
      // exit if unmatched
      if (!skipping && !spell.colorMatched()) {
        skipping = true;
        repeaters.skipOut(inPhrase);
      }
      say("OX");
      break;
    case 'P':
      // left paren
      // START A NEW SPELL
      // don't think this entry on the repeater stack is helpful
      //if (!skipping) repeaters.setRepeat(source.marker(0), 0, inPhrase);
      inPhrase = true;
      say("PU");
      break;
    case 'Q':
      // toggle sound
      if (!skipping) spell.toggleSound();
      say("QUSH");
      break;
    case 'R':
      if (!skipping) spell.turn(dirRIGHT);
      say("RI");
      break;
    case 'S':
      // spell
      switchTo(SPEL);
      say(" SPELLS TU");
      break;
    case 'T':
      // begin spell name
      switchTo(SPELCAST);
      say("TU");
      break;
    case 'U':
      // unused
      break;
    case 'V':
      // like W, but doesn't wait - looks for one key spell
      if (source.isASpell || repeating) {
        if (keyPressed) {
          char letterSpell = keyToUpper(key);
          if (letterSpell == 'Z') {
            cast("");
          }
          else {
            cast("" + letterSpell);
          }
        }
      }
      say("VUZIM");
      break;
    case 'W':
      // request input until ZIM
      if (source.isASpell || repeating) {
        // set a bunch of flags and parse the keyboard buffer until zim
        // TREAT LIKE PU
        inPhrase = true;
        redirectInputToKeyboard();
        say("WU");
      }
      else {
        say("WUZIM");
      }
      break;
    case 'X':
      // else
      // MUST BE AT VERY BEGINNING OF WORD
      skipping = !skipping;
      say("XEN");
      break;
    case 'Y':
      // toggle mirror
      if (!skipping) spell.toggleMirror();
      say("Y");
      break;
    case 'Z':
      // right paren
      // ONLY HAS EFFECT IF IN PU OR WU (OR TU, BUT THAT IS HANDLED ELSEWHERE)
      if (inPhrase) {
        this.endWord();
        inPhrase = false;
        // also need to end the phrase, in case that had a repeater on it
        this.endWord();
        say("ZIM");
      }
      break;
    case ' ':
      // ends word
      // UNLESS INSIDE A PU OR WU
      this.endWord();
      say(" ");
      break;
    case '!':
      // clears screen and resets everything
      this.clear();
      say("!");
      break;
    }
  }
}