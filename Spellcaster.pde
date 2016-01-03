 final int dotSize = 6;
final int textAreaHeight = 62;
final int numColors = 16;
final int keyBufferSize = 10000;
final int storeSize = 100; // total number of spells we can store
final int stackSize = 500; // limit for nested spells/loops/etc
final int dirUP = 0;
final int dirRIGHT = 1;
final int dirDOWN = 2;
final int dirLEFT = 3;
final int dirREVERSE = 4;
//PFont f;
boolean looping = true;
boolean collectInput = true;
int worldWidth, worldHeight;
int[][] world;
int[] border;
int colorLastOn = 0;
Spell spell;
color[] colors;
Buffer keyBuffer;
Parser parser;
SpellBook spellBook;
Teleporter teleporter;

void setup() 
{ 
  size(612, 675, P2D);
  frameRate(30);
  worldWidth = (width-(2*dotSize)-2)/dotSize;
  worldHeight = (height-(2*dotSize)-textAreaHeight-2)/dotSize;
  //textMode(SCREEN);
  //f = createFont("Georgia", 14, true);
  //textFont(f);
  //textAlign(LEFT);
  //initialize objects
  keyBuffer = new Buffer(keyBufferSize);
  parser = new Parser();
  colors = new color[numColors];
  colors[0] = color(0, 0, 0); /*  Black */
  colors[1] = color(255, 205, 243); /* Pink: */
  colors[2] = color(173, 35, 35); /* Red: */
  colors[3] = color(255, 238, 51); /* Yellow: */
  colors[4] = color(29, 105, 20); /* Green: */
  colors[5] = color(41, 208, 208); /* Cyan: */
  colors[6] = color(157, 175, 255); /* Lt. Blue: */
  colors[7] = color(129, 74, 25); /* Brown: */
  colors[8] = color(129, 197, 122); /* Lt. Green: */
  colors[9] = color(129, 38, 192); /* Purple: */
  colors[10] = color(160, 160, 160); /* Lt. Gray: */
  colors[11] = color(255, 146, 51); /* Orange: */
  colors[12] = color(42, 75, 215); /* Blue: */
  colors[13] = color(233, 222, 187); /* Tan: */
  colors[14] = color(87, 87, 87); /* Dk. Gray:  */
  colors[15] = color(255, 255, 255); /*White: */
  spell = new Spell(false);
  spellBook = new SpellBook();
  spellBook.loadSpells();
  initialize();
}

void initialize()
{
  world = new int[worldWidth][worldHeight];
  border = new int[(worldWidth*2)+(worldHeight*2)+4];
  teleporter = new Teleporter();
  spell.reset();
  background(0);
  spell.drawDot();
  drawMatchBox(numColors-1, colorLastOn);
}

void draw()
{
  if (!keyBuffer.empty()) {
    parser.parse(keyBuffer);
  }
}

void mouseClicked()
{
  spellBook.saveSpells();
}

void keyPressed()
{
  if (key == '~') {
    System.gc();
  }
  if (collectInput) {
    if (key == CODED) {
      // deal with arrow keys and other non-ASCII keys)
    }
    else {
      // make sure key is uppercase
      keyBuffer.push(keyToUpper(key));
    }
  }
}

char keyToUpper(char thisKey)
{  
  if (thisKey >= 'a' && thisKey <= 'z') {
    thisKey -= ('a' - 'A');
  }
  return thisKey;
}

void drawMatchBox(int upper, int lower)
{
  int y = height - textAreaHeight - 2;
  int h = (textAreaHeight - 2)/2;
  int x = (width - h) + 2;
  fill(colors[upper]);
  stroke(colors[upper]);
  rect(x+1, y+1, h, h);
  fill(colors[lower]);
  stroke(colors[lower]);
  rect(x+1, y+1+h, h, h);
  noFill();
  if (upper == lower) {
    stroke(255);
  }
  else {
    stroke(0);
  }
  rect(x, y, h+1, (2*h)+1);
}

/*
 * Teleporter - stores and restores teleporter locations
 *   expose: store a spell for the designated letter
 *   felt: reset the spell stored in the designated letter
 * Note: the special recursive teleporter (') is implemented in BufferClass
 */
class Teleporter
{
  Spell[] teleporters;

  Teleporter()
  {
    teleporters = new Spell[26];
    for (int i = 0; i < 26; i++) {
      teleporters[i] = new Spell(true);
    }
  }

