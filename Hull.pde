class Hull {
  int type;
  float armour = 0;
  int buildTime = 9999999;
  float weight = 9999999;
  
  Hull(int tempType) {
    type = tempType;
    
    switch(type) {
      case 0:
        armour = 40;
        buildTime = 120;
        weight = 1000;
        break;
      case 1:
        armour = 60;
        buildTime = 150;
        weight = 1200;
        break;
      case 2:
        armour = 100;
        buildTime = 180;
        weight = 1500;
        break;
      case 3:
        armour = 200;
        buildTime = 250;
        weight = 1700;
        break;
      case 4:
        armour = 400;
        buildTime = 400;
        weight = 3000;
        break;
      case 5:
        armour = 500;
        buildTime = 300;
        weight = 3500;
        break;
      case 6:
        armour = 800;
        buildTime = 550;
        weight = 5000;
        break;
      case 7:
        armour = 1000;
        buildTime = 700;
        weight = 6000;
        break;
      case 8:
        armour = 1600;
        buildTime = 800;
        weight = 8000;
        break;
      case 9:
        armour = 2500;
        buildTime = 1000;
        weight = 10000;
        break;
    }
  }

  
  void display() {
    
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
        vertex(20,0);
        vertex(5,6);
        vertex(-20,5);
        vertex(-20,-5);
        vertex(5,-6);
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
        vertex(25,0);
        vertex(6,7);
        vertex(-25,6);
        vertex(-25,-6);
        vertex(6,-7);
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