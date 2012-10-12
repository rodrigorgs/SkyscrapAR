class CommitLog {
  XML elem;
  
  public CommitLog(XML elem) {
    this.elem = elem;
  }
  
  XML getVersion(int version) {
    XML[] children = this.elem.getChildren();
    if (version > children.length)
      version = children.length;
    else if (version < 1)
      version = 1;
      
    int index = version - 1;

    return children[index];
  }
  
  String getMessageForVersion(int version) {
    return getVersion(version).getString("msg");
  }
  
  String getMessage() {
    return getMessageForVersion(g_currentVersion);
  }
  
  String getAuthor() {
    return getVersion(g_currentVersion).getString("author");
  }
}
