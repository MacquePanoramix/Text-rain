// |TextDrop instances|

ArrayList<TextDrop> drops = new ArrayList<TextDrop>(); 

// |Explosion instances|

ArrayList<Explosion> explosions = new ArrayList<Explosion>(); 

// |Text content arrays|

String[] lines;      // Lines from the text file
String[] sentences;  // Sentences from the text
String[] words;      // Words from the text
char[] letters;      // Letters from the text

// |Font properties|

PFont font;

// |Mode and settings|

int mode = 0;                   // 0: Sentence, 1: Word, 2: Letter
boolean collisionEnabled = false; // Collision detection toggle
boolean explosionEnabled = false; // Explosion effect toggle
int numDrops;                    // Current number of text drops
int maxDrops = 200;              // Maximum number of drops
int minDrops = 1;                // Minimum number of drops

// |Explosion animation variables|

PImage[] explosionSheets = new PImage[5];                // Explosion sprite sheets
int[] numExplosionFrames = {64, 64, 64, 64, 12};         // Frames in each explosion animation
boolean[] isGrid = {true, true, true, true, false};      // Sprite sheet formats (grid or not). Basically if it's a 8x8 square or a 12x1 row
int explosionType = 0;                                   // Current explosion type (0-5)

// |Frames to preload|

ArrayList<PImage[]> explosionFrames = new ArrayList<PImage[]>();

// |State variable|

int state = 0; // 0: Title Screen, 1: Text Drop Mode

// |Title text instance|

TextTitle titleText;

void setup() {

  // |Window setup|

  size(1600, 900, P2D); // Using P2D to improve screen rendering performance of the explosions (Before it was lagging too much with the explosions with more frames)
  background(0);

  // |Font setup|

  font = createFont("Arial", 16);
  textFont(font);

  // |Load text content|

  lines = loadStrings("text.txt");
  String text = join(lines, " ");
  String fullText = text; // Entire text

  // |Separate text into sentences, words, and letters|

  sentences = splitTokens(text, ".!?");
  words = splitTokens(text, " \n\r\t");
  letters = text.toCharArray();

  // |Load and preprocess explosion sprite sheets| Done to improve performance so that the explosion frames don't have to be processed each time

  for (int i = 0; i < explosionSheets.length; i++) {

    // |Load explosion sprite sheet|

    explosionSheets[i] = loadImage("explosion " + (i+1) + ".png");

    // |Extract frames from sprite sheet|

    PImage[] frames = extractFrames(explosionSheets[i], numExplosionFrames[i], isGrid[i]);

    // |Add frames to preloaded frames list|

    explosionFrames.add(frames);
  }

  // |Initialize drops based on current mode|

  setNumDropsByMode();
  initializeDrops();

  // |Initialize title text|

  titleText = new TextTitle(fullText);
}

void draw() {

  // |Fading trail effect| A almost completely transparent black rectangle covering the screen

  fill(0, 50);
  rect(0, 0, width, height);

  // |Title Screen mode|

  if (state == 0) {
    
    // |Update and display title text|

    titleText.update();
    titleText.display();
    
  // |Text Drop Mode|

  } else if (state == 1) {

    // |Update all TextDrops|

    for (TextDrop drop : drops) {
      drop.update();
    }

    // |Collision handling|

    if (collisionEnabled) {
      handleCollisions();
    }

    // |Display all TextDrops| Done after Collision for more in sync display of the text drops.

    for (TextDrop drop : drops) {
      drop.display();
    }

    // |Update and display explosions|

    for (int i = explosions.size() - 1; i >= 0; i--) {
      Explosion explosion = explosions.get(i);
      explosion.update();
      explosion.display();

      // |Remove explosion if animation finished|

      if (explosion.isFinished()) {
        explosions.remove(i);
      }
    }

    // |Display current status|

    displayStatus();
  }
}

void mousePressed() {

  // |Left mouse button: Cycle through modes|

  if (mouseButton == LEFT && state == 1) {
    mode = (mode + 1) % 3; // Cycle through modes 0, 1, 2 (Setences, Words and Letters)
    setNumDropsByMode();
    initializeDrops();

  // |Right mouse button: Toggle collision detection|

  } else if (mouseButton == RIGHT && state == 1) {
    collisionEnabled = !collisionEnabled;
  }
}

void keyPressed() {

  // |Enter key: Toggle between title screen and text drop mode|

  if (key == ENTER || key == RETURN) {
    state = (state + 1) % 2; // Toggle between mode 0 and 1 (Tittle screen and Drop text)

  } else if (state == 1) { // Only functional in text drop mode

    // |Spacebar: Toggle explosion effect|

    if (key == ' ') {
      explosionEnabled = !explosionEnabled;

    // |E key: Cycle through explosion types|

    } else if (key == 'e' || key == 'E') {
      explosionType = (explosionType + 1) % 6; // Cycle through different explosions (0-5)
    }
  }
}

