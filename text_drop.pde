class TextDrop {
  float x;
  float y;
  float speedY;
  float speedX;
  String content;
  float contentWidth;
  float contentHeight;
  boolean spin;        // Whether this content spins
  float angle;         // Current rotation angle
  float rotationSpeed; // Rotation speed and direction
  float textSize;      // Randomized text size
  color currentColor;  // Current color of the content
  int colorChangeTimer; // Timer for color change effect
  
  TextDrop(String c) {
    content = c;
    // Randomize text size between 12 and 24
    textSize = random(12, 24);
    textFont(font, textSize); // Set font and size
    contentWidth = textWidth(content);
    contentHeight = textAscent() + textDescent();
    x = random(width - contentWidth);
    y = random(-500, -50);
    speedY = random(2, 5);
    speedX = random(-1, 1); // Horizontal speed (wind effect)
    // Decide randomly whether this content spins
    spin = random(1) < 0.5; // 50% chance to spin
    angle = 0;
    // Randomize rotation speed between -0.1 and 0.1
    rotationSpeed = random(-0.05, 0.05);
    // Set initial color to green
    currentColor = color(0, 255, 0);
    // Initialize color change timer
    colorChangeTimer = 0;
  }
  
  void update() {
    y += speedY;
    x += speedX;
    
    // Keep the content within horizontal bounds
    if (x < -contentWidth) {
      x = width;
    } else if (x > width) {
      x = -contentWidth;
    }
    
    if (spin) {
      angle += rotationSpeed;
    }
    
    // Chance to start a color change
    if (colorChangeTimer == 0 && random(1) < 0.01) { // 1% chance each frame
      currentColor = color(random(255), random(255), random(255));
      colorChangeTimer = int(random(10, 30)); // Color change lasts for 10-30 frames
    } else if (colorChangeTimer > 0) {
      colorChangeTimer--;
      if (colorChangeTimer == 0) {
        currentColor = color(0, 255, 0); // Revert back to green
      }
    }
    
    if (y > height) {
      reset();
    }
  }
  
  void display() {
    pushMatrix();
    translate(x + contentWidth / 2, y + contentHeight / 2);
    if (spin) {
      rotate(angle);
    }
    fill(currentColor);
    textAlign(CENTER, CENTER);
    textFont(font, textSize);
    text(content, 0, 0);
    popMatrix();
  }
  
  void reset() {
    y = random(-500, -50);
    // Pick a new content based on the mode
    switch (mode) {
      case 0: // Sentence Mode
        content = trim(sentences[int(random(sentences.length))]) + ".";
        break;
      case 1: // Word Mode
        content = words[int(random(words.length))];
        break;
      case 2: // Letter Mode
        content = str(letters[int(random(letters.length))]);
        break;
    }
    // Randomize text size
    textSize = random(12, 24);
    textFont(font, textSize);
    contentWidth = textWidth(content);
    contentHeight = textAscent() + textDescent();
    x = random(width - contentWidth);
    speedY = random(2, 5);
    speedX = random(-1, 1);
    spin = random(1) < 0.5; // Decide again whether it spins
    angle = 0;
    rotationSpeed = random(-0.05, 0.05);
    currentColor = color(0, 255, 0);
    colorChangeTimer = 0;
  }
  
  boolean checkCollision(TextDrop other) {
    // Get bounding boxes for this content and the other content
    float thisLeft = x;
    float thisRight = x + contentWidth;
    float thisTop = y;
    float thisBottom = y + contentHeight;
    
    float otherLeft = other.x;
    float otherRight = other.x + other.contentWidth;
    float otherTop = other.y;
    float otherBottom = other.y + other.contentHeight;
    
    // Check for overlap
    return !(thisRight < otherLeft || thisLeft > otherRight || thisBottom < otherTop || thisTop > otherBottom);
  }
  
  void resolveCollision(TextDrop other) {
    // Simple collision response: exchange velocities
    float tempSpeedX = speedX;
    float tempSpeedY = speedY;
    
    speedX = other.speedX;
    speedY = other.speedY;
    
    other.speedX = tempSpeedX;
    other.speedY = tempSpeedY;
    
    // Adjust positions to prevent sticking
    while (checkCollision(other)) {
      x += speedX;
      y += speedY;
      other.x += other.speedX;
      other.y += other.speedY;
    }
  }
}
