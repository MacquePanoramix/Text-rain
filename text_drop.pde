// |TextDrop class|

class TextDrop extends TextBase { 

  // |Position properties|

  float x; // Position
  float y; // Position
  float speedY;
  float speedX;

  // |Content properties|

  float contentWidth;
  float contentHeight;

  // |Spin properties|

  boolean spin;        // Whether the text should be spinning
  float angle;         // Current rotation angle
  float rotationSpeed; // Positive for clockwise, negative for counter clockwise.

  // |Text properties|

  float textSize;
  int colorChangeTimer; // Timer for color change effect

  TextDrop(String c) {

    // |Content properties|

    content = c; // Text content
    textFont(font, textSize);
    contentWidth = textWidth(content);
    contentHeight = textAscent() + textDescent(); // Text height calculation

    // |Randomize all properties|

    reset();
  }

  void update() {

    // |Position|

    y += speedY;
    x += speedX;

    // |Keep the text within the horizontal bounds|

    if (x < -contentWidth) {
      x = width;
    } else if (x > width) {
      x = -contentWidth;
    }

    // |Spin update|

    if (spin) {
      angle += rotationSpeed;
    }

    // |Color change chance update (color lootbox)|

    if (colorChangeTimer == 0 && random(1) < 0.01) { // 1% chance each frame
      currentColor = color(random(255), random(255), random(255));
      colorChangeTimer = int(random(10, 30)); // Color change lasts for 10-30 frames
    } else if (colorChangeTimer > 0) {
      colorChangeTimer--;
      if (colorChangeTimer == 0) {
        currentColor = color(0, 255, 0); // Revert back to green
      }
    }

    // |Respawn when hit bottom|

    if (y > height) {
      reset();
    }
  }

  void display() {

    // |Save coordinates|

    pushMatrix();

    // |Move text down/left/right|

    translate(x + contentWidth / 2, y + contentHeight / 2);

    // |Rotate text|

    if (spin) {
      rotate(angle);
    }

    // |Text settings|

    fill(currentColor);
    textAlign(CENTER, CENTER);
    textFont(font, textSize);
    text(content, 0, 0);

    // |Load saved coordinates|

    popMatrix();
  }

  void reset() {

    // |Text properties|

    textSize = random(16, 26);
    textFont(font, textSize);

    // |Position properties|

    y = random(-500, -50);
    x = random(width - contentWidth); // Ensure text starts within the screen
    speedY = random(1, 3);  // Fall speed
    speedX = random(-1, 1); // Wind effect

    // |Spin properties|

    spin = random(1) < 0.2; // 20% chance to spin
    angle = 0;
    rotationSpeed = random(-0.02, 0.02);

    // |Color properties|

    currentColor = color(0, 255, 0); // Initial color is green
    colorChangeTimer = 0;

    // |Content properties|

    content = getRandomContent(); // New random content
    contentWidth = textWidth(content);
    contentHeight = textAscent() + textDescent();
  }

  boolean checkCollision(TextDrop other) {

    // |Collision box coordinates for this text|

    float thisLeft = x;
    float thisRight = x + contentWidth;
    float thisTop = y;
    float thisBottom = y + contentHeight;

    // |Collision box coordinates for other text|

    float otherLeft = other.x;
    float otherRight = other.x + other.contentWidth;
    float otherTop = other.y;
    float otherBottom = other.y + other.contentHeight;

    // |Overlap check|

    return !(thisRight < otherLeft || thisLeft > otherRight || thisBottom < otherTop || thisTop > otherBottom);
  }

  void resolveCollision(TextDrop other) {

    // |Simple collision resolution: exchanging speeds|

    // |Temporary speeds|

    float tempSpeedX = speedX;
    float tempSpeedY = speedY;

    // |Exchange speeds|

    speedX = other.speedX;
    speedY = other.speedY;

    other.speedX = tempSpeedX;
    other.speedY = tempSpeedY;

    // |Anti-sticking measure|

    while (checkCollision(other)) {
      x += speedX;
      y += speedY;
      other.x += other.speedX;
      other.y += other.speedY;
    }
  }
}
