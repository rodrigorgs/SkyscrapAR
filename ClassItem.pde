
class ClassItem extends SimpleMapItem {
  float boxLeft, boxTop;
  float boxRight, boxBottom;
  
  color currentColor;
  int index = -1;
  String type;
  String name;
  
  PackageItem parent;
  int level;
  XMLElement xmlElement;
  
  color DEFAULT_COLOR = 0xccCCCCCC; // first two digits is alpha
  color HIGHLIGHT_COLOR = 0xffFFFF99;

  ClassItem(PackageItem parent, XMLElement elem, int level) {
    this.type = "class";
    this.parent = parent;
    this.xmlElement = elem;
    this.level = level;
    this.index = g_treemapItems.size();
    this.name = elem.getString("name");
    
    g_treemapItems.add(this);
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

  void boxWithBounds(double x, double y, double z, double w, double h, double zz, double baseRatio) {
    float a = (float)(x + w/2);
    float b = (float)(y + h/2);
    float c = (float)(z + zz/2);
    translate(a, b, c);
    box((float)(w*baseRatio), (float)(h*baseRatio), (float)zz);
    translate(-a, -b, -c);
  }

  void draw() {
    Rect bounds = this.getBounds();
    double zz = this.getSize() * 1.0;
    
    stroke(0);
    fill(0x99ffffff);
    // box for largest version
    boxWithBounds(bounds.x, bounds.y, level * PACKAGE_HEIGHT, bounds.w, bounds.h, 0.01, CLASS_BASE_RATIO);
    
    if (!HIDE_NON_SELECTED || this.isSelected()) {
      picker.start(this.index);
      fill(this.currentColor);
      // box for selected version
      int currentLoc = xmlElement.getChild(g_currentVersion - 1).getInt("loc");
      double currentFactor = currentLoc / this.getSize();
      boxWithBounds(bounds.x, bounds.y, level * PACKAGE_HEIGHT, bounds.w, bounds.h, zz, CLASS_BASE_RATIO * currentFactor);
    }
  }
}
