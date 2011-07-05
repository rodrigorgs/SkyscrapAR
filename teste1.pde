/*
TODO list
=========
- BUG: Sometimes we select the board and it selects a class (Label)
- BUG: When marker disappears, the model zooms out

DONE
====
- Use churn as height
  - height = sum(churns) from v[i+1] to v[j] minus churn(v[i])
- Highlight classes that were changed in the last version
  - Also: classes changed between first and last version
- Use tweening to animate version change
- Take greater height as a reference height
- Write name of hover class on some kind of title bar
- Speak class name (split words with hyphen)
- Maybe try mrbola speech (Didn't work, only noise is produced).
*/

////////////////////////////////////////////////////////
/////////// Configuration Variables ////////////////////
////////////////////////////////////////////////////////

int THRESHOLD = 45; //85; //110;
double CONFIDENCE_THRESHOLD = 0.51; // default: 0.51
boolean DEBUG = false;

boolean DRAW_MODELS = true;
boolean FLIPPED_CAM = false;

int TREEMAP_WIDTH = 150;
int TREEMAP_HEIGHT = 150;
boolean HIDE_NON_SELECTED = false;

double PACKAGE_HEIGHT = 2.0;

double PACKAGE_BASE_RATIO = 0.95;
double CLASS_BASE_RATIO = 0.90;

double CLASS_MIN_HEIGHT = 10.0;
double CLASS_MAX_HEIGHT = (TREEMAP_WIDTH + TREEMAP_HEIGHT) * 0.6;

boolean HIGHLIGHT_CHANGES_IS_CUMULATIVE = false;

double TWEENING_TIME_INTERVAL = 1000; // milliseconds

////////////////////////////////////////////////////////
///////////////////// Imports //////////////////////////
////////////////////////////////////////////////////////

import guru.ttslib.*;
import processing.video.*;
import jp.nyatla.nyar4psg.*;
import treemap.*;
import picking.*;
//import processing.opengl.*;

////////////////////////////////////////////////////////
/////////// Global Variables ///////////////////////////
////////////////////////////////////////////////////////

PFont font;

PMatrix3D lastMatrix = new PMatrix3D();

// NyAR4Psg
Capture cam;
MultiMarker nya;
//PFont font=createFont("FFScala", 32);
NyAR4PsgConfig nyarConf = NyAR4PsgConfig.CONFIG_PSG;
//NyAR4PsgConfig nyarConf = new NyAR4PsgConfig(NyAR4PsgConfig.CS_RIGHT_HAND, NyAR4PsgConfig.TM_NYARTK);
PImage myframe;

// Treemap
Treemap map;
PackageItem mapModel;
int globalIndex = 0;
LinkedList<ClassItem> g_treemapItems = new LinkedList<ClassItem>();
int g_currentVersion = 1;
int g_firstVersion = 1;
double g_tweeningVersion = g_currentVersion;
double g_maxChurn = 0;
int maxVersion = -1;

// misc
TTS tts;
Announcer announcer = null;
String titleString = "";
Picker picker;


////////////////////////////////////////////////////////
////////////////// Functions ///////////////////////////
////////////////////////////////////////////////////////

void loadTreemap() {
  // different choices for the layout method
  //MapLayout algorithm = new SliceLayout(); // linhas finas
  //MapLayout algorithm = new StripTreemap(); // linhas finas subdivididas
  MapLayout algorithm = new PivotBySplitSize(); // default
  //MapLayout algorithm = new SquarifiedLayout();

  XMLElement elem = new XMLElement(this, "test.xml");
  mapModel = new PackageItem(null, elem, 0);
  maxVersion = elem.getInt("to");

  map = new Treemap(mapModel, 0, 0, width, height);
  map.setLayout(algorithm);
  map.updateLayout(-TREEMAP_WIDTH/2, -TREEMAP_HEIGHT/2, TREEMAP_WIDTH, TREEMAP_HEIGHT);
}

void setup() {
  size(640,480,P3D);
  println(MultiMarker.VERSION);
  cam=new Capture(this,640,480);
  nya=new MultiMarker(this,width,height,"camera_para.dat",nyarConf);
  nya.addARMarker("patt.sample1",80);
  nya.addARMarker("patt.kanji",80);
  nya.setThreshold(THRESHOLD);
  nya.setConfidenceThreshold(CONFIDENCE_THRESHOLD);
  myframe = new PImage(width, height, RGB);

  println("default confidence: " + MultiMarker.DEFAULT_CF_THRESHOLD);

  loadTreemap();
  picker = new Picker(this);
  
  tts = new TTS();
  
  font = loadFont("Menlo-Bold-32.vlw");
  textFont(font);
}

// Rodrigo, 2011-06-06
// should be the last method call on draw()
// based on http://forum.processing.org/topic/nyartoolkit-when-i-flip-videocapture-mirror-effect-the-overlayed-objects-don%C2%B4t-flip
void flipScreen() {
  loadPixels();
  for (int x=0; x<width; x++) {
      for (int y=0; y<height; y++) {
        int loc = (width- x- 1) + y*width;
        myframe.pixels[x+y*width] = color(red(pixels[loc]), green(pixels[loc]), blue(pixels[loc]));
      }
    }
  myframe.updatePixels();
      hint (DISABLE_DEPTH_TEST);
      image(myframe, 0, 0);
    hint (ENABLE_DEPTH_TEST);
}

