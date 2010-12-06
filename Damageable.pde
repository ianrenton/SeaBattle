abstract class Damageable {
  
  float health;
  
  void damage(float damage) {
    health -= damage;
    if (health < 0) health = 0;
  }
  
}
