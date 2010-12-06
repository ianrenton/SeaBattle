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
