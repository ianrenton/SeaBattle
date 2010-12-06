class Base extends Damageable {
  boolean player;
  float maxHealth = 100000;
  int xPos;
  int yPos;
  float orientation;
  
  Base(boolean tempPlayer, int winWidth, int winHeight) {
    player = tempPlayer;
    health = maxHealth;
    
    if (!player) {
      xPos = ((winWidth-204)/2)+20;
      yPos = 36;
      orientation = 0;
    } else {
      xPos = ((winWidth-204)/2)-20;
      yPos = winHeight-36;
      orientation = 180;
    }
  }
  
  boolean isDead() {
    return (health <= 0);
  }
  
  void display() {
    // Switch to matrix relative to base position and orientation to draw it
    pushMatrix();
    translate(xPos,yPos);
    rotate(radians(orientation));
    stroke(100);
    fill(200);
    beginShape();
    vertex(-40,-30);
    vertex(10,-30);
    vertex(10,30);
    vertex(0,30);
    vertex(0,0);
    vertex(-40,0);
    endShape(CLOSE);    
    popMatrix();
    
    // Switch to matrix relative to position only to draw the health bar
    pushMatrix();
    translate(xPos,yPos);
    displayHealthBar();  
    popMatrix();
 }
  
  void displayHealthBar() {
    int xOffset = -40;
    int yOffset = -30;
    if (player) {
      xOffset = -10;
      yOffset = 25;
    }
    int healthpx = (int)(health / maxHealth * 49);
    stroke(0);
    fill(0);
    rect(xOffset, yOffset, 50, 5);
    noStroke();
    if (healthpx > 10) fill(0,255,0);
    else if (healthpx > 5) fill(255,255,0);
    else fill(255,0,0);
    rect(xOffset+1,yOffset+1,healthpx,4);
  }
}
