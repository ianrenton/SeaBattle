import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Sea_Battle extends PApplet {

// DIFFICULTY OPTIONS //
float RESEARCH_TIME = 1.5f; // Higher numbers slow down research
int AI_BUILD_THINKING_TIME = 300; // Number of ticks AI takes to decide on a build.  Lost on 240, easy win on 500

boolean DEBUG = true;

BuildQueue myQueue = new BuildQueue(true);
BuildQueue enemyQueue = new BuildQueue(false);
Base myBase;
Base enemyBase;
ArrayList<Ship> myShips = new ArrayList<Ship>();
ArrayList<Ship> enemyShips = new ArrayList<Ship>();
PFont titleFont;
PFont buttonFont;
PFont smallFont;
boolean shipSelected = false;
float MY_BASE_X;
float MY_BASE_Y;
float ENEMY_BASE_X;
float ENEMY_BASE_Y;
int NUM_COMPONENTS = 4;
int NUM_CHOICES_PER_COMPONENT = 10;
boolean mouseDragging = false;
int dragStartX;
int dragStartY;
ComponentButton[][] componentButtons = new ComponentButton[NUM_COMPONENTS][NUM_CHOICES_PER_COMPONENT];

public void setup() {
  size(600,600);
  frameRate(30);
  titleFont = loadFont("FreeMono-28.vlw");
  buttonFont = loadFont("CourierNewPSMT-20.vlw");
  smallFont = loadFont("LucidaSans-12.vlw");

  for (int i=0; i<NUM_COMPONENTS; i++) {
    for (int j=0; j<NUM_CHOICES_PER_COMPONENT; j++) {
      componentButtons[i][j] = new ComponentButton(width, height, i, j, (j==0), (j==0));
    }
  }

  myBase = new Base(true, width, height);
  enemyBase = new Base(false, width, height);
  MY_BASE_X = (width-200)/2-13;
  MY_BASE_Y = height-55;
  ENEMY_BASE_X = (width-200)/2+10;
  ENEMY_BASE_Y = 55;
}

public void draw() {
  if (!myBase.isDead() && !enemyBase.isDead()) {
    // Normal condition, play game
    // Render UI bits
    drawUI();
    myQueue.updateComponentButtons();
    // Number-crunching
    myQueue.tick();
    enemyQueue.tick();
    myQueue.displayResearchProgress();
    myQueue.displayBuildProgress();
    myQueue.displayQueueDots();
    for (int i=0; i<enemyShips.size(); i++) enemyShips.get(i).ai();
    for (int i=0; i<enemyShips.size(); i++) enemyShips.get(i).move();
    for (int i=0; i<myShips.size(); i++) myShips.get(i).move();
    for (int i=0; i<enemyShips.size(); i++) if (enemyShips.get(i).isDead()) enemyShips.remove(i);
    for (int i=0; i<myShips.size(); i++) if (myShips.get(i).isDead()) myShips.remove(i);
    // Game field rendering
    drawField();
    myBase.display();
    enemyBase.display();
    for (int i=0; i<myShips.size(); i++) myShips.get(i).displayDestinationMarker();
    for (int i=0; i<enemyShips.size(); i++) enemyShips.get(i).displayHealthBar();
    for (int i=0; i<myShips.size(); i++) myShips.get(i).displayHealthBar();
    for (int i=0; i<enemyShips.size(); i++) enemyShips.get(i).display();
    for (int i=0; i<myShips.size(); i++) myShips.get(i).display();
    // Mouse dragging
    if (mouseDragging) {
      stroke(255);
      noFill();
      rectMode(CORNERS);
      rect(dragStartX, dragStartY, mouseX, mouseY);
      rectMode(CORNER);
    }
  
  } 
  else if (myBase.isDead()) {
    // You lose
    stroke(255);
    fill(0);
    rectMode(CORNER);
    rect(100,height/2-20,width-200,40);
    fill(255);
    textFont(titleFont);
    text("You Lose", width/2-70, height/2+8);
  } 
  else {
    // You win
    stroke(255);
    fill(0);
    rectMode(CORNER);
    rect(100,height/2-20,width-200,40);
    fill(255);
    textFont(titleFont);
    text("You Win!", width/2-70, height/2+8);
  }
}

public void mouseDragged() {
  if (!mouseDragging) {
    dragStartX = mouseX;
    dragStartY = mouseY;
    mouseDragging = true;
  }
}

public void mouseReleased() {
  if (mouseDragging) {
    int maxX = max(mouseX, dragStartX);
    int minX = min(mouseX, dragStartX);
    int maxY = max(mouseY, dragStartY);
    int minY = min(mouseY, dragStartY);
    for (int i=0; i<myShips.size(); i++) {
      if ((myShips.get(i).xPos <= maxX) && (myShips.get(i).xPos >= minX) && (myShips.get(i).yPos <= maxY) && (myShips.get(i).yPos >= minY)) {
        myShips.get(i).selected = true;
        shipSelected = true;
      }
    }
    dragStartX = mouseX;
    dragStartY = mouseY;
    mouseDragging = false;
  }
}

public void mouseClicked() {
  // Right-click = deselect, wherever it happens.
  if (mouseButton == RIGHT) {
    for (int i=0; i<myShips.size(); i++) {
      if (myShips.get(i).selected == true) {
        myShips.get(i).selected = false;
      }
    }
    shipSelected = false;
  } 
  else {

    // Click in game field
    if ((mouseX > 3) && (mouseX < width-200) && (mouseY > 3) && (mouseY < height-3)) {
      // Ship selected already, so now we're giving instructions
      if (shipSelected) {
        for (int i=0; i<myShips.size(); i++) {
          if (myShips.get(i).selected == true) {
            myShips.get(i).setGoalPosition(mouseX, mouseY);
            myShips.get(i).selected = false;
          }
        }
        shipSelected = false;

        // We're selecting a ship.
      } 
      else {
        int closestShip = -1;
        float minDistance = 75;
        for (int i=0; i<myShips.size(); i++) {
          float dist = distance(myShips.get(i).xPos, myShips.get(i).yPos, mouseX, mouseY);
          if (dist < minDistance) {
            closestShip = i;
            minDistance = dist;
          }
        }
        for (int i=0; i<myShips.size(); i++) {
          myShips.get(i).selected = (i==closestShip)?true:false;
        }
        shipSelected = true;
      }
    }

    // Click on Build button
    if ((mouseX > width-190) && (mouseX < width-10) && (mouseY > height-40) && (mouseY < height-10)) {
      myQueue.build();
    }

    // Click on component button.  Selects it if it's researched already,
    // attempts to research it if it's next in line.
    for (int i=0; i<NUM_COMPONENTS; i++) {
      for (int j=0; j<NUM_CHOICES_PER_COMPONENT; j++) {
        if (componentButtons[i][j].isOver(mouseX, mouseY)) {
          if (componentButtons[i][j].researched) {
            myQueue.setSelectedComponent(i, j);
          } 
          else if (componentButtons[i][j-1].researched) {
            myQueue.setResearchComponent(i, j);
          }
        }
      }
    }
  }
}

public void drawUI() {
  background(0);
  stroke(255);
  fill(0);
  rectMode(CORNER);
  // Right bar
  rect(width-197,3,194,height-6);
  // Research percentage bar
  rect(width-190,height-90,181,6);
  // Build button
  rect(width-190,height-40,181,30);
  // Build percentage bar
  rect(width-190,height-50,181,6);
  // Build queue boxes
  for (int i=0; i<10; i++) {
    stroke(255);
    fill(0);
    rect(width-190+(19*i),height-64,10,10);
  }
  // Build configuration headers
  textFont(smallFont);
  fill(255);
  text("Hull", width - 180, 60);
  text("Weapon", width - 148, 60);
  text("Engines", width - 98, 60);
  text("Radar", width - 48, 60);

  text("Build", width - 190, height-68);
  text("Research", width - 190, height-93);

  textFont(titleFont);
  text("Sea Battle", width-187, 25);
  textFont(buttonFont);
  text("BUILD", width-128, height-19);
}

public void drawField() {
  // Water
  stroke(255);
  fill(64,64,180);
  rectMode(CORNER);
  rect(3,3,width-203,height-6);

  // Land
  pushMatrix();
  translate(4,4);
  drawLand();
  translate(width-204,height-7);
  rotate(radians(180));
  drawLand();
  popMatrix();
}

public void drawLand() {
  noStroke();
  fill(30,200,30);
  beginShape();
  vertex(0,0);
  vertex(width-204,0);
  vertex(width-204,10);
  vertex((width-204)*2/3,24);
  vertex((width-204)/3,16);
  vertex(0,20);
  endShape(CLOSE);
}

public float distance(float x1, float y1, float x2, float y2) {
  return sqrt(sq(x2-x1) + sq(y2-y1));
}

public float angle(float x1, float y1, float x2, float y2) {
  float a = atan((x2-x1)/(y1-y2));
  if (y2 > y1) a = a + PI;
  if (a >= TWO_PI) a -= TWO_PI;
  if (a < 0) a += TWO_PI;
  return degrees(a);
}

// Spawn a ship on the map in the next available slot.
public void spawn(boolean player, Ship ship) {
  if (player) {
    // Find a free slot for the ship
    boolean found;
    int jump = 0;
    do {
      found = false;
      for (int i=0; i<myShips.size(); i++) {
          println(myShips.get(i).xPos + "  " + MY_BASE_X + jump);
        if ((myShips.get(i).xPos == MY_BASE_X + jump) && (myShips.get(i).yPos == MY_BASE_Y)) {
          found = true;
        }
      }
      jump += 15;
    } 
    while (found && (jump < 150));
    ship.xPos = MY_BASE_X + jump - 15;

    myShips.add(ship);
  } 
  else {
    // Find a free slot for the ship
    boolean found;
    int jump = 0;
    do {
      found = false;
      for (int i=0; i<enemyShips.size(); i++) {
          println(enemyShips.get(i).xPos + "  " + (ENEMY_BASE_X - jump));
        if ((enemyShips.get(i).xPos == ENEMY_BASE_X - jump) && (enemyShips.get(i).yPos == ENEMY_BASE_Y)) {
          found = true;
        }
      }
      jump += 15;
    } 
    while (found && (jump < 150));
    ship.xPos = ENEMY_BASE_X - jump + 15;
    
    enemyShips.add(ship);
  }
}

class Base extends Damageable {
  boolean player;
  float maxHealth = 100000;
  int xPos;
  int yPos;
  float orientation;
  
  Base(boolean tempPlayer, int winWidth, int winHeight) {
    player = tempPlayer;
    health = maxHealth;
    
    if (!player) {
      xPos = ((winWidth-204)/2)+20;
      yPos = 36;
      orientation = 0;
    } else {
      xPos = ((winWidth-204)/2)-20;
      yPos = winHeight-36;
      orientation = 180;
    }
  }
  
  public boolean isDead() {
    return (health <= 0);
  }
  
  public void display() {
    // Switch to matrix relative to base position and orientation to draw it
    pushMatrix();
    translate(xPos,yPos);
    rotate(radians(orientation));
    stroke(100);
    fill(200);
    beginShape();
    vertex(-40,-30);
    vertex(10,-30);
    vertex(10,30);
    vertex(0,30);
    vertex(0,0);
    vertex(-40,0);
    endShape(CLOSE);    
    popMatrix();
    
    // Switch to matrix relative to position only to draw the health bar
    pushMatrix();
    translate(xPos,yPos);
    displayHealthBar();  
    popMatrix();
 }
  
  public void displayHealthBar() {
    int xOffset = -40;
    int yOffset = -30;
    if (player) {
      xOffset = -10;
      yOffset = 25;
    }
    int healthpx = (int)(health / maxHealth * 49);
    stroke(0);
    fill(0);
    rect(xOffset, yOffset, 50, 5);
    noStroke();
    if (healthpx > 10) fill(0,255,0);
    else if (healthpx > 5) fill(255,255,0);
    else fill(255,0,0);
    rect(xOffset+1,yOffset+1,healthpx,4);
  }
}
class BuildQueue {
  boolean player;
  ArrayList<Ship> queue = new ArrayList<Ship>();
  int aiBuildTicker = 0;
  int spawnTicker = 0;
  int spawnTickerStartedFrom = 0;
  int maxHull = 0;
  int maxWeapon = 0;
  int maxEngine = 0;
  int maxRadar = 0;
  int selectedHull = 0;
  int selectedWeapon = 0;
  int selectedEngine = 0;
  int selectedRadar = 0;
  int researchingComponent = -1;
  boolean researching = false;
  int researchTicker = 0;
  int researchTickerStartedFrom = 0;


  BuildQueue(boolean tempPlayer) {
    player = tempPlayer;
  }

  public void tick() {
    if (!player) {
      // Enemy build & research automation
      aiBuildTicker++;
      
      // Everything has a "thinking" delay
      if (aiBuildTicker%AI_BUILD_THINKING_TIME == 0) {
        
        // Only build when queue is empty, so we're always building the latest stuff
        if (queue.size() == 0) {
          // Pick what to build.
          // Hull: random
          // Weapon: random from the top half of what's researched
          // Engine/Radar: always max.
          selectedHull = PApplet.parseInt(floor(random(maxHull+1)));
          selectedWeapon = PApplet.parseInt(floor(random((maxWeapon+1)/2) + ((maxWeapon+1)/2)));
          selectedEngine = maxEngine;
          selectedRadar = maxRadar;
          build(selectedHull, selectedWeapon, selectedEngine, selectedRadar);
        }
        
        // Only research when able
        if (!researching) {
          int[] maxLevels = { maxHull, maxWeapon, maxEngine, maxRadar };
          int minMaxLevel = min(maxLevels);
          if (maxHull == minMaxLevel) setResearchComponent(0, minMaxLevel+1);
          else if (maxWeapon == minMaxLevel) setResearchComponent(1, minMaxLevel+1);
          else if (maxEngine == minMaxLevel) setResearchComponent(2, minMaxLevel+1);
          else setResearchComponent(3, minMaxLevel+1);
        }
      }
    }

    // Count down spawn ticker
    if (queue.size() > 0) {
      spawnTicker--;
      // If zero, we spawn the ship
      if (spawnTicker <= 0) {
        spawn(player, queue.get(0));
        queue.remove(0);
        // If there's still something in the queue, reset the ticker.  Otherwise, leave it and
        // set the "started from" to zero.
        if (queue.size() > 0) {
          spawnTicker = queue.get(0).hull.buildTime;
          spawnTickerStartedFrom = spawnTicker;
        } 
        else {
          spawnTickerStartedFrom = 0;
        }
      }
    }

    // Count down research ticker
    if (researching) {
      researchTicker--;
      // If zero, we complete research
      if (researchTicker <= 0) {
        switch (researchingComponent) {
        case 0:
          maxHull++;
          break;
        case 1:
          maxWeapon++;
          break;
        case 2:
          maxEngine++;
          break;
        case 3:
          maxRadar++;
          break;
        }
        researching = false;
        researchTickerStartedFrom = 0;
        if (player) updateComponentButtons();
      }
    }
  }

  // Adds an item to the queue based on what's currently selected
  public void build() {
    build(selectedHull, selectedWeapon, selectedEngine, selectedRadar);
  }

  // Adds an item to the queue
  public void build(int hull, int weapon, int engine, int radar) {
    // 11 is max queue size (1 in progress, 10 backed up)
    if (queue.size() <= 10) {
      // Add ship of correct alleigance and position
      if (player) {
        queue.add(new Ship(true, MY_BASE_X, MY_BASE_Y, 0, new Hull(hull), new Weapon(weapon), new Engine(engine), new Radar(radar)));
      } 
      else {
        queue.add(new Ship(false, ENEMY_BASE_X, ENEMY_BASE_Y, 180, new Hull(hull), new Weapon(weapon), new Engine(engine), new Radar(radar)));
      }
      /* DEBUG print enemy build */  if ((DEBUG) && (!player)) println("Enemy build: " + hull + " " + weapon + " " + engine + " " + radar);
      // If the queue *was* empty, set the spawn ticker for this new build.
      if (queue.size() == 1) {
        spawnTicker = queue.get(0).hull.buildTime;
        spawnTickerStartedFrom = spawnTicker;
      }
    }
  }


  // Selects a component option for research
  public void setResearchComponent(int component, int option) {
    // Only start new research if nothing ongoing
    if (!researching) {
      /* DEBUG print enemy techlevel */  if ((DEBUG) && (!player)) println("Enemy tech level: " + maxHull + " " + maxWeapon + " " + maxEngine + " " + maxRadar + "  Researching " + component + " / " + option);
      switch (component) {
      case 0:
        if (option == maxHull+1) {
          researchingComponent = component;
          researchTicker = (int)(pow(RESEARCH_TIME,(float)option)*100);
          researchTickerStartedFrom = researchTicker;
          researching = true;
          if (player) componentButtons[component][option].setResearching(true);
        }
        break;
      case 1:
        if (option == maxWeapon+1) {
          researchingComponent = component;
          researchTicker = (int)(pow(RESEARCH_TIME,(float)option)*100);
          researchTickerStartedFrom = researchTicker;
          researching = true;
          if (player) componentButtons[component][option].setResearching(true);
        }
        break;
      case 2:
        if (option == maxEngine+1) {
          researchingComponent = component;
          researchTicker = (int)(pow(RESEARCH_TIME,(float)option)*100);
          researchTickerStartedFrom = researchTicker;
          researching = true;
          if (player) componentButtons[component][option].setResearching(true);
        }
        break;
      case 3:
        if (option == maxRadar+1) {
          researchingComponent = component;
          researchTicker = (int)(pow(RESEARCH_TIME,(float)option)*100);
          researchTickerStartedFrom = researchTicker;
          researching = true;
          if (player) componentButtons[component][option].setResearching(true);
        }
        break;
      }
    }
    if (player) updateComponentButtons();
  }

  // Sets a component option as selected
  public void setSelectedComponent(int component, int option) {
    // Set the internal var
    switch (component) {
    case 0:
      selectedHull = option;
      break;
    case 1:
      selectedWeapon = option;
      break;
    case 2:
      selectedEngine = option;
      break;
    case 3:
      selectedRadar = option;
      break;
    }
    if (player) updateComponentButtons();
  }


  // Update component button status
  public void updateComponentButtons() {

    // Update the buttons to show glowing outline for selected ones.
    for (int j=0; j<NUM_CHOICES_PER_COMPONENT; j++) {
      componentButtons[0][j].setSelected(j == selectedHull);
      componentButtons[0][j].setResearched(j <= maxHull);
      componentButtons[0][j].display();
    }
    for (int j=0; j<NUM_CHOICES_PER_COMPONENT; j++) {
      componentButtons[1][j].setSelected(j == selectedWeapon);
      componentButtons[1][j].setResearched(j <= maxWeapon);
      componentButtons[1][j].display();
    }
    for (int j=0; j<NUM_CHOICES_PER_COMPONENT; j++) {
      componentButtons[2][j].setSelected(j == selectedEngine);
      componentButtons[2][j].setResearched(j <= maxEngine);
      componentButtons[2][j].display();
    }
    for (int j=0; j<NUM_CHOICES_PER_COMPONENT; j++) {
      componentButtons[3][j].setSelected(j == selectedRadar);
      componentButtons[3][j].setResearched(j <= maxRadar);
      componentButtons[3][j].display();
    }
  }

  // Displays a progress bar for the current build.
  public void displayBuildProgress() {
    int progresspx = 0;
    if (spawnTickerStartedFrom > 0) {
      progresspx = (int)((float)(spawnTickerStartedFrom - spawnTicker) / (float)(spawnTickerStartedFrom-1) * 178);
    }
    noStroke();
    fill(255,255,0);
    rect(width-189,height-49,progresspx,5);
    fill(0);
    rect(width-189+progresspx,height-49,178-progresspx,5);
  }

  // Displays a progress bar for the current build.
  public void displayResearchProgress() {
    int progresspx = 0;
    if (researchTickerStartedFrom > 0) {
      progresspx = (int)((float)(researchTickerStartedFrom - researchTicker) / (float)(researchTickerStartedFrom-1) * 178);
    }
    noStroke();
    fill(0,255,0);
    rect(width-189,height-89,progresspx,5);
    fill(0);
    rect(width-189+progresspx,height-89,178-progresspx,5);
  }

  // Displays dots for things backed up in the queue.  Start painting green,
  // switch to black when we're over the queue size.
  public void displayQueueDots() {
    noStroke();
    fill(255,255,0);
    for (int i=0; i<10; i++) {
      if (i >= queue.size()-1) {
        fill(0);
      }
      rect(width-189+(19*i),height-63,9,9);
    }
  }
}

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

  public void setResearched(boolean val) {
    researched = val;
    if (researched) researching = false;
  }

  public void setResearching(boolean val) {
    researching = val;
  }

  public void setSelected(boolean val) {
    selected = val;
  }

  public void display() {
    fill(0);
    if (selected) stroke(255,255,0);
    else if (researching) stroke(0,255,0);
    else if (researched) stroke(255);
    else stroke(127);
    rect(xPos, yPos, buttonWidth, buttonHeight);
    displayIcon();
  }

  public void displayIcon() {
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

  public boolean isOver(int x, int y) {
    return ((x >= xPos) && (x <= xPos + buttonWidth) && (y >= yPos) && (y <= yPos + buttonHeight));
  }
}

abstract class Damageable {
  
  float health;
  
  public void damage(float damage) {
    health -= damage;
    if (health < 0) health = 0;
  }
  
}
class Engine {
  int type;
  float thrust = 0;
  
  Engine(int tempType) {
    type = tempType;
    
    switch(type) {
      case 0:
        thrust = 400;
        break;
      case 1:
        thrust = 600;
        break;
      case 2:
        thrust = 1000;
        break;
      case 3:
        thrust = 1500;
        break;
      case 4:
        thrust = 2200;
        break;
      case 5:
        thrust = 3000;
        break;
      case 6:
        thrust = 4000;
        break;
      case 7:
        thrust = 6000;
        break;
      case 8:
        thrust = 10000;
        break;
      case 9:
        thrust = 15000;
        break;
    }
  }
}
class Hull {
  int type;
  float armour = 0;
  int buildTime = 9999999;
  float weight = 9999999;
  boolean submarine = false;
  
  Hull(int tempType) {
    type = tempType;
    
    switch(type) {
      case 0:
        armour = 20;
        buildTime = 120;
        weight = 1000;
        break;
      case 1:
        armour = 30;
        buildTime = 150;
        weight = 1500;
        break;
      case 2:
        armour = 50;
        buildTime = 180;
        weight = 2000;
        break;
      case 3:
        armour = 100;
        buildTime = 250;
        weight = 4000;
        break;
      case 4:
        armour = 200;
        buildTime = 400;
        weight = 6000;
        break;
      case 5:
        armour = 100;
        buildTime = 300;
        weight = 5000;
        break;
      case 6:
        armour = 400;
        buildTime = 550;
        weight = 8000;
        break;
      case 7:
        armour = 500;
        buildTime = 700;
        weight = 12000;
        break;
      case 8:
        armour = 800;
        buildTime = 800;
        weight = 15000;
        break;
      case 9:
        armour = 1200;
        buildTime = 1000;
        weight = 20000;
        break;
    }
  }

  
  public void display() {
    
    switch(type) {
      case 0:
        beginShape();
        vertex(10,0);
        vertex(2,5);
        vertex(-10,4);
        vertex(-10,-4);
        vertex(2,-5);
        endShape(CLOSE);
        break;
      case 1:
        beginShape();
        vertex(15,0);
        vertex(4,6);
        vertex(-15,4);
        vertex(-15,-4);
        vertex(4,-6);
        endShape(CLOSE);
        break;
      case 2:
        beginShape();
        vertex(18,0);
        vertex(4,6);
        vertex(-18,4);
        vertex(-18,-4);
        vertex(4,-6);
        endShape(CLOSE);
        break;
      case 3:
        beginShape();
        vertex(18,0);
        vertex(5,6);
        vertex(-18,5);
        vertex(-18,-5);
        vertex(5,-6);
        endShape(CLOSE);
        break;
      case 4:
        beginShape();
        vertex(20,0);
        vertex(5,6);
        vertex(-20,5);
        vertex(-20,-5);
        vertex(5,-6);
        endShape(CLOSE);
        break;
      case 5:
        beginShape();
        curveVertex(0,-4);
        curveVertex(10,-4);
        curveVertex(15,0);
        curveVertex(10,4);
        curveVertex(0,4);
        curveVertex(0,4);
        curveVertex(-10,4);
        curveVertex(-15,0);
        curveVertex(-10,-4);
        curveVertex(0,-4);
        endShape(CLOSE);
        break;
      case 6:
        beginShape();
        vertex(25,0);
        vertex(6,7);
        vertex(-25,6);
        vertex(-25,-6);
        vertex(6,-7);
        endShape(CLOSE);
        break;
      case 7:
        beginShape();
        curveVertex(0,-5);
        curveVertex(15,-5);
        curveVertex(20,0);
        curveVertex(15,5);
        curveVertex(0,5);
        curveVertex(0,5);
        curveVertex(-15,5);
        curveVertex(-20,0);
        curveVertex(-15,-5);
        curveVertex(0,-5);
        endShape(CLOSE);
        break;
      case 8:
        beginShape();
        vertex(25,-8);
        vertex(25,8);
        vertex(-25,8);
        vertex(-25,-8);
        endShape(CLOSE);
        break;
      case 9:
        beginShape();
        vertex(30,0);
        vertex(4,8);
        vertex(-30,7);
        vertex(-30,-7);
        vertex(4,-9);
        vertex(25,-9);
        vertex(25,-2);
        endShape(CLOSE);
        break;
    }
  }
}
class Radar {
  int type;
  float range = 0;
  
  Radar(int tempType) {
    type = tempType;
    
    switch(type) {
      case 0:
        range = 20;
        break;
      case 1:
        range = 25;
        break;
      case 2:
        range = 35;
        break;
      case 3:
        range = 50;
        break;
      case 4:
        range = 70;
        break;
      case 5:
        range = 95;
        break;
      case 6:
        range = 125;
        break;
      case 7:
        range = 165;
        break;
      case 8:
        range = 225;
        break;
      case 9:
        range = 300;
        break;
    }
  }
}
class Ship extends Damageable {
  boolean player;
  float xPos;
  float yPos;
  float maxSpeed;
  float speed = 0;
  float bearing;
  float xGoal = -1;
  float yGoal = -1;
  boolean movingToGoal = false;
  boolean selected = false;
  ArrayList<Ship> targets;
  Base baseTarget;
  int targetShip = -1;
  Weapon weapon;
  Hull hull;
  Engine engine;
  Radar radar;
  float scariness = 999999; // Scariness for AI target-picking
  
  Ship(boolean tempPlayer, float tempXPos, float tempYPos, float tempBearing, Hull tempHull, Weapon tempWeapon, Engine tempEngine, Radar tempRadar) {
    player = tempPlayer;
    xPos = tempXPos;
    yPos = tempYPos;
    bearing = tempBearing;
    weapon = tempWeapon;
    hull = tempHull;
    engine = tempEngine;
    radar = tempRadar;
    
    maxSpeed = engine.thrust / hull.weight;
    health = hull.armour;
    calcScariness();
  }
  
  // AI routine for enemy ships
  public void ai() {
    // Look for targets
    int closestShip = -1;
    float minDistance = 9999;
    for (int i=0; i<myShips.size(); i++) {
      float dist = distance(xPos, yPos, myShips.get(i).xPos, myShips.get(i).yPos);
      // Consider ships that are less scary than this one, or that are really close for kamikaze
      if ((dist < minDistance) && ((dist < radar.range/2) || (scariness > myShips.get(i).scariness))) {
        closestShip = i;
        minDistance = dist;
      }
    }
    
    // Set goals based on situation
    if (minDistance <= radar.range*4/5) {
      // If well within firing range, hold station
      movingToGoal = false;
    } else if (closestShip >= 0) {
      // If there's a ship on the board that's outside or close to edge of
      // firing range, move closer.
      setGoalPosition(myShips.get(closestShip).xPos, myShips.get(closestShip).yPos);
    } else if (distance(xPos, yPos, myBase.xPos, myBase.yPos) <= radar.range*4/5){
      // Within firing range of player base, stop (and fire)
      movingToGoal = false;
    } else {
      // No player ships to target, and not near to player base, so head for it
      setGoalPosition(myBase.xPos, myBase.yPos);
    }
  }
  
  
  // Movement routine - enemy ships must run ai() first, player ships can just run this.
  public void move() {
    // Movement Decision-making /////
    
    if ((distance(xPos, yPos, xGoal, yGoal) < 5+(maxSpeed/2)) || (movingToGoal == false)) {
      // Close enough or no target, so stop.  As turn rate is based on maxSpeed, accuracy
      // must be based on it too otherwise we risk continuous overshoot.
      speed = 0;
      movingToGoal = false;
    } else if (abs(bearing - angle(xPos, yPos, xGoal, yGoal)) < 5+maxSpeed) {
      // Angle right, so set speed.  As turn rate is based on maxSpeed, accuracy
      // must be based on it too otherwise we risk continuous overshoot.
      speed = maxSpeed;
    } else {
      // Angle wrong, so turn.  Turning rate based on maxSpeed
      float diff = bearing - angle(xPos, yPos, xGoal, yGoal);
      if (((diff > 0) && (diff <= 180)) || (diff < -180)) bearing -= 1+(maxSpeed/2);
      else bearing += 1+(maxSpeed/2);
      //println(bearing + "   " + angle(xPos, yPos, xGoal, yGoal) + "   " + diff);
    }
    
    
    // Actual movement /////
    
    xPos = xPos + (speed * sin(radians(bearing)));
    yPos = yPos - (speed * cos(radians(bearing)));
    if (xPos > width-210) {
      xPos = width-210;
    } else if (xPos < 10) {
      xPos = 10;
    }
    if (yPos > height-30) {
      yPos = height-30;
    } else if (yPos < 30) {
      yPos = 30;
    }
    // Prevent runaway positive/negative bearings
    if (bearing >= 360) bearing -= 360;
    if (bearing < 0) bearing += 360;
    
    
    // Targetting /////
    
    targetShip = -1;
    float minDistance = radar.range;
    // If a player ship, target enemies, otherwise target player ships.
    if (player) {
      targets = enemyShips;
      baseTarget = enemyBase;
    } else {
      targets = myShips;
      baseTarget = myBase;
    }
    for (int i=0; i<targets.size(); i++) {
      float dist = distance(xPos, yPos, targets.get(i).xPos, targets.get(i).yPos);
      if (dist < minDistance) {
        targetShip = i;
        minDistance = dist;
      }
    }
    if (targetShip > -1) {
      // Targettable ship in range
      weapon.setTarget(targets.get(targetShip), true);
      weapon.setAbsoluteBearing(angle(xPos, yPos, targets.get(targetShip).xPos, targets.get(targetShip).yPos));
    } else {
      // No targettable ship, check for the base
      if (distance(xPos, yPos, baseTarget.xPos, baseTarget.yPos) < radar.range) {
        weapon.setTarget(baseTarget, true);
        weapon.setAbsoluteBearing(angle(xPos, yPos, baseTarget.xPos, baseTarget.yPos));
      }
      else {
        // Base isn't targetable either, so return gun to centre.
        weapon.setTarget(null, false);
        weapon.setAbsoluteBearing(bearing);
      }
    }
  }
  
  public void setGoalPosition(float x, float y) {
    xGoal = x;
    yGoal = y;
    movingToGoal = true;
  }
  
  // Calculate how scary this ship is to the AI.  TODO recalc on health loss
  public void calcScariness() {
    scariness = (weapon.power / weapon.rate) * health;
  }
  
  public boolean isDead() {
    return (health <= 0);
  }
  
  public void display() {
    // Switch to matrix relative to ship position and bearing
    pushMatrix();
    translate(xPos,yPos);
    rotate(radians(bearing-90)); // -90 to translate from zero being up to being right
    
    // Display radar circle
    if (selected) {
      stroke(127,127,255);
      noFill();
      ellipseMode(RADIUS);
      ellipse(0,0,radar.range,radar.range);
    }
    
    // Display hull
    stroke(0);
    if (player) fill(color(127,127,200));
    else fill(color(200,127,127));
    hull.display();
    popMatrix();
    
    // Switch to matrix relative to ship position BUT NOT bearing (for weapon & healthbar)
    pushMatrix();
    translate(xPos,yPos);
    weapon.attemptFire();
    weapon.display();
    popMatrix();
  }
  
  public void displayDestinationMarker() {
    if ((movingToGoal) && (player)) {
      strokeWeight(5);
      stroke(127,127,255);
      line(xPos, yPos, xGoal, yGoal);
      strokeWeight(1);
    }
  }
  
  public void displayHealthBar() {
    // Switch to matrix relative to ship position BUT NOT bearing (for weapon & healthbar)
    pushMatrix();
    translate(xPos,yPos);
    
    int healthpx = (int)(health / hull.armour * 20);
    stroke(0);
    fill(0);
    rect(-10, 20, 20, 4);
    if (healthpx > 10) fill(0,255,0);
    else if (healthpx > 5) fill(255,255,0);
    else fill(255,0,0);
    rect(-10,20,healthpx,4);
    
    popMatrix();
  }
}
class Weapon {
  int type;
  float power = 0;
  int rate = 9999999;
  int rateCounter = 0;
  Damageable target;
  boolean targeting = false;
  boolean firing = false;
  
  float absoluteBearing;
  
  Weapon(int tempType) {
    type = tempType;
    
    switch(type) {
      case 0:
        power = 0.1f;
        rate = 1;
        break;
      case 1:
        power = 2;
        rate = 5;
        break;
      case 2:
        power = 4;
        rate = 7;
        break;
      case 3:
        power = 10;
        rate = 12;
        break;
      case 4:
        power = 30;
        rate = 20;
        break;
      case 5:
        power = 100;
        rate = 75;
        break;
      case 6:
        power = 100;
        rate = 30;
        break;
      case 7:
        power = 50;
        rate = 20;
        break;
      case 8:
        power = 250;
        rate = 30;
        break;
      case 9:
        power = 100;
        rate = 5;
        break;
    }
  }

  public void setAbsoluteBearing(float b) {
    absoluteBearing = b;
  }

  public void setTarget(Damageable tempTarget, boolean tempTargeting) {
    target = tempTarget;
    targeting = tempTargeting;
  }
  
  public void attemptFire() {
    if (targeting) {
      rateCounter = (rateCounter+1)%rate;
      if (rateCounter == 0) {
        firing = true;
        target.damage(power);
      } else {
        firing = false;
      }
    } else {
      firing = false;
    }
  }
  
  public void display() {
    
    // Switch to a matrix rotated about the gun angle
    pushMatrix();
    rotate(radians(absoluteBearing-180)); // -180 to translate from zero being up to being down
    stroke(0);
    
    switch(type) {
      case 0:
        line(0,0,0,5);
        ellipseMode(CENTER);
        ellipse(0,0,2,2);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          triangle(0,5,-1,10,1,10);
        }
        break;
      case 1:
        line(0,0,0,5);
        ellipseMode(CENTER);
        ellipse(0,0,5,5);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          triangle(0,5,-2,10,2,10);
        }
        break;
      case 2:
        strokeWeight(3);
        line(0,0,0,6);
        strokeWeight(1);
        ellipseMode(CENTER);
        ellipse(0,0,5,5);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          triangle(0,6,-2,12,2,12);
        }
        break;
      case 3:
        strokeWeight(5);
        line(0,0,0,7);
        strokeWeight(1);
        ellipseMode(CENTER);
        ellipse(0,0,7,7);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          triangle(0,7,-3,15,3,15);
        }
        break;
      case 4:
        strokeWeight(1);
        ellipseMode(CENTER);
        ellipse(0,0,8,8);
        rect(-2,-3,4,10);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          triangle(-2,7,2,7,0,15);
        }
        break;
      case 5:
        strokeWeight(1);
        ellipseMode(CENTER);
        ellipse(0,0,7,7);
        ellipse(0,2,4,4);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          ellipse(0,2,5,5);
        }
        break;
      case 6:
        strokeWeight(7);
        line(0,0,0,10);
        strokeWeight(2);
        rect(-4,-5,8,10);
        strokeWeight(1);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          triangle(0,10,-3,20,3,20);
        }
        break;
      case 7:
        strokeWeight(2);
        ellipseMode(CENTER);
        ellipse(0,0,8,8);
        rect(-4,-4,8,12);
        strokeWeight(1);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          triangle(-4,12,4,12,0,25);
        }
        break;
      case 8:
        strokeWeight(2);
        rect(-6,-6,12,12);
        ellipseMode(CENTER);
        ellipse(0,0,6,6);
        strokeWeight(1);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          ellipse(0,0,6,6);
        }
        break;
      case 9:
        strokeWeight(3);
        line(0,-5,0,15);
        strokeWeight(1);
        ellipseMode(CENTER);
        ellipse(0,0,7,7);
        if (firing) {
          stroke(255,0,0);
          fill(255,0,0);
          triangle(0,15,-1,30,1,30);
        }
        break;
    }
    
    popMatrix();
  }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "Sea_Battle" });
  }
}
