// SEA BATTLE v0.5
// by Ian Renton
// Licenced under the terms of the BSD 2-clause licence
// See https://ianrenton.com/software/seabattle for more information!

boolean DEBUG = false;       // Add extra debug printlns
boolean INSTANT_BUY = false;  // All research and building is instant, for testing
String version = "0.5";

// Game speed settings
float RESEARCH_TIME = 1.5; // Higher numbers slow down research
float BUILD_TIME = 1; // Higher numbers slow down building

// AI Settings.
// Better AIs think faster, build bigger fleets, prioritise weapons and prioritise radars.
String[] aiLevelNames = new String[]{"Trivial", "Easy", "Moderate", "Hard","Insane"};
int[] aiLevelThinkTimes = new int[]{400,300,200,100,1};
int[] aiLevelFleetSize = new int[]{1,2,3,4,4};
int[] aiLevelPrioritiseWeapons = new int[]{0,0,1,2,4};
int[] aiLevelPrioritiseRadar = new int[]{0,0,0,1,3};
boolean[] aiLevelOnlyBuildBestWeapon = new boolean[]{false,false,false,false,true};

// Other variables
boolean playing = false;
boolean paused = false;
int aiLevel = 1;
String menuMessage = "";
BuildQueue myQueue = new BuildQueue(true);
BuildQueue enemyQueue = new BuildQueue(false);
Base myBase;
Base enemyBase;
ArrayList<Ship> myShips = new ArrayList<Ship>();
ArrayList<Ship> enemyShips = new ArrayList<Ship>();
ArrayList<Island> islands = new ArrayList<Island>();
ArrayList<DeathRecord> deathRecords = new ArrayList<DeathRecord>();
float titleFontSize = 28;
float buttonFontSize = 20;
float smallFontSize = 12;
boolean shipSelected = false;
float MY_BASE_X;
float MY_BASE_Y;
float ENEMY_BASE_X;
float ENEMY_BASE_Y;
int NUM_COMPONENTS = 4;
int NUM_CHOICES_PER_COMPONENT = 10;
int NUM_ISLANDS = 5;
int ISLAND_RADIUS = 20;
boolean mouseDragging = false;
int dragStartX;
int dragStartY;
ComponentButton[][] componentButtons = new ComponentButton[NUM_COMPONENTS][NUM_CHOICES_PER_COMPONENT];

// Run once at start to instantiate window.
void setup() {
  size(600,600);
  frameRate(30); // Note that all research and build times are in "frame ticks" so changing this actually changes game speed!
  initialSetup();
}

// Run every iteration.  Renders everything and performs the update ticks.
void draw() {
  drawUI();
  myQueue.updateComponentButtons();
  drawField();
  myBase.display();
  enemyBase.display();
  myQueue.displayResearchProgress();
  myQueue.displayBuildProgress();
  myQueue.displayQueueDots();
  if (!playing) {
    // Menu condition
    drawMenu(menuMessage);
  } else if (paused) {
    // Pause condition
    drawPause();
  } else if (!myBase.isDead() && !enemyBase.isDead()) {
    // Normal condition, play game
    
    // Process build/research queues
    myQueue.tick();
    enemyQueue.tick();
    
    // Move ships (includes firing)
    for (int i=0; i<enemyShips.size(); i++) enemyShips.get(i).ai();
    for (int i=0; i<enemyShips.size(); i++) enemyShips.get(i).move();
    for (int i=0; i<myShips.size(); i++) myShips.get(i).move();
    
    // Process deaths
    for (int i=0; i<enemyShips.size(); i++) {
      Ship e = enemyShips.get(i);
      if (e.isDead()) {
        deathRecords.add(new DeathRecord(e.lastDamageCause.describe() + " sunk " + e.describe(), true));
        enemyShips.remove(i);
      }
    }
    for (int i=0; i<myShips.size(); i++) {
      Ship m = myShips.get(i);
      if (m.isDead()) {
        deathRecords.add(new DeathRecord(m.lastDamageCause.describe() + " sunk " + m.describe(), false));
        myShips.remove(i);
      }
    }
    
    // Draw UI clutter
    for (int i=0; i<myShips.size(); i++) myShips.get(i).displayDestinationMarker();
    for (int i=0; i<enemyShips.size(); i++) enemyShips.get(i).displayHealthBar();
    for (int i=0; i<myShips.size(); i++) myShips.get(i).displayHealthBar();
    
    // Draw ships
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

// Setup run from the setup() method to create a game board that sits behind the menu, and
// run again on game start to reset things (e.g. if playing a second game in a row).
void initialSetup() {
  // Button generation
  for (int i=0; i<NUM_COMPONENTS; i++) {
    for (int j=0; j<NUM_CHOICES_PER_COMPONENT; j++) {
      componentButtons[i][j] = new ComponentButton(width, height, i, j, (j==0), (j==0));
    }
  }

  // Base generation
  myBase = new Base(true, width, height);
  enemyBase = new Base(false, width, height);
  MY_BASE_X = (width-200)/2-13;
  MY_BASE_Y = height-55;
  ENEMY_BASE_X = (width-200)/2+10;
  ENEMY_BASE_Y = 55;
}

// Run on starting the game. Regens islands, removes any ships etc. from previous plays.
void startGame() {
  initialSetup();
  playing = true;
  menuMessage = "";
  
  // Island generation
  islands.clear();
  for (int i=0; i<NUM_ISLANDS; i++)
  {
    float xPos = random(40, width-240);
    float yPos = random(100, height-100);
    islands.add(new Island(xPos,yPos));
  }
  
  // Clear ships and death records
  myShips.clear();
  enemyShips.clear();
  deathRecords.clear();
  
  // Queue reset
  myQueue = new BuildQueue(true);
  enemyQueue = new BuildQueue(false);
}

// Start multiple selection if mouse dragging
void mouseDragged() {
  if (!mouseDragging) {
    dragStartX = mouseX;
    dragStartY = mouseY;
    mouseDragging = true;
  }
}

// End multiple selection, selecting everything inside the box
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

// Deal with left and right clicks - both on the menu and on the game field.
void mouseClicked() {
  if (DEBUG) println("Click");
  if (!playing) {
    // At menu
    if ((mouseX > 100) && (mouseX < width-100) && (mouseY > height/2-100) && (mouseY < height/2-60)) {
      startGame();
    }
    for (int i=0; i<aiLevelNames.length; i++) {
      if ((mouseX > width/2+11) && (mouseX < width-179) && (mouseY > height/2+(i*30)-9) && (mouseY < height/2+(i*30)+11)) {
        aiLevel = i;
      }
    }
  } else {
    // Right-click = deselect, wherever it happens.
    if (mouseButton == RIGHT) {
      deselectShips();
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
  
        } else {
          // We're selecting a ship.
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

// P for Pause, Esc for deselect
void keyPressed() {
  if (key == 'p' || key == 'P') {
    if (playing) {
      paused = !paused;
    }
  }
  if (key == ESC) {
    key = 0; // Prevent the Escape being passed on, closing the app
    deselectShips();
  }
}

// Draw the main part of the UI (background, right-hand toolbar)
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
  textSize(smallFontSize);
  fill(255);
  
  // Build configuration headers
  text("Hull", width - 180, 47);
  text("Weapon", width - 148, 47);
  text("Engines", width - 98, 47);
  text("Radar", width - 48, 47);

  text("Build Queue", width - 190, height-68);
  text("Research", width - 190, height-93);
  
  // Deployed Fleet Power ("scariness")
  text("Fleet Power:", width-190, height-180);
  fill(color(127,127,200));
  int scariness = 0;
  for (int i=0; i<myShips.size(); i++) scariness += myShips.get(i).scariness;
  text(scariness, width-100, height-180);
  fill(color(200,127,127));
  scariness = 0;
  for (int i=0; i<enemyShips.size(); i++) scariness += enemyShips.get(i).scariness;
  text(scariness, width-60, height-180);
  
  // Latest sinkings
  int numSinkings = Math.min(3, deathRecords.size());
  for (int i=0; i<numSinkings; i++) {
    DeathRecord dr = deathRecords.get(deathRecords.size()-i-1);
    if (dr.good) {
      fill(color(127,127,200));
    } else {
      fill(color(200,127,127));
    }
    text(dr.text, width-190, height-160+(20*i));
  }

  fill(255);
  text("v"+version, width-40, 30);
  textSize(titleFontSize);
  text("Sea Battle", width-180, 30);
  textSize(buttonFontSize);
  text("BUILD", width-125, height-17);
}

// Draw the playing field
void drawField() {
  // Water
  stroke(255);
  fill(64,64,180);
  rectMode(CORNER);
  rect(3,3,width-203,height-6);

  // Land
  pushMatrix();
  translate(4,4);
  drawCoast();
  translate(width-204,height-7);
  rotate(radians(180));
  drawCoast();
  popMatrix();
  for (Island i : islands)
  {
    i.display();
  }
}

// Draw just the coast - as a separate function since we draw the same thing twice,
// only the second time is reversed.
void drawCoast() {
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

// Draw the New Game menu
void drawMenu(String notice) {
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
    textSize(titleFontSize);
    text(notice, width/2-70, height/2-132);
  }
  // Start Game box
  stroke(255);
  fill(0);
  rect(100,height/2-100,width-200,40);
  fill(255);
  textSize(titleFontSize);
  text("Click Here to Start Game", width/2-160, height/2-70);
  // Difficulty box
  fill(0);
  rect(130,height/2-20,width-280,165);
  fill(255);
  textSize(buttonFontSize);
  text("Difficulty:", width/2-150, height/2+8);
  for (int i=0; i<aiLevelNames.length; i++) {
    stroke(0);
    fill((aiLevel == i)?255:0);
    rect(width/2+11,height/2+(i*30)-11,width/2-190,24);
    fill((aiLevel == i)?0:255);
    text(aiLevelNames[i], width/2+20, height/2+8+(i*30));
  }
}

// Draw the Paused box
void drawPause() {
  rectMode(CORNER);
  // BG Alpha
  fill(0,0,0,128);
  rect(0,0,width,height);
  // Notice
  stroke(255);
  fill(0);
  rect(100,height/2-20,width-200,40);
  fill(255);
  textSize(titleFontSize);
  text("Paused", width/2-50, height/2+8);
}

// Deselect any selected ships - as a separate function, because
// this is called on right-click and pressing Escape
void deselectShips() {
  for (int i=0; i<myShips.size(); i++) {
    if (myShips.get(i).selected == true) {
      myShips.get(i).selected = false;
    }
  }
  shipSelected = false;
}

// Utility function - calc distance between two points
float distance(float x1, float y1, float x2, float y2) {
  return sqrt(sq(x2-x1) + sq(y2-y1));
}

// Utility function - calc angle of Y from X
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
        if ((abs(myShips.get(i).xPos - (MY_BASE_X + jump)) < 10) && (abs(myShips.get(i).yPos - MY_BASE_Y) < 10)) {
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
        if ((abs(enemyShips.get(i).xPos - (ENEMY_BASE_X + jump)) < 10) && (abs(enemyShips.get(i).yPos - ENEMY_BASE_Y) < 10)) {
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