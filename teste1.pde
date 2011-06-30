/* Configuration options */
int THRESHOLD = 110;
double CONFIDENCE_THRESHOLD = 0.51; // default: 0.51
boolean DEBUG = false;

boolean DRAW_MODELS = true;
boolean FLIPPED_CAM = false;

// treemap
int TREEMAP_WIDTH = 150;
int TREEMAP_HEIGHT = 150;
boolean HIDE_NON_SELECTED = false;

///////////////////////////////////////////////////////
import guru.ttslib.*;

import processing.video.*;
import jp.nyatla.nyar4psg.*;
// opengl
//import processing.opengl.*;
// load STL models
import unlekker.data.*;
import unlekker.geom.*;
// treemap
import treemap.*;
// picking
import picking.*;

////////
PMatrix3D lastMatrix = new PMatrix3D();

///////////
Capture cam;
MultiMarker nya;
PFont font=createFont("FFScala", 32);
NyAR4PsgConfig nyarConf = NyAR4PsgConfig.CONFIG_PSG;
//NyAR4PsgConfig nyarConf = new NyAR4PsgConfig(NyAR4PsgConfig.CS_RIGHT_HAND, NyAR4PsgConfig.TM_NYARTK);
PImage myframe;

// STL model
STL stl;
FaceList poly;

// Treemap
Treemap map;
PackageItem mapModel;
int globalIndex = 0;

// tts
TTS tts;

// picking
Picker picker;

void loadSTL() {
  stl = new STL(this, "Boxes.stl");
  poly=stl.getPolyData();

  poly.normalize(200); // normalize object to 400 radius
  poly.center(); // center it around world origin
}

void loadTreemap() {
  XMLElement elem = new XMLElement(this, "test.xml");
  mapModel = new PackageItem(null, elem, 0);
    
//  String[] lines = loadStrings("equator.txt");
//  for (int i = 0; i < lines.length; i++) {
//    mapModel.addWord(lines[i]);
//  }
//  mapModel.finishAdd();

    // different choices for the layout method
    //MapLayout algorithm = new SliceLayout(); // linhas finas
    //MapLayout algorithm = new StripTreemap(); // linhas finas subdivididas
    MapLayout algorithm = new PivotBySplitSize(); // default
    //MapLayout algorithm = new SquarifiedLayout();

  map = new Treemap(mapModel, 0, 0, width, height);
  map.setLayout(algorithm);
  map.updateLayout(-TREEMAP_WIDTH/2, -TREEMAP_HEIGHT/2, TREEMAP_WIDTH, TREEMAP_HEIGHT);
}

void setup() {
  size(640,480,P3D);
//  colorMode(RGB, 100);
  println(MultiMarker.VERSION);
  cam=new Capture(this,640,480);
  nya=new MultiMarker(this,width,height,"camera_para.dat",nyarConf);
  nya.addARMarker("patt.sample1",80);
  nya.addARMarker("patt.kanji",80);
  nya.setThreshold(THRESHOLD);
  nya.setConfidenceThreshold(CONFIDENCE_THRESHOLD);
  myframe = new PImage(width, height, RGB);

  println("default confidence: " + MultiMarker.DEFAULT_CF_THRESHOLD);

  loadSTL();
  loadTreemap();
  picker = new Picker(this);
  
  tts = new TTS();
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
  lights();
  map.draw();
  noLights();
}

void drawModelTreemap3D() {
  lights();
  
  noStroke();
  fill(#000033);
  pushMatrix();
  translate(0, 0, -12.0f);
  box((float)TREEMAP_WIDTH, (float)TREEMAP_HEIGHT, 12.0f);
  popMatrix();
  
  stroke(0x33000000);  
  int i = 0;
  for (Mappable item : mapModel.getItems()) {
    WordItem wordItem = (WordItem)item;
    
    Rect bounds = item.getBounds();
    float x = (float)(bounds.x + bounds.w / 2);
    float y = (float)(bounds.y + bounds.h / 2);
    float z = log((float)item.getSize()) * 5.0f;
    
    float factor = 0.6;
    
    fill(0x99ffffff);
    pushMatrix();
    translate(x, y, 0);
    box((float)bounds.w*0.9, (float)bounds.h*0.9, 0.01);
    popMatrix();
    
    if (!HIDE_NON_SELECTED || wordItem.isSelected()) {
      pushMatrix();
      translate(x, y, z);
      picker.start(i); i++;
      fill(wordItem.currentColor);
      box((float)bounds.w*factor, (float)bounds.h*factor, 2*z);
      popMatrix();
    }
//    println(item.getSize());
  }
  
  noLights();
}

void drawModelTreemap() {
  if (FLIPPED_CAM)
    rotateX(radians(180));
    
  map.draw();
}

void drawModelSTL() {
  noStroke();
  lights();
  fill(0, 200, 255, 128);
  poly.draw(this);
  
  noLights();
}

void drawModelCube() {
  fill(0,0,255);
  translate(0,0,2.5);
  box(600, 600, 5);
}

void drawModel() {
//  drawModelCube();
//  drawModelSTL();
//  drawModelTreemap();
//  drawModelTreemap3D();
  drawXmlTreemap3D();
}

void draw()
{
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
}

// interaction
void mouseClicked() {
  int x = mouseX;
  int y = mouseY;
  if (FLIPPED_CAM)
    x = width - x;
    
  int id = picker.get(x, y);
  if (id > -1) {
    WordItem item = (WordItem)mapModel.getItems()[id];
    println(item.word);
    tts.speak("JUnitTest. " + item.word);
    item.toggleSelect();
//    cubes[id].changeColor();
  }
  
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
  
  
} 
