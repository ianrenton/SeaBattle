abstract class Damageable {
  
  float health;
  
  Ship lastDamageCause;
  
  void damage(float damage, Ship cause) {
    health -= damage;
    if (health < 0) health = 0;
    lastDamageCause = cause;
  }
  
  boolean isDead() {
    return (health <= 0);
  }
}