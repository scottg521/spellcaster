
boolean debug = true;

void myDebug(String msg)
{
  if (debug) {
    println();
    println("DEBUG: " + msg);
  }
}

 void debugProcessing(char theChar)
{
  print("" + theChar);
}

String debugBufferAtLocation(int loc)
{
  return parser.bufferContents(loc, 1);
}