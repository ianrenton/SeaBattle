class Ship extends Damageable {
  boolean player;
  float xPos;
  float yPos;
  float maxSpeed;
  float speed = 0;
  float heading;
  float xGoal = -1;
  float yGoal = -1;
  boolean movingToGoal = false;
  boolean selected = false;
  ArrayList<Ship> targets;
  Base baseTarget;
  int targetShip = -1;
  boolean commandedToGo = false;
  Weapon weapon;
  Hull hull;
  Engine engine;
  Radar radar;
  float scariness; // Scariness for AI target-picking and fleet power display
  
  Ship(boolean tempPlayer, float tempXPos, float tempYPos, float tempheading, Hull tempHull, Weapon tempWeapon, Engine tempEngine, Radar tempRadar) {
    player = tempPlayer;
    xPos = tempXPos;
    yPos = tempYPos;
    heading = tempheading;
    weapon = tempWeapon;
    weapon.setOwner(this);
    hull = tempHull;
    engine = tempEngine;
    radar = tempRadar;
    
    maxSpeed = engine.thrust / hull.weight;
    health = hull.armour;
    calcScariness();
  }
  
  // AI routine for enemy ships
  void ai() {
    if (commandedToGo) {
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
      if (minDistance <= radar.range*3/5) {
        // If too close, back off
        int targetXPos = (int)(2*xPos - myShips.get(closestShip).xPos);
        int targetYPos = (int)(2*yPos - myShips.get(closestShip).yPos);
        setGoalPosition(targetXPos, targetYPos);
      } else if (minDistance <= radar.range*4/5) {
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
  }
  
  
  // Movement routine - enemy ships must run ai() first, player ships can just run this.
  void move() {
    // Movement Decision-making /////
    // Find closest ship position and closest island in case we need to move away from it
    Ship closestShip = null;
    Island closestIsland = null;
    float minDistanceToShip = 9999;
    float minDistanceToIsland = 9999;
    for (Ship s : myShips) {
      float dist = distance(xPos, yPos, s.xPos, s.yPos);
      // Dist>0.1 check to make sure we don't compare against the ship that's checking.
      if ((dist < minDistanceToShip) && (dist>0.1)) {
        closestShip = s;
        minDistanceToShip = dist;
      }
    }
    for (Ship s : enemyShips) {
      float dist = distance(xPos, yPos, s.xPos, s.yPos);
      // Dist>0.1 check to make sure we don't compare against the ship that's checking.
      if ((dist < minDistanceToShip) && (dist>0.1)) {
        closestShip = s;
        minDistanceToShip = dist;
      }
    }
    for (Island i : islands) {
      float dist = distance(xPos, yPos, i.xPos, i.yPos);
      if (dist < minDistanceToIsland) {
        closestIsland = i;
        minDistanceToIsland = dist;
      }
    }
    
    if ((distance(xPos, yPos, xGoal, yGoal) < 10+(maxSpeed/2)) || (movingToGoal == false)) {
      // Close enough or no target, so stop.  As turn rate is based on maxSpeed, accuracy
      // must be based on it too otherwise we risk continuous overshoot.
      speed = 0;
      movingToGoal = false;
    } else if (abs(heading - angle(xPos, yPos, xGoal, yGoal)) < 5+maxSpeed) {
      // Angle right, so set speed.  As turn rate is based on maxSpeed, accuracy
      // must be based on it too otherwise we risk continuous overshoot.
      speed = maxSpeed;
    } else {
      // Angle wrong, so turn.  Turning rate based on maxSpeed
      float diff = heading - angle(xPos, yPos, xGoal, yGoal);
      if (((diff > 0) && (diff <= 180)) || (diff < -180)) heading -= 1+(maxSpeed/2);
      else heading += 1+(maxSpeed/2);
      if (DEBUG) println(heading + "   " + angle(xPos, yPos, xGoal, yGoal) + "   " + diff);
    }
    
    // Prevent running into islands and ships
    try {
      if ((closestIsland != null) && (minDistanceToIsland < ISLAND_RADIUS + 10)) {
        // Move away to avoid intersecting
        float xDist = xPos - closestIsland.xPos;
        if ((xDist < 0) && (xDist > -ISLAND_RADIUS)) {
          xPos--;
        } else if ((xDist >= 0) && (xDist < ISLAND_RADIUS)) {
          xPos++;
        }
        float yDist = yPos - closestIsland.yPos;
        if ((yDist < 0) && (yDist > -ISLAND_RADIUS)) {
          yPos--;
        } else if ((yDist >= 0) && (yDist < ISLAND_RADIUS)) {
          yPos++;
        }
        // Back up and turn away from islands
        xPos = xPos - (speed * sin(radians(heading)));
        yPos = yPos + (speed * cos(radians(heading)));
        float relheading = (heading - angle(xPos, yPos, closestIsland.xPos, closestIsland.yPos));
        if (relheading < 0) {
          heading = heading - 45;
        } else {
          heading = heading + 45;
        }
      }
      else if ((closestShip != null) && (minDistanceToShip < 30)) {
        // Move away to avoid intersecting
        float xDist = xPos - closestShip.xPos;
        if ((xDist < 0) && (xDist > -10)) {
          xPos--;
        } else if ((xDist >= 0) && (xDist < 10)) {
          xPos++;
        }
        float yDist = yPos - closestShip.yPos;
        if ((yDist < 0) && (yDist > -10)) {
          yPos--;
        } else if ((yDist >= 0) && (yDist < 10)) {
          yPos++;
        }
        // Don't turn away from other ships as this will make stacking them up in the shipyard
        // (and combat) look weird.
      }
    } catch (IndexOutOfBoundsException ex) {}
    
    // Prevent runaway positive/negative headings
    if (heading >= 360) heading -= 360;
    if (heading < 0) heading += 360;
    
    // Actual movement /////
    
    xPos = xPos + (speed * sin(radians(heading)));
    yPos = yPos - (speed * cos(radians(heading)));
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
        weapon.setAbsoluteBearing(heading);
      }
    }
  }
  
  void commandToGo() {
    commandedToGo = true;
  }
  
  void setGoalPosition(float x, float y) {
    xGoal = x;
    yGoal = y;
    movingToGoal = true;
  }
  
  void damage(float damage, Ship cause) {
    super.damage(damage, cause);
    calcScariness();
  }
  
  // Calculate how scary this ship is to the AI.  TODO recalc on health loss
  void calcScariness() {
    scariness = (weapon.power / weapon.rate) * health;
  }
  
  void display() {
    // Switch to matrix relative to ship position and heading
    pushMatrix();
    translate(xPos,yPos);
    rotate(radians(heading-90)); // -90 to translate from zero being up to being right
    
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
    
    // Switch to matrix relative to ship position BUT NOT heading (for weapon & healthbar)
    pushMatrix();
    translate(xPos,yPos);
    weapon.attemptFire();
    weapon.display();
    popMatrix();
  }
  
  void displayDestinationMarker() {
    if ((movingToGoal) && (player)) {
      strokeWeight(5);
      stroke(127,127,255);
      line(xPos, yPos, xGoal, yGoal);
      strokeWeight(1);
    }
  }
  
  void displayHealthBar() {
    // Switch to matrix relative to ship position BUT NOT heading (for weapon & healthbar)
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
  
  // Return a description of the ship for recording purposes
  String describe() {
    String s = player ? "Blue" : "Red";
    s = s + " " + (hull.type+1) + "."  + (weapon.type+1) + "."  + (engine.type+1) + "."  + (radar.type+1);
    return s;
  }
}