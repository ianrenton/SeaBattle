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
