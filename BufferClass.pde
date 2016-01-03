/* 
 * 
 */

class Buffer
{
  char[] q;
  int first, last;
  Spell myTeleporter;
  boolean isASpell;

  Buffer(int qSize)
  {
    q = new char[qSize];
    first = last = 0;
    myTeleporter = new Spell(true);
    isASpell = false;
  }
  
  Buffer(String contents)
  {
    q = new char[contents.length()];
    for (last = 0; last < q.length; last++) {
      q[last] = contents.charAt(last);
    }
    first = 0;
    myTeleporter = new Spell(true);
    isASpell = true;
  }
  
  // special debug routine
  char tokenAt(int location)
  {
    if (location >= 0 && location < q.length) {
      return q[location];
    }
    else {
      return '*';
    }
  }

  void push(char item)
  {
    // need to deal with keypresses while a spell is running and in VU or WU mode
    if (last == q.length) { /* queue full */
      // handle full queue (beep?)
    }
    else {
      q[last] = item;
      last++;
    }
  }

  boolean empty()
  {
    return (last == first);
  }

  char pop()
  {
    if (this.empty()) {
      // handle empty queue (beep?)
      return 0;
    }
    char item = q[first];
    first++;
    return item;
  }

  void backUpOne()
  {
    if (first > 0) {
      first--;
    }
  }

  int marker(int offset)
  {
    // first is actually item waiting to be read
    // offset will be negative, reflecting how many characters back to go
    // if you want to keep the current character, that's -1
    return first + offset;
  }

  void setPointer(int location)
  {
    first = location;
  }

  String getQ(int endPoint)
  {
    return (new String(q, 0, endPoint));
  }
  
  void clear()
  {
    first = last = 0;
  }
}