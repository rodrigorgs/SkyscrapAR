class PackageItem extends ClassItem implements MapModel {    
  MapLayout algorithm = new PivotBySplitSize();
  Mappable[] items;
  boolean layoutValid;
    
  public PackageItem(PackageItem parent, XMLElement folder, int level) {
//    super(parent, folder, level);      
    this.type = "package";
    this.parent = parent;
    this.level = level;
    this.index = g_treemapItems.size();
    this.name = folder.getString("name");    
    
    if (parent == null)
      this.fullName = this.name;
    else
      this.fullName = parent.fullName + "." + this.name;

    
    g_treemapItems.add(this);

    XMLElement[] contents = folder.getChildren();
    items = new Mappable[contents.length];
    int count = 0;
    for (int i = 0; i < contents.length; i++) {
      
      XMLElement elem = contents[i];
      ClassItem newItem = null;
      if (elem.getName().equals("class")) {
        newItem = new ClassItem(this, elem, level+1);
      }
      else {
        newItem = new PackageItem(this, elem, level+1);
      }
       
      items[count++] = newItem;
      size += newItem.getSize();
    }
  }
  
  /* MapModel interface */
  Mappable[] getItems() {
    return items;
  }

  int getItemCount() {
    return items.length;
  }
  
  /* Drawing */
  
  Rect rectRatio(Rect rect, double ratio) {
    double deltaw = rect.w * (1 - ratio)/2;
    double deltah = rect.h * (1 - ratio)/2;
    return new Rect(rect.x + deltaw, rect.y + deltah, rect.w*ratio, rect.h*ratio);
  }
  
  void checkLayout() {
    if (!layoutValid) {
      // good place to write debug code.
      
      if (getItemCount() != 0) {
        algorithm.layout(this, rectRatio(bounds, PACKAGE_BASE_RATIO));
      }
      layoutValid = true;
    }
  }
  
  void draw() {
    checkLayout();
    
    picker.start(32767);
    // TODO: draw the package (a quarter)
    Rect bounds = this.getBounds();
    fill(1.0 - level * 0.2, 0.0, 0.0, 1.0);
    strokeWeight(1);
    stroke(0);
//    fill(0xFFff0000);
    boxWithBounds(bounds.x, bounds.y, level * PACKAGE_HEIGHT, bounds.w, bounds.h, PACKAGE_HEIGHT, PACKAGE_BASE_RATIO);
  
    for (int i = 0; i < items.length; i++) {
      items[i].draw();
    }
  }
}
