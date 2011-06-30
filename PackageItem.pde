class PackageItem extends ClassItem implements MapModel {    
  MapLayout algorithm = new PivotBySplitSize();
  Mappable[] items;
  boolean layoutValid;
    
  public PackageItem(PackageItem parent, XMLElement folder, int level) {
    super(parent, folder, level);

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
      // DEBUG
      print("bounds: " + bounds.toString());
      
      if (getItemCount() != 0) {
        algorithm.layout(this, bounds);
      }
      layoutValid = true;
    }
  }
  
  void draw() {
    checkLayout();
    calcBox();
    // TODO: draw the package (a quarter)
  
    for (int i = 0; i < items.length; i++) {
      items[i].draw();
    }
  }
}