void mouseWheel(MouseEvent event) {

  // |Adjust number of drops with mouse wheel|

  float e = event.getCount();
  adjustNumDrops((int)e);
  
}

void adjustNumDrops(int change) {

  // |Adjust the number of drops within the permited limits|

  numDrops -= change;
  numDrops = constrain(numDrops, minDrops, maxDrops);

  // |Update drops list|

  if (drops.size() < numDrops) { //If too few drops

    // |Add new drops until enough|

    int dropsToAdd = numDrops - drops.size();
    for (int i = 0; i < dropsToAdd; i++) {
      String content = getRandomContent();
      drops.add(new TextDrop(content));
    }

  } else if (drops.size() > numDrops) { //If too many drops

    // |Remove excess drops until enough|

    int dropsToRemove = drops.size() - numDrops;
    for (int i = 0; i < dropsToRemove; i++) {
      drops.remove(drops.size() - 1); // Remove the drops from the end of the list
    }
  }
}

void setNumDropsByMode() {

  // |Set number of drops based on current mode|

  switch (mode) {
    case 0:
      numDrops = 20; // Sentence Mode
      break;
    case 1:
      numDrops = 50; // Word Mode
      break;
    case 2:
      numDrops = 100; // Letter Mode
      break;
    default:
      numDrops = 50;
  }

  // |Make sure the number of drops is still within the limits| // Just for precaution

  numDrops = constrain(numDrops, minDrops, maxDrops);
}

void initializeDrops() {

  // |Clear existing drops|

  drops.clear();

  // |Create new drops|

  for (int i = 0; i < numDrops; i++) {
    String content = getRandomContent();
    drops.add(new TextDrop(content));
  }
}

String getRandomContent() {

  // |Retrieve random content from the text based on mode|

  String content = "";
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
  return content;
}

void handleCollisions() {

  // |Loops to check for collision between each drop in relation to each other|

  for (int i = 0; i < drops.size(); i++) {
    TextDrop dropA = drops.get(i);
    for (int j = i + 1; j < drops.size(); j++) {
      TextDrop dropB = drops.get(j);

      // |Check for collision between drops|

      if (dropA.checkCollision(dropB)) {

        // |Add explosion effect if enabled|

        if (explosionEnabled) {

          // |Calculate collision point to be center of explosion|

          float collisionX = (dropA.x + dropB.x) / 2;
          float collisionY = (dropA.y + dropB.y) / 2;
          int eType = explosionType;
          if (explosionType == 5) { // Random explosion from all 5 different types available (Only in explosion mode 5/Random mode)
            eType = int(random(5));
          }

          // |Create new explosion|

          explosions.add(new Explosion(collisionX, collisionY, eType));
        }

        // |Resolve collision between drops|

        dropA.resolveCollision(dropB);
      }
    }
  }
}

void displayStatus() {

  // |Display current mode and settings|

  fill(255);
  textSize(16);
  textAlign(CENTER);

  String modeText = "";
  switch (mode) {
    case 0:
      modeText = "Sentence Mode";
      break;
    case 1:
      modeText = "Word Mode";
      break;
    case 2:
      modeText = "Letter Mode";
      break;
  }

  String collisionText = collisionEnabled ? "Collision: ON" : "Collision: OFF";
  String explosionText = explosionEnabled ? "Explosion: ON" : "Explosion: OFF";
  String explosionTypeText = "";

  if (explosionEnabled) {
    if (explosionType == 5) {
      explosionTypeText = "Type: Random";
    } else {
      explosionTypeText = "Type: " + (explosionType + 1);
    }
  }

  // |Render status text|

  text(modeText + " | " + collisionText + " | " + explosionText + " " + explosionTypeText + " | Drops: " + numDrops, width / 2, 20);
}

// |Function to extract frames from sprite sheets|

PImage[] extractFrames(PImage spriteSheet, int totalFrames, boolean gridFormat) {

  // |Initialize frames array|

  PImage[] frames = new PImage[totalFrames];

  if (gridFormat) { 

    // |Calculate grid properties| To be adjusted later on if I get animation sprite sheets in different grid formats

    int columns = 8;
    int rows = 8;
    int frameWidth = spriteSheet.width / columns; // Divide all frames vertically
    int frameHeight = spriteSheet.height / rows; // Divide all frames horizontally
    int frameIndex = 0;

    // |Extract frames from the grid|

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (frameIndex < totalFrames) {
          frames[frameIndex] = spriteSheet.get(col * frameWidth, row * frameHeight, frameWidth, frameHeight); // Get pixels correpontdent to a indexed frame image
          frameIndex++;
        }
      }
    }

  } else {

    // |Extract frames from horizontal sprite sheet|

    int frameWidth = spriteSheet.width / totalFrames;
    int frameHeight = spriteSheet.height;

    for (int i = 0; i < totalFrames; i++) {
      frames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, frameHeight); // Get pixels correpontdent to a indexed frame image
    }
  }

  return frames;
}
