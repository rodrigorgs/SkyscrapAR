
class ClassItem extends SimpleMapItem {
  float boxLeft, boxTop;
  float boxRight, boxBottom;
  
  color currentColor;
  int index;
  
  PackageItem parent;
  int level;
  XMLElement xmlElement;
  
  color DEFAULT_COLOR = 0xccCCCCCC; // first two digits is alpha
  color HIGHLIGHT_COLOR = 0xffFFFF99;

  ClassItem(PackageItem parent, XMLElement elem, int level) {
    this.parent = parent;
    this.xmlElement = elem;
    this.level = level;
    this.index = globalIndex++;
    setSize(elem.getInt("maxloc"));
    
    this.currentColor = DEFAULT_COLOR;
  }

  boolean isSelected() {
    return this.currentColor == HIGHLIGHT_COLOR;
  }

  void toggleSelect() {
    if (this.currentColor == DEFAULT_COLOR)
      this.currentColor = HIGHLIGHT_COLOR;
    else
      this.currentColor = DEFAULT_COLOR;
  }

  void draw() {
    Rect bounds = this.getBounds();
    float x = (float)(bounds.x + bounds.w / 2);
    float y = (float)(bounds.y + bounds.h / 2);
    float z = log((float)this.getSize()) * 5.0f;
    
    float factor = 0.6;
    
    fill(0x99ffffff);
    pushMatrix();
    translate(x, y, 0);
    box((float)bounds.w*0.9, (float)bounds.h*0.9, 0.01);
    popMatrix();
    
    if (!HIDE_NON_SELECTED || this.isSelected()) {
      pushMatrix();
      translate(x, y, z);
      picker.start(this.index);
      fill(this.currentColor);
      box((float)bounds.w*factor, (float)bounds.h*factor, 2*z);
      popMatrix();
    }
  }
}
