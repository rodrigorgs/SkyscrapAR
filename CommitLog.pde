class CommitLog {
  XMLElement elem;
  
  public CommitLog(XMLElement elem) {
    this.elem = elem;
  }
  
  String getMessageForVersion(int version) {
    XMLElement[] children = this.elem.getChildren();
    if (version > children.length)
      version = children.length;
    else if (version < 1)
      version = 1;
      
    int index = version - 1;
    
    return children[index].getString("msg");
  }
  
  String getMessage() {
    return getMessageForVersion(g_currentVersion);
  }
}
