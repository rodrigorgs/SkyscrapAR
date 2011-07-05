
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
    
    for (XMLElement version : elem.getChildren()) {
      int churn = version.getInt("sumchurn");
      if (churn > g_maxChurn)
        g_maxChurn = churn;
    }
    
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
  
  XMLElement getVersion(int version) {
    return xmlElement.getChild(version - 1);
  }
  
  XMLElement getFirstVersion() {
    return getVersion(g_firstVersion);
  }
  
  XMLElement getCurrentVersion() {
    return getVersion(g_currentVersion);
  }

  double getMaxLoc() {
    return this.getSize();
  }

  boolean hasChanged() {
    if (g_currentVersion == g_firstVersion)
      return false;
      
    if (!HIGHLIGHT_CHANGES_IS_CUMULATIVE) {
      return getCurrentVersion().getInt("changed") != 0;
    }
    else {
      for (int i = g_firstVersion + 1; i <= g_currentVersion; i++) {
        if (getVersion(i).getInt("changed") != 0)
          return true;
      }
      return false;
    }
  }
  
  double getIntBetweenVersions(String attr, double version) {
    int version1 = floor((float)version);
    int version2 = ceil((float)version);
    double alpha = version - version1;
    
    int value1 = getVersion(version1).getInt(attr);
    int value2 = getVersion(version2).getInt(attr);
    
    return (1-alpha)*value1 + alpha*value2;
  }
  
  double getCurrentTweenInt(String attr) {
    return getIntBetweenVersions(attr,  g_tweeningVersion);
  }

  void draw() {
    Rect bounds = this.getBounds();
    
    stroke(0);
    fill(0x99ffffff);
    // box for largest version
    boxWithBounds(bounds.x, bounds.y, level * PACKAGE_HEIGHT, bounds.w, bounds.h, 0.01, CLASS_BASE_RATIO);
    
    if (!HIDE_NON_SELECTED || this.isSelected()) {
      XMLElement current = getCurrentVersion();
      XMLElement first = getFirstVersion();
      double churn = getCurrentTweenInt("sumchurn") - first.getInt("sumchurn");
      double boxHeight = CLASS_MIN_HEIGHT + (churn / g_maxChurn) * CLASS_MAX_HEIGHT; 
      double currentLoc = getCurrentTweenInt("loc");
      double currentFactor = currentLoc / getMaxLoc();
      if (currentLoc == 0) {
        return;
      }
      
      strokeWeight(hasChanged() ? 4 : 1);
      
      picker.start(this.index);
      fill(this.currentColor);
      // box for selected version
      boxWithBounds(bounds.x, bounds.y, level * PACKAGE_HEIGHT, bounds.w, bounds.h, boxHeight, CLASS_BASE_RATIO * currentFactor);
    }
  }
}
