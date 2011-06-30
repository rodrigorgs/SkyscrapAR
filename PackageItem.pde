class PackageItem extends ClassItem implements MapModel {    
  MapLayout algorithm = new PivotBySplitSize();
  Mappable[] items;
  boolean layoutValid;
    
  public PackageItem(PackageItem parent, XMLElement folder, int level) {
    super(parent, folder, level);
    
    this.type = "package";

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
  
  void checkLayout() {
    if (!layoutValid) {
      // good place to write debug code.
      
      if (getItemCount() != 0) {
        algorithm.layout(this, bounds);
      }
      layoutValid = true;
    }
  }
  
  void draw() {
    checkLayout();
    
    // TODO: draw the package (a quarter)
    Rect bounds = this.getBounds();
    fill(0xFFff0000);
    boxWithBounds(bounds.x, bounds.y, level * PACKAGE_HEIGHT, bounds.w, bounds.h, PACKAGE_HEIGHT, 1.0);
  
    for (int i = 0; i < items.length; i++) {
      items[i].draw();
    }
  }
}
