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
        power = 0.1;
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

  void setAbsoluteBearing(float b) {
    absoluteBearing = b;
  }

  void setTarget(Damageable tempTarget, boolean tempTargeting) {
    target = tempTarget;
    targeting = tempTargeting;
  }
  
  void attemptFire() {
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
  
  void display() {
    
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
