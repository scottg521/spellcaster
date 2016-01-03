/* 
 * 
 */

class Phrase
{
  int startLocation;
  int repeatCount;
  boolean inPhrase;

  Phrase(int start, int count, boolean inPhrase)
  {
    startLocation = start;
    repeatCount = count;
    this.inPhrase = inPhrase;
    myDebug("New Phrase - starting with " + debugBufferAtLocation(start) + " repeating " + count);
  }

  void decrementCount()
  {
    repeatCount--;
  }
}

class PhraseStack
{
  int stackTop = -1;
  Phrase[] myStack;

  PhraseStack()
  {
    myStack = new Phrase[stackSize];
  }

  void clear()
  {
    stackTop = -1;
  }

  void setRepeat(int pointer, int count, boolean inPhrase)
  {
    myDebug("Repeating from " + pointer + " " + count + " times.");
    stackTop++;
    if (stackTop < stackSize) {
      myStack[stackTop] = new Phrase(pointer, count, inPhrase);
    }
    else {
      // deal with error
      println("PhraseStack overflow");
    }
  }
  
  void skipOut(boolean inPhrase)
  {
    if (!inPhrase) {
      if (stackTop > 0) {
        stackTop--;
      }
    }
    // else phrase end will handle things
  }

  int repeatPointer()
  {
    return myStack[stackTop].startLocation;
  }

  boolean repeatAgain(boolean inPhrase)
  {
    boolean repeat = false;

    if (stackTop < 0) {
      // nothing to repeat
      return false;
    }
    else {
      // if we are in a phrase, the repeater must also be in that phrase
      if ((inPhrase && myStack[stackTop].inPhrase) || !inPhrase) {
        int numLeft = myStack[stackTop].repeatCount;
        if (numLeft == 0) {
          // done with this repeater
          stackTop--;
        }
        else {
          if (numLeft > 0) {
            myStack[stackTop].decrementCount();
          }
          repeat = true;
          debugProcessing('*');
        }
      }
    }
    return repeat;
  }
}