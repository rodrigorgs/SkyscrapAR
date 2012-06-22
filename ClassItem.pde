
class ClassItem extends SimpleMapItem {
  color currentColor;
  int index = -1;
  String type;
  String name;
  String fullName;
  
  int[] churns;
  int[] locs;
  int[] changeds;
  int firstChurn = 0;
  int firstClassVersion;
  
  PackageItem parent;
  int level;
  XMLElement xmlElement;
  
  ClassItem() {
  }

  ClassItem(PackageItem parent, XMLElement elem, int level) {
    this.type = elem.getString("type");
    this.parent = parent;
    this.xmlElement = elem;
    this.level = level;
    this.index = g_treemapItems.size();
    this.name = elem.getString("name");
    
    if (parent == null || parent.name == null)
      this.fullName = this.name;
    else
      this.fullName = parent.fullName + "." + this.name;
    
    g_treemapItems.add(this);
    
    int maxloc = 0;
    XMLElement[] versions = elem.getChildren();
    int lastVersion = versions[versions.length-1].getInt("num");
    println("lastVersion = " + lastVersion);
    
    locs = new int[lastVersion];
    churns = new int[lastVersion];
    changeds = new int[lastVersion];
    
    println("Loading " + this.name);
    
    int lastNum = -1;
    int lastLoc = 0;
    int lastChurn = 0;
    for (XMLElement version : versions) {
      int num = version.getInt("num") - 1;
      
      locs[num] = version.getInt("curr_loc");
      churns[num] = version.getInt("churn");
      changeds[num] = 1; //version.getInt("changed");
      
      for (int i = lastNum+1; i < num; i++) {
        locs[i] = lastLoc;
        churns[i] = lastChurn;
        changeds[i] = 0;
      }
      
      lastNum = num;
      lastLoc = locs[num];
      lastChurn = churns[num];
    
      if (firstChurn == 0) {
        firstChurn = lastChurn;
        firstClassVersion = num+1;
      }
      
      if (lastLoc > maxloc)
        maxloc = lastLoc;
        
      if (lastChurn > g_maxChurn)
        g_maxChurn = lastChurn;
    }
    
    setSize(maxloc);
    
    this.currentColor = CLASS_DEFAULT_COLOR;
  }

  boolean isSelected() {
    return this.currentColor == CLASS_HIGHLIGHT_COLOR;
  }

  void toggleSelect() {
    if (this.currentColor == CLASS_DEFAULT_COLOR) {
      this.currentColor = CLASS_HIGHLIGHT_COLOR;
      g_nSelectedItems += 1;
    }
    else {
      this.currentColor = CLASS_DEFAULT_COLOR;
      g_nSelectedItems -= 1;
    }
  }

  void boxWithBounds(double x, double y, double z, double w, double h, double zz, double baseRatio) {
    float a = (float)(x + w/2);
    float b = (float)(y + h/2);
    float c = (float)(z + zz/2);
    translate(a, b, c);
    box((float)(w*baseRatio), (float)(h*baseRatio), (float)zz);
    translate(-a, -b, -c);
  }
  
  double getMaxLoc() {
    return this.getSize();
  }

  boolean hasChangedInVersion(int v) {
    return getIntForVersion("changed", v) != 0;
  }
  
  boolean hasChanged() {
    if (g_currentVersion == g_firstVersion)
      return false;
      
    if (!HIGHLIGHT_CHANGES_IS_CUMULATIVE) {
      return getIntBetweenVersions("changed", g_currentVersion) != 0;
    }
    else {
      for (int i = g_firstVersion + 1; i <= g_currentVersion; i++) {
        if (getIntBetweenVersions("changed", i) != 0)
          return true;
      }
      return false;
    }
  }
  
  int getIntForVersion(String attr, int version) {
    version = version - 1;
    int v = version;
    if (v > locs.length - 1) {
      v = locs.length - 1;
    }
    
    if (attr.equals("curr_loc"))
      return locs[v];
    else if (attr.equals("churn")) {
      if (version+1 < firstClassVersion)
        return churns[firstClassVersion-1];
      else
        return churns[v];
    }
    else if (attr.equals("changed")) {
      if (version > locs.length)
        return 0;
      else
        return changeds[v];
    }
    else
      throw new RuntimeException("Error");
      
//    return getVersion(version).getInt(attr);
  }
  
  int getIntForCurrentVersion(String attr) {
    return getIntForVersion(attr, g_currentVersion);
  }
  
  double getIntBetweenVersions(String attr, double version) {
    int version1 = floor((float)version);
    int version2 = ceil((float)version);
    double alpha = version - version1;
    
    int value1 = getIntForVersion(attr, version1);
    int value2 = getIntForVersion(attr, version2);
    
    return (1-alpha)*value1 + alpha*value2;
  }
  
  double getCurrentTweenInt(String attr) {
    return getIntBetweenVersions(attr,  g_tweeningVersion);
  }

  void draw() {
    Rect bounds = this.getBounds();
    
    stroke(1);
    strokeWeight(1);
    fill(CLASS_FLOOR_COLOR);
    // box for largest version
    boxWithBounds(bounds.x, bounds.y, (level - 1) * PACKAGE_HEIGHT, bounds.w, bounds.h, 0.02, CLASS_BASE_RATIO);
    
    if (!HIDE_NON_SELECTED || this.isSelected() || this.hasChanged()) {
      double churn = getCurrentTweenInt("churn") - firstChurn;

      double boxHeight = CLASS_MIN_HEIGHT + (churn / g_maxChurn) * CLASS_MAX_HEIGHT;
      if (boxHeight < 0) {
        boxHeight = 0;
      }
      
      double currentLoc = getCurrentTweenInt("curr_loc");
      double currentFactor = currentLoc / getMaxLoc();
      if (currentLoc == 0) {
        return;
      }
      
      strokeWeight(hasChanged() ? 2.5 : 1);
      
      picker.start(this.index);
      fill(hasChanged() ? (isSelected() ? #FF6600 : CLASS_CHANGED_COLOR) : this.currentColor);
      // box for selected version
      boxWithBounds(bounds.x, bounds.y, (level-1) * PACKAGE_HEIGHT, bounds.w, bounds.h, boxHeight, CLASS_BASE_RATIO * currentFactor);
    }
  }
}