  void expose(char which)
  {
    if (which >= 'A' && which <= 'Z') {
      teleporters[which - 'A'] = spell.clone();
    }
    else {
      // error (special recursive teleporter (') is in BufferClass)
    }
  }

  void felt(char which)
  {
    if (which >= 'A' && which <= 'Z') {
      spell.reset(teleporters[which - 'A']);
    }
    else {
      // error (special recursive teleporter (') is in BufferClass)
    }
  }
}

/*
 * SpellBook - keeps track or spells that are defined
 *   write: add the spell (name, tokens) to the spell store, overwriting if name exists
 *   lookupSpell: return the string of tokens stored under the given name (or "" if none)
 ^   saveSpells: write the spell store to the disk as spells.txt
 *   loadSpells: read spells.txt from the disk and add to the store
 * Note: the spell file on disk is a simple text file, with each line <name>,<spell token string>
 * TODO: be able to read and write files with other names
 */
class SpellBook
{
  String[] store;
  String[] spellNames;
  int numSpells = 0;

  SpellBook()
  {
    store = new String[storeSize];
    spellNames = new String[storeSize];
    // read stored spells from disk file
  }

  void write(String name, String newSpell)
  {
    // if name already exists, overwrite
    int idx = findSpell(name);
    if (idx >= 0) {
      store[idx] = newSpell;
    }
    else {
      if (numSpells < storeSize) {
        spellNames[numSpells] = name;
        store[numSpells] = newSpell;
        numSpells++;
      }
      else {
        // handle error
        println("Too many spells.");
      }
    }
  }

  /*
   * returns index of spell or -1 if not found
   */
  private int findSpell(String name)
  {
    int i = 0;
    while (i < numSpells && !spellNames[i].equals (name)) {
      i++;
    }
    if (i == numSpells) {
      i = -1;
    }
    return i;
  }

  String lookUpSpell(String name)
  {
    int i = findSpell(name);
    return (i < 0 ? "" : store[i]);
  }

  void loadSpells()
  {
    String lines[] = loadStrings("spells.txt");
    if (lines != null) {
      for (int i=0; i < lines.length; i++) {
        String[] parts = split(lines[i], ',');
        this.write(parts[0], parts[1]);
      }
    }
  }

  void saveSpells()
  {
    if (numSpells > 0) {
      String lines[] = new String[numSpells];
      for (int i = 0; i < numSpells; i++) {
        lines[i] = spellNames[i] + "," + store[i];
      }
      saveStrings("spells.txt", lines);
      println("Saved " + numSpells + " spells!");
    }
  }
}

/* 
 * Spell - stores location, color, etc. and handles all movement
 *   clone: return a new copy of a spell
 *   reset:
 *   decrementPenColor: set the pen color to one less than current (wrapping)
 *   setPenColor: set the pen color to given color
 *   drawDot:
 *   makeMove: 
 *   turn: 
 *   toggleSound: 
 *   toggleMirror: 
 *   colorNowOn:
 *   colorMatched: 
 * Note: colorLastOn is a global becuase it should carry across instances of Spell
 */
class Spell
{
  int x = worldWidth/2;
  int y = worldHeight/2;
  int direction = dirUP;
  int penColor = numColors - 1;
  boolean soundOn = true;
  boolean mirrorOn = false;
  boolean inBorder = false;

  Spell(boolean inBorder)
  {
    if (inBorder) {
      this.inBorder = true;
      this.x = 0;
      this.y = -1; // border is one-dimensional
    }
  }

  Spell(Spell oldSpell)
  {
    this.x = oldSpell.x;
    this.y = oldSpell.y;
    this.direction = oldSpell.direction;
    this.penColor = oldSpell.penColor;
    this.soundOn = oldSpell.soundOn;
    this.mirrorOn = oldSpell.mirrorOn;
  }

  Spell clone()
  {
    return new Spell(this);
  }

  void reset()
  {
    this.x = worldWidth/2;
    this.y = worldHeight/2;
    this.direction = dirUP;
    this.penColor = numColors - 1;
    this.soundOn = true;
    this.mirrorOn = false;
    this.inBorder = false;
    colorLastOn = 0;
  }

  void reset(Spell newSpell)
  {
    this.x = newSpell.x;
    this.y = newSpell.y;
    this.direction = newSpell.direction;
    this.penColor = newSpell.penColor;
    this.soundOn = newSpell.soundOn;
    this.mirrorOn = newSpell.mirrorOn;
    this.inBorder = newSpell.inBorder;
  }

  void decrementPenColor()
  {
    this.penColor--;
    if (this.penColor < 0) {
      this.penColor = numColors-1;
    }
  }

  void setPenColor(int whatColor)
  {
    this.penColor = whatColor % numColors;
    drawMatchBox(this.penColor, colorLastOn);
  }

  void drawDot()
  {
    drawDot(this.penColor);
  }

  void drawDot(int colorToDraw)
  {
    fill(colors[colorToDraw]);
    stroke(colors[colorToDraw]);
    if (this.inBorder) {
      int borderX, borderY;
      if (this.x <= worldHeight + 2) {
        // in left vertical
        borderX = 0;
        borderY = worldHeight + 2 - this.x;
      }
      else if (this.x <= worldHeight + 2 + worldWidth) {
        // in top horizontal
        borderX = this.x - (worldHeight + 2);
        borderY = 0;
      }
      else if (this.x <= (2 * (worldHeight + 2)) + worldWidth) {
        // in right vertical
        borderX = worldWidth + 1;
        borderY = this.x - (worldHeight + 3 + worldWidth);
      }
      else {
        // in bottom horizontal
        borderX = border.length - this.x;
        borderY = worldHeight + 1;
      }
      rect(dotSize * borderX, dotSize * borderY, dotSize, dotSize);
      border[this.x] = colorToDraw;
    }
    else {
      rect((this.x+1)*dotSize, (this.y+1)*dotSize, dotSize, dotSize);
      world[this.x][this.y] = colorToDraw;
    }
  }

  void makeMove(int moveCode)
  {
    if (inBorder) {
      moveInBorder(moveCode);
    }
    else {
      moveInWorld(moveCode);
    }
    drawMatchBox(this.penColor, colorLastOn);
  }

  private void moveInBorder(int moveCode)
  {
    if (this.direction == dirUP) {
      // move clockwise)
      this.x++;
      if (this.x == border.length) this.x = 0;
    }
    else {
      // move counterclockwise
      if (this.x == 0) this.x = border.length;
      this.x--;
    }
    if (moveCode == 'B') {
      drawDot();
    }
    if (moveCode == 'G') {
      drawDot(this.penColor ^ border[this.x]);
    }
  }

  private void moveInWorld(int moveCode)
  {
    colorLastOn = world[this.x][this.y];
    // 'wash' (xor) current dot
    if (moveCode == 'G') {
      drawDot(this.penColor ^ world[this.x][this.y]);
    }
    switch (this.direction) {
    case dirDOWN:
      this.y++;
      if (this.y == worldHeight) this.y = 0;
      break;
    case dirUP:
      if (this.y == 0) this.y = worldHeight;
      this.y--;
      break;
    case dirLEFT:
      if (this.x == 0) this.x = worldWidth;
      this.x--;
      break;
    case dirRIGHT:
      this.x++;
      if (this.x == worldWidth) this.x = 0;
      break;
    }
    if (moveCode == 'B') {
      drawDot();
    }
    if (moveCode == 'G') {
      drawDot(this.penColor ^ world[this.x][this.y]);
    }
  }

  void turn(int turnOptions)
  {
    if (this.mirrorOn) {
      // switch left and right
      if (turnOptions == dirLEFT) {
        turnOptions = dirRIGHT;
      } 
      else if (turnOptions == dirRIGHT) {
        turnOptions = dirLEFT;
      }
    }
    if (!this.inBorder) {
      if (turnOptions == dirLEFT) {
        if (this.direction == dirUP) {
          this.direction = dirLEFT;
        } 
        else {
          this.direction--;
        }
      }
      if (turnOptions == dirRIGHT) {
        this.direction = (this.direction + 1) % 4;
      }
    } 
    if (turnOptions == dirREVERSE) {
      this.direction = (this.direction + 2) % 4;
    }
    if (turnOptions == dirUP) {
      this.direction = dirUP;
    }
  }

  void toggleSound()
  {
    this.soundOn = !this.soundOn;
  }

  void toggleMirror()
  {
    this.mirrorOn = !this.mirrorOn;
  }

  int colorNowOn()
  {
    return (inBorder? border[this.x] : world[this.x][this.y]);
  }

  boolean colorMatched()
  {
    return (colorLastOn == this.colorNowOn());
  }
}