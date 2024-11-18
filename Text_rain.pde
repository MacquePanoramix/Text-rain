//Main Page

ArrayList<TextDrop> drops = new ArrayList<TextDrop>(); 
// this is where we store all the text drops (like sentences, words, or letters)

// variables for handling text and its diff modes
String[] lines; // full lines from the file
String[] sentences; // chopped up sentences
String[] words;     // all the individual words
char[] letters;     // all the lil letters
PFont font;         // font for the text
int mode = 0;       // 0 = sentences, 1 = words, 2 = letters
boolean collisionEnabled = false; // toggle to turn collision on/off
int numDrops;       // how many text drops we got rn
int maxDrops = 200; // cap the max drops allowed
int minDrops = 1;   // and the minimum too, no 0 drops!

void setup() {
  size(600, 400);  // setting up the canvas size
  background(0);   // black background, clean slate
  
  // loading the font, default one or custom if u got it
  font = createFont("Arial", 16);
  textFont(font);
  
  // grab the text from the file and process it
  lines = loadStrings("text.txt"); // load each line
  String text = join(lines, " ");  // merge all lines into one
  
  // breaking text into smaller bits
  sentences = splitTokens(text, ".!?"); // split by punctuation
  words = splitTokens(text, " \n\r\t"); // split by spaces n stuff
  letters = text.toCharArray();        // break into single letters
  
  // decide starting drop count based on mode
  setNumDropsByMode();
  initializeDrops(); // fill up the drops list
}

void draw() {
  // adding a lil trail fade effect
  fill(0, 50); 
  rect(0, 0, width, height);
  
  // update every drop, let em fall
  for (TextDrop drop : drops) {
    drop.update();
  }
  
  // handle collisions if that’s turned on
  if (collisionEnabled) {
    handleCollisions();
  }
  
  // show all the drops on the screen
  for (TextDrop drop : drops) {
    drop.display();
  }
  
  // display info about the current mode, collisions, and drop count
  displayStatus();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    // switch between modes (sentence -> word -> letter)
    mode = (mode + 1) % 3; 
    setNumDropsByMode(); // update drop count for new mode
    initializeDrops();   // reset the drops
  } else if (mouseButton == RIGHT) {
    // toggle collision on or off
    collisionEnabled = !collisionEnabled; 
  }
}

void mouseWheel(MouseEvent event) {
  // adjust the number of drops using mouse scroll
  float e = event.getCount();
  adjustNumDrops((int)e);
}

void adjustNumDrops(int change) {
  // tweak the drop count, but stay in the limits
  numDrops -= change;
  numDrops = constrain(numDrops, minDrops, maxDrops);
  
  // if drops are less, add new ones
  if (drops.size() < numDrops) {
    int dropsToAdd = numDrops - drops.size();
    for (int i = 0; i < dropsToAdd; i++) {
      String content = getRandomContent(); // get a random text bit
      drops.add(new TextDrop(content));
    }
  } else if (drops.size() > numDrops) {
    // too many? remove some extras from the end
    int dropsToRemove = drops.size() - numDrops;
    for (int i = 0; i < dropsToRemove; i++) {
      drops.remove(drops.size() - 1);
    }
  }
}

void setNumDropsByMode() {
  // set the default drop count based on the mode
  switch (mode) {
    case 0:
      numDrops = 20; // fewer for sentences
      break;
    case 1:
      numDrops = 50; // medium for words
      break;
    case 2:
      numDrops = 100; // more for letters, they small
      break;
    default:
      numDrops = 50; // fallback in case something goes wrong
  }
  numDrops = constrain(numDrops, minDrops, maxDrops); // just in case
}

void initializeDrops() {
  // clear the old drops and fill with new ones
  drops.clear();
  for (int i = 0; i < numDrops; i++) {
    String content = getRandomContent(); // randomize text
    drops.add(new TextDrop(content));
  }
}

String getRandomContent() {
  // grab a random sentence, word, or letter based on mode
  String content = "";
  switch (mode) {
    case 0: // sentence mode
      content = trim(sentences[int(random(sentences.length))]) + ".";
      break;
    case 1: // word mode
      content = words[int(random(words.length))];
      break;
    case 2: // letter mode
      content = str(letters[int(random(letters.length))]);
      break;
  }
  return content;
}

void handleCollisions() {
  // check every drop against each other for collisions
  for (int i = 0; i < drops.size(); i++) {
    TextDrop dropA = drops.get(i);
    for (int j = i + 1; j < drops.size(); j++) {
      TextDrop dropB = drops.get(j);
      if (dropA.checkCollision(dropB)) {
        dropA.resolveCollision(dropB); // fix it if they bump
      }
    }
  }
}

void displayStatus() {
  // show info like mode, collision state, and drop count
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
  text(modeText + " | " + collisionText + " | Drops: " + numDrops, width / 2, 20);
}
