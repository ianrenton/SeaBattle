class BuildQueue {
  boolean player;
  ArrayList<Ship> queue = new ArrayList<Ship>();
  int aiBuildTicker;
  int aiBuildNumber;
  int spawnTicker;
  int spawnTickerStartedFrom;
  int maxHull;
  int maxWeapon;
  int maxEngine;
  int maxRadar;
  int selectedHull;
  int selectedWeapon;
  int selectedEngine;
  int selectedRadar;
  int researchingComponent;
  boolean researching;
  int researchTicker;
  int researchTickerStartedFrom;


  BuildQueue(boolean tempPlayer) {
    player = tempPlayer;
    reset();
  }
  
  void reset() {
    queue.clear();
    aiBuildTicker = 0;
    aiBuildNumber = 0;
    spawnTicker = 0;
    spawnTickerStartedFrom = 0;
    maxHull = 0;
    maxWeapon = 0;
    maxEngine = 0;
    maxRadar = 0;
    selectedHull = 0;
    selectedWeapon = 0;
    selectedEngine = 0;
    selectedRadar = 0;
    researchingComponent = -1;
    researching = false;
    researchTicker = 0;
    researchTickerStartedFrom = 0; 
  }

  void tick() {
    if (!player) {
      // Enemy build & research automation
      aiBuildTicker++;
      
      // Everything has a "thinking" delay
      if (aiBuildTicker%(aiLevelThinkTimes[aiLevel]) == 0) {
        
        // Only build when queue is empty, so we're always building the latest stuff
        if (queue.size() == 0) {
          // Pick what to build.
          // Hull: random
          // Weapon: random from the top half of what's researched, unless AI level
          // is harsh and only picks the best
          // Engine/Radar: always max.
          selectedHull = int(floor(random(maxHull+1)));
          if (aiLevelOnlyBuildBestWeapon[aiLevel]) {
            selectedWeapon = maxWeapon;
          } else {
            selectedWeapon = int(floor(random((maxWeapon+1)/2) + ((maxWeapon+1)/2)));
          }
          selectedEngine = maxEngine;
          selectedRadar = maxRadar;
          build(selectedHull, selectedWeapon, selectedEngine, selectedRadar);
          
          // Command ships to go once a fleet is built up
          aiBuildNumber++;
          if (aiBuildNumber % aiLevelFleetSize[aiLevel] == 0) {
            for (int i=0; i<enemyShips.size(); i++) enemyShips.get(i).commandToGo();
          }
        }
        
        // Only research when able
        if (!researching) {
          int[] maxLevels = { maxHull, maxWeapon-aiLevelPrioritiseWeapons[aiLevel], maxEngine, maxRadar-aiLevelPrioritiseRadar[aiLevel] };
          int minMaxLevel = min(maxLevels);
          if (maxHull == minMaxLevel) setResearchComponent(0, minMaxLevel+1);
          else if (maxWeapon-aiLevelPrioritiseWeapons[aiLevel] == minMaxLevel) setResearchComponent(1, minMaxLevel+1+aiLevelPrioritiseWeapons[aiLevel]);
          else if (maxEngine == minMaxLevel) setResearchComponent(2, minMaxLevel+1);
          else setResearchComponent(3, minMaxLevel+1+aiLevelPrioritiseRadar[aiLevel]);
        }
      }
    }

    // Count down spawn ticker
    if (queue.size() > 0) {
      spawnTicker--;
      // If zero (or "instant buy" debug flag is set), we spawn the ship
      if (spawnTicker <= 0 || INSTANT_BUY) {
        spawn(player, queue.get(0));
        queue.remove(0);
        // If there's still something in the queue, reset the ticker.  Otherwise, leave it and
        // set the "started from" to zero.
        if (queue.size() > 0) {
          spawnTicker = queue.get(0).getBuildTime();
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
      // If zero (or "instant buy" debug flag is set), we complete research
      if (researchTicker <= 0 || INSTANT_BUY) {
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
  void build() {
    build(selectedHull, selectedWeapon, selectedEngine, selectedRadar);
  }

  // Adds an item to the queue
  void build(int hull, int weapon, int engine, int radar) {
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
        spawnTicker = queue.get(0).getBuildTime();
        spawnTickerStartedFrom = spawnTicker;
      }
    }
  }


  // Selects a component option for research
  void setResearchComponent(int component, int option) {
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
  void setSelectedComponent(int component, int option) {
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
  void updateComponentButtons() {

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
  void displayBuildProgress() {
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
  void displayResearchProgress() {
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
  void displayQueueDots() {
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