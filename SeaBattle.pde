boolean DEBUG = false;
String version = "0.2";

// Game speed settings
float RESEARCH_TIME = 1.5; // Higher numbers slow down research

// AI Settings.
// Better AIs think faster, build bigger fleets, prioritise weapons and prioritise radars.
String[] aiLevelNames = new String[]{"Trivial", "Easy", "Moderate", "Hard","Insane"};
int[] aiLevelThinkTimes = new int[]{400,300,200,100,1};
int[] aiLevelFleetSize = new int[]{1,2,3,4,4};
int[] aiLevelPrioritiseWeapons = new int[]{0,0,1,2,4};
int[] aiLevelPrioritiseRadar = new int[]{0,0,0,1,3};
boolean[] aiLevelOnlyBuildBestWeapon = new boolean[]{false,false,false,false,true};

boolean playing = false;
int aiLevel = 1;
String menuMessage = "";
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

void setup() {
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

void draw() {
  if (!playing) {
    // Menu condition
    drawMenu(menuMessage);
  } else if (!myBase.isDead() && !enemyBase.isDead()) {
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
    menuMessage = "You Lose";
    playing = false;
  } 
  else {
    menuMessage = "You Win!";
    playing = false;
  }
}

void mouseDragged() {
  if (!mouseDragging) {
    dragStartX = mouseX;
    dragStartY = mouseY;
    mouseDragging = true;
  }
}

void mouseReleased() {
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

void mouseClicked() {
  if (DEBUG) println("Click");
  if (!playing) {
    // At menu
    if ((mouseX > 100) && (mouseX < width-100) && (mouseY > height/2-100) && (mouseY < height/2-60)) {
      playing = true;
      menuMessage = "";
    }
    for (int i=0; i<aiLevelNames.length; i++) {
      if ((mouseX > width/2+11) && (mouseX < width-179) && (mouseY > height/2+(i*30)-9) && (mouseY < height/2+(i*30)+11)) {
        aiLevel = i;
      }
    }
  } else {
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
}

void drawUI() {
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
  textFont(smallFont);
  fill(255);
  
  // Build configuration headers
  text("Hull", width - 180, 60);
  text("Weapon", width - 148, 60);
  text("Engines", width - 98, 60);
  text("Radar", width - 48, 60);

  text("Build", width - 190, height-68);
  text("Research", width - 190, height-93);

  text("v"+version, width-40, 40);
  textFont(titleFont);
  text("Sea Battle", width-187, 25);
  textFont(buttonFont);
  text("BUILD", width-128, height-19);
}

void drawField() {
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

void drawLand() {
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

void drawMenu(String notice) {
  drawUI();
  myQueue.updateComponentButtons();
  drawField();
  myBase.display();
  enemyBase.display();
  rectMode(CORNER);
  // BG Alpha
  fill(0,0,0,128);
  rect(0,0,width,height);
  // Notice
  if (!notice.equals("")) {
    stroke(255);
    fill(0);
    rect(100,height/2-160,width-200,40);
    fill(255);
    textFont(titleFont);
    text(notice, width/2-70, height/2-132);
  }
  // Start Game box
  stroke(255);
  fill(0);
  rect(100,height/2-100,width-200,40);
  fill(255);
  textFont(titleFont);
  text("Start Game", width/2-90, height/2-72);
  // Difficulty box
  fill(0);
  rect(130,height/2-20,width-280,165);
  fill(255);
  textFont(buttonFont);
  text("Difficulty:", width/2-150, height/2+8);
  for (int i=0; i<aiLevelNames.length; i++) {
    stroke(0);
    fill((aiLevel == i)?255:0);
    rect(width/2+11,height/2+(i*30)-9,width/2-190,20);
    fill((aiLevel == i)?0:255);
    text(aiLevelNames[i], width/2+20, height/2+8+(i*30));
  }
}

float distance(float x1, float y1, float x2, float y2) {
  return sqrt(sq(x2-x1) + sq(y2-y1));
}

float angle(float x1, float y1, float x2, float y2) {
  float a = atan((x2-x1)/(y1-y2));
  if (y2 > y1) a = a + PI;
  if (a >= TWO_PI) a -= TWO_PI;
  if (a < 0) a += TWO_PI;
  return degrees(a);
}

// Spawn a ship on the map in the next available slot.
void spawn(boolean player, Ship ship) {
  if (player) {
    // Find a free slot for the ship
    boolean found;
    int jump = 0;
    do {
      found = false;
      for (int i=0; i<myShips.size(); i++) {
        if (DEBUG) println(myShips.get(i).xPos + "  " + MY_BASE_X + jump);
        if ((myShips.get(i).xPos == MY_BASE_X + jump) && (myShips.get(i).yPos == MY_BASE_Y)) {
          found = true;
        }
      }
      jump += 20;
    } 
    while (found && (jump < 200));
    ship.xPos = MY_BASE_X + jump - 20;

    myShips.add(ship);
  } 
  else {
    // Find a free slot for the ship
    boolean found;
    int jump = 0;
    do {
      found = false;
      for (int i=0; i<enemyShips.size(); i++) {
          if (DEBUG) println(enemyShips.get(i).xPos + "  " + (ENEMY_BASE_X - jump));
        if ((enemyShips.get(i).xPos == ENEMY_BASE_X - jump) && (enemyShips.get(i).yPos == ENEMY_BASE_Y)) {
          found = true;
        }
      }
      jump += 20;
    } 
    while (found && (jump < 200));
    ship.xPos = ENEMY_BASE_X - jump + 20;
    
    enemyShips.add(ship);
  }
}

