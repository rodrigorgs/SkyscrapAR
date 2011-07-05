class Announcer extends Thread {
  String toSay;
  
  Announcer(String whatToSay) {
    toSay = whatToSay;
  }
  
  void start() {
    super.start();
  }
  
  void run() {
    tts.speak(toSay);
  }
}