//*******************************************************/
// Drawing
//*******************************************************/

void drawXmlTreemap3D() {
  picker.start(32767);
  lights();
  noStroke();
  
  pushMatrix();
  translate(0, 0, -12.0f);
  fill(128);
  box((float)TREEMAP_WIDTH, (float)TREEMAP_HEIGHT, 12.0f);
  popMatrix();
  
  stroke(0x33000000);
  map.draw();
  noLights();
}

void drawModelCube() {
  fill(0,0,255);
  translate(0,0,2.5);
  box(600, 600, 5);
}

void drawModel() {
//  drawModelCube();
  drawXmlTreemap3D();
}

//////////////// tweening //////////////////////////

int startTime = 0;
double startTweeningVersion = g_tweeningVersion;

void tweenVersion() {
  int time = millis();
  double progress = (time - startTime) / TWEENING_TIME_INTERVAL;
  if (progress > 1.0)
    progress = 1.0;
    
  g_tweeningVersion = progress*(g_currentVersion) + (1 - progress)*(startTweeningVersion);
}

void setCurrentVersion(int v) {
  g_currentVersion = v;
  startTime = millis();
  startTweeningVersion = g_tweeningVersion;
}

////////////////////////////////////////////////////


void draw()
{
  tweenVersion();
  
  if (cam.available() !=true) {
      return;
  }  
  cam.read();
  nya.detect(cam);
  background(0);
  
  if (DEBUG) {
    loadPixels();
    for (int i = 0; i < width*height; i++) {
      color c = cam.pixels[i];
      if (brightness(c) > THRESHOLD)
        pixels[i] = #FFFFFF;
      else
        pixels[i] = #000000;
    }
    updatePixels();
  }
  else {
    nya.drawBackground(cam);
  }
  
  if((nya.isExistMarker(0))){
    lastMatrix = nya.getMarkerMatrix(0);
    nya.beginTransform(0);
    if (DRAW_MODELS)
      drawModel();
    nya.endTransform();
  }
  else {
    pushMatrix();
    resetMatrix();
    applyMatrix(lastMatrix.m00, lastMatrix.m01, lastMatrix.m02, lastMatrix.m03,
    lastMatrix.m10, lastMatrix.m11, lastMatrix.m12, lastMatrix.m13,
    lastMatrix.m20, lastMatrix.m21, lastMatrix.m22, lastMatrix.m23,
    lastMatrix.m30, lastMatrix.m31, lastMatrix.m32, lastMatrix.m33
    );
    if (DRAW_MODELS)
      drawModel();

    popMatrix();
  }
  
  if((nya.isExistMarker(1))){
    nya.beginTransform(1);
    if (DRAW_MODELS)
      drawModelCube();
    nya.endTransform();
  }

  
  if (FLIPPED_CAM)
    flipScreen();
    
  fill(0, 0, 0);
  text(titleString, 10, 32);
}

// interaction
void mouseMoved() {
  int x = mouseX;
  int y = mouseY;
  if (FLIPPED_CAM)
    x = width - x;
    
  int id = picker.get(x, y);
  if (id > -1 && id < g_treemapItems.size()) {
    ClassItem item = g_treemapItems.get(id);
    titleString = item.name;
  }
  else {
    titleString = "";
  }
}

void mouseClicked() {
  int x = mouseX;
  int y = mouseY;
  if (FLIPPED_CAM)
    x = width - x;
    
  int id = picker.get(x, y);
  if (id > -1 && id < g_treemapItems.size()) {
    ClassItem item = g_treemapItems.get(id);
//    if (!item.type.equals("package")) {
      item.toggleSelect();
      println("" + id + ": " + item.name + " level=" + item.level);
      if (item.isSelected())
        speak(item.name);
//    }
  }  
}

void speak(String name) {
  String hyphenatedName = "";
  int i = 0;
  for (char c : name.toCharArray()) {
    if (i > 0 && c > 'A' && c < 'Z')
      hyphenatedName += "-";
    hyphenatedName += c;
    i++;
  }
  
  println("Speak " + hyphenatedName);
  announcer = new Announcer(hyphenatedName);
  announcer.start();
}

void updateThreshold(int newThreshold) {
  if (newThreshold > 255)
    THRESHOLD = 255;
  else if (newThreshold < 0)
    THRESHOLD = 0;
  else   
    THRESHOLD = newThreshold;
  nya.setThreshold(THRESHOLD);
  
  println("New THRESHOLD = " + THRESHOLD);
}

void keyPressed() {
  if (key == 'd')
    DEBUG = !DEBUG;
  else if (key == 'm')
    DRAW_MODELS = !DRAW_MODELS;
  else if (key == 'h') {
    HIDE_NON_SELECTED = !HIDE_NON_SELECTED;
  }
  else if (key == '+' || key == '=') {
    updateThreshold(THRESHOLD + 5);
  }
  else if (key == '-') {
    updateThreshold(THRESHOLD - 5);
  }
  else if (key == '.' && g_currentVersion < maxVersion) {
    setCurrentVersion(g_currentVersion + 1);
  }
  else if (key == ',' && g_currentVersion > 1) {
    setCurrentVersion(g_currentVersion - 1);
  }
  else if (key == 'c') {
    HIGHLIGHT_CHANGES_IS_CUMULATIVE = !HIGHLIGHT_CHANGES_IS_CUMULATIVE;
  }
} 
