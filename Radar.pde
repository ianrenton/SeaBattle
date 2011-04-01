class Radar {
  int type;
  float range = 0;
  
  Radar(int tempType) {
    type = tempType;
    
    switch(type) {
      case 0:
        range = 30;
        break;
      case 1:
        range = 35;
        break;
      case 2:
        range = 45;
        break;
      case 3:
        range = 60;
        break;
      case 4:
        range = 80;
        break;
      case 5:
        range = 105;
        break;
      case 6:
        range = 135;
        break;
      case 7:
        range = 170;
        break;
      case 8:
        range = 210;
        break;
      case 9:
        range = 280;
        break;
    }
  }
}
