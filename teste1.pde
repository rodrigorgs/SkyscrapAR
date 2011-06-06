

/* Configuration options */
int THRESHOLD = 80;
int TREEMAP_WIDTH = 150;
int TREEMAP_HEIGHT = 150;
boolean FLIPPED_CAM = true;

///////////////////////////////////////////////////////
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
WordMap mapModel;

// picking
Picker picker;

void loadSTL() {
  stl = new STL(this, "Boxes.stl");
  poly=stl.getPolyData();

  poly.normalize(200); // normalize object to 400 radius
  poly.center(); // center it around world origin
}

void loadTreemap() {
  mapModel = new WordMap();
    
  String[] lines = loadStrings("equator.txt");
  for (int i = 0; i < lines.length; i++) {
    mapModel.addWord(lines[i]);
  }
  mapModel.finishAdd();

    // different choices for the layout method
    //MapLayout algorithm = new SliceLayout();
    //MapLayout algorithm = new StripTreemap();
    //MapLayout algorithm = new PivotBySplitSize();
    //MapLayout algorithm = new SquarifiedLayout();

  map = new Treemap(mapModel, 0, 0, width, height);
  map.updateLayout(-TREEMAP_WIDTH/2, -TREEMAP_HEIGHT/2, TREEMAP_WIDTH, TREEMAP_HEIGHT);
}

void setup() {
  size(640,480,P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION);
  cam=new Capture(this,640,480);
  nya=new MultiMarker(this,width,height,"camera_para.dat",nyarConf);
  nya.addARMarker("patt.hiro",80);
  nya.setThreshold(THRESHOLD);
  myframe = new PImage(width, height, RGB);

  loadSTL();
  loadTreemap();
  picker = new Picker(this);
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

void drawModelTreemap3D() {
//  stroke(0x33000000);
  noStroke();
  lights();
  
  int i = 0;
  for (Mappable item : mapModel.getItems()) {
    WordItem wordItem = (WordItem)item;
    Rect bounds = item.getBounds();
    float x = (float)(bounds.x + bounds.w / 2);
    float y = (float)(bounds.y + bounds.h / 2);
    float z = log((float)item.getSize()) * 5.0f;
    
    pushMatrix();
    translate(x, y, z);
    picker.start(i); i++;
    fill(wordItem.currentColor);
    box((float)bounds.w, (float)bounds.h, 2*z);
    popMatrix();
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
  translate(0,0,20);
  box(40);
}

void drawModel() {
//  drawModelCube();
//  drawModelSTL();
//  drawModelTreemap();
  drawModelTreemap3D();
}

void draw()
{
  if (cam.available() !=true) {
      return;
  }
  cam.read();
  nya.detect(cam);
  background(0);
  nya.drawBackground(cam);
  if((nya.isExistMarker(0))){
    nya.beginTransform(0);
    drawModel();
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
    item.toggleSelect();
//    cubes[id].changeColor();
  }
  
}
