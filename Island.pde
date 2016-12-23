class Island {
  float xPos;
  float yPos;
  
  Island(float tempXPos, float tempYPos) {
    xPos = tempXPos;
    yPos = tempYPos;
  }
  
  void display() {    
    // Display island shape
    noStroke();
    fill(30,200,30);
    ellipseMode(CENTER);
    ellipse(xPos,yPos,ISLAND_RADIUS*2,ISLAND_RADIUS*2);
  }
}