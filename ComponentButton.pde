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
    yPos = 70 + (35*row);
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
    textFont(smallFont);

    switch(col) {
    case 0:
      switch(row) {
      case 0:
        text("PtlBt", 0, 0);
        break;
      case 1:
        text("MslBt", 0, 0);
        break;
      case 2:
        text("Crvtt", 0, 0);
        break;
      case 3:
        text("Frigt", 0, 0);
        break;
      case 4:
        text("Dstyr", 0, 0);
        break;
      case 5:
        text("SSK", 0, 0);
        break;
      case 6:
        text("Crsr", 0, 0);
        break;
      case 7:
        text("SSN", 0, 0);
        break;
      case 8:
        text("LPD", 0, 0);
        break;
      case 9:
        text("A/cCr", 0, 0);
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
        text("Harpn", 0, 0);
        break;
      case 5:
        text("DChrg", 0, 0);
        break;
      case 6:
        text("15\"", 0, 0);
        break;
      case 7:
        text("StRay", 0, 0);
        break;
      case 8:
        text("Thawk", 0, 0);
        break;
      case 9:
        text("RailG", 0, 0);
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
        text("Nu 1", 0, 0);
        break;
      case 5:
        text("DETb", 0, 0);
        break;
      case 6:
        text("Nu 2", 0, 0);
        break;
      case 7:
        text("Nu 3", 0, 0);
        break;
      case 8:
        text("FBrdr", 0, 0);
        break;
      case 9:
        text("Fusn", 0, 0);
        break;
      }
      break;
    case 3:
      switch(row) {
      case 0:
        text("R Mk1", 0, 0);
        break;
      case 1:
        text("R Mk2", 0, 0);
        break;
      case 2:
        text("R Mk3", 0, 0);
        break;
      case 3:
        text("R Mk4", 0, 0);
        break;
      case 4:
        text("R Mk5", 0, 0);
        break;
      case 5:
        text("WBR 1", 0, 0);
        break;
      case 6:
        text("WBR 2", 0, 0);
        break;
      case 7:
        text("HSR 1", 0, 0);
        break;
      case 8:
        text("HSR 2", 0, 0);
        break;
      case 9:
        text("EPR R", 0, 0);
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

