class ComponentButton {
  int xPos;
  int yPos;
  int col;
  int row;
  int buttonWidth;
  int buttonHeight;
  boolean researching = false;
  boolean researched;
  boolean selected;

  ComponentButton(int winWidth, int winHeight, int tmpCol, int tmpRow, boolean tmpResearched, boolean tmpSelected) {
    col = tmpCol;
    row = tmpRow;
    xPos = winWidth - 189 + (46*col);
    yPos = 55 + (35*row);
    buttonWidth = 40;
    buttonHeight = 30;
    researched = tmpResearched;
    selected = tmpSelected;
  }

  void setResearched(boolean val) {
    researched = val;
    if (researched) researching = false;
  }

  void setResearching(boolean val) {
    researching = val;
  }

  void setSelected(boolean val) {
    selected = val;
  }

  void display() {
    fill(0);
    if (selected) stroke(255,255,0);
    else if (researching) stroke(0,255,0);
    else if (researched) stroke(255);
    else stroke(127);
    rect(xPos, yPos, buttonWidth, buttonHeight);
    displayIcon();
  }

  void displayIcon() {
    pushMatrix();
    translate(xPos+2, yPos+20);

    if (selected) fill(255,255,0);
    else if (researching) fill(0,255,0);
    else if (researched) fill(255);
    else fill(127);
    textSize(smallFontSize);

    switch(col) {
    case 0:
      switch(row) {
      case 0:
        text("PB", 0, 0);
        break;
      case 1:
        text("PG", 0, 0);
        break;
      case 2:
        text("FF", 0, 0);
        break;
      case 3:
        text("FFG", 0, 0);
        break;
      case 4:
        text("DD", 0, 0);
        break;
      case 5:
        text("DDG", 0, 0);
        break;
      case 6:
        text("CG", 0, 0);
        break;
      case 7:
        text("CB", 0, 0);
        break;
      case 8:
        text("BB", 0, 0);
        break;
      case 9:
        text("CV", 0, 0);
        break;
      }
      break;
    case 1:
      switch(row) {
      case 0:
        text(".303", 0, 0);
        break;
      case 1:
        text("4.5\"", 0, 0);
        break;
      case 2:
        text("5.25\"", 0, 0);
        break;
      case 3:
        text("8\"", 0, 0);
        break;
      case 4:
        text("15\"", 0, 0);
        break;
      case 5:
        text("TRP 1", 0, 0);
        break;
      case 6:
        text("TRP 2", 0, 0);
        break;
      case 7:
        text("MIS 1", 0, 0);
        break;
      case 8:
        text("MIS 2", 0, 0);
        break;
      case 9:
        text("RAIL", 0, 0);
        break;
      }
      break;
    case 2:
      switch(row) {
      case 0:
        text("DE 1", 0, 0);
        break;
      case 1:
        text("DE 2", 0, 0);
        break;
      case 2:
        text("DE 3", 0, 0);
        break;
      case 3:
        text("DE 4", 0, 0);
        break;
      case 4:
        text("DE 5", 0, 0);
        break;
      case 5:
        text("NUC 1", 0, 0);
        break;
      case 6:
        text("NUC 2", 0, 0);
        break;
      case 7:
        text("NUC 3", 0, 0);
        break;
      case 8:
        text("NUC 4", 0, 0);
        break;
      case 9:
        text("FUSN", 0, 0);
        break;
      }
      break;
    case 3:
      switch(row) {
      case 0:
        text("NONE", 0, 0);
        break;
      case 1:
        text("MK2", 0, 0);
        break;
      case 2:
        text("MK3", 0, 0);
        break;
      case 3:
        text("MK4", 0, 0);
        break;
      case 4:
        text("MK5", 0, 0);
        break;
      case 5:
        text("MK6", 0, 0);
        break;
      case 6:
        text("MK7", 0, 0);
        break;
      case 7:
        text("SUPR", 0, 0);
        break;
      case 8:
        text("ULTR", 0, 0);
        break;
      case 9:
        text("SATT", 0, 0);
        break;
      }
      break;
    }
    popMatrix();
  }

  boolean isOver(int x, int y) {
    return ((x >= xPos) && (x <= xPos + buttonWidth) && (y >= yPos) && (y <= yPos + buttonHeight));
  }
}