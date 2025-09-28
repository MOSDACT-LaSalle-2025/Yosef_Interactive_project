
import ddf.minim.*;

Minim minim;
AudioPlayer song;


int cols = 14;
int rows = 14;
int cellSize = 90;

Drawer[] drawers = new Drawer[5];
color[] colors = new color[5];
RowMotion[] xMotion = new RowMotion[rows];
RowMotion[] yMotion = new RowMotion[cols];

float[] xDirections = new float[5];
float[] yDirections = new float[5];
float[] xSpeedFactors = new float[5];
float[] ySpeedFactors = new float[5];

float controlSpeed = 50000000; // משנה את המהירות הכללית של הסקץ'

interface Drawer {
  void draw(float cx, float cy, float s, color c);
}

class RowMotion {
  float offset;
  float speed;

  RowMotion(float speed, boolean vertical) {
    this.speed = speed;
    this.offset = vertical ? random(height) : 0;
  }

  void update(boolean vertical, float direction, float speedFactor, float controlSpeed) {
    float delta = speed * direction * speedFactor * controlSpeed;
    offset += vertical ? -delta : delta;

    if (offset < 0) offset += cellSize;
    if (offset > cellSize) offset -= cellSize;
  }

  float getOffset() {
    return offset;
  }
}

void settings() {
  size(cols * cellSize, rows * cellSize);
}

void setup() {
    minim = new Minim(this);
  song = minim.loadFile("Four-Tet-Parallel-Jalebi.mp3"); // ודא שהקובץ נמצא בתיקיית data
  song.play();
  rectMode(CENTER);
  textSize(20);
  fill(255);

  initColors();
  initDrawers();
  initMotionArrays();

  for (int i = 0; i < 5; i++) {
    xDirections[i] = 1;
    yDirections[i] = -1;
    xSpeedFactors[i] = 1.0;
    ySpeedFactors[i] = 1.0;
  }
}

void draw() {
  background(8, 7, 8);

  drawHorizontalLayer();
  blendMode(DIFFERENCE);
  drawVerticalLayer();
  blendMode(BLEND);

  fill(255);
  for (int i = 0; i < 5; i++) {
    text("X Speed " + i + ": " + nf(xSpeedFactors[i], 1, 2), 10, height - 120 + i * 20);
    text("Y Speed " + i + ": " + nf(ySpeedFactors[i], 1, 2), 200, height - 120 + i * 20);
  }
}

void drawHorizontalLayer() {
  for (int y = 0; y < rows; y++) {
    int type = y % 5;
    color c = colors[type];
    xMotion[y].update(false, xDirections[type], xSpeedFactors[type], controlSpeed);

    for (int x = 0; x <= cols; x++) {
      float cx = ((x * cellSize + xMotion[y].getOffset()) % (cols * cellSize) + cols * cellSize) % (cols * cellSize);
      float cy = y * cellSize + cellSize * 0.5;
      drawers[type].draw(cx, cy, cellSize, c);
    }
  }
}

void drawVerticalLayer() {
  for (int x = 0; x < cols; x++) {
    int type = x % 5;
    color c = colors[type];
    yMotion[x].update(true, yDirections[type], ySpeedFactors[type], controlSpeed);

    for (int i = 0; i <= rows + 2; i++) {
      float cy = ((height + yMotion[x].getOffset() - i * cellSize) % (rows * cellSize) + rows * cellSize) % (rows * cellSize);
      float cx = x * cellSize + cellSize * 0.5;
      drawers[type].draw(cx, cy, cellSize, c);
    }
  }
}

void keyPressed() {
  // מהירות X
  if (key == '1') xSpeedFactors[0] *= 1.1;
  if (key == '2') xSpeedFactors[0] *= 0.9;
  if (key == '3') xSpeedFactors[1] *= 1.1;
  if (key == '4') xSpeedFactors[1] *= 0.9;
  if (key == '5') xSpeedFactors[2] *= 1.1;
  if (key == '6') xSpeedFactors[2] *= 0.9;
  if (key == '7') xSpeedFactors[3] *= 1.1;
  if (key == '8') xSpeedFactors[3] *= 0.9;
  if (key == '9') xSpeedFactors[4] *= 1.1;
  if (key == '0') xSpeedFactors[4] *= 0.9;

  // מהירות Y
  if (key == 'a') ySpeedFactors[0] *= 1.1;
  if (key == 's') ySpeedFactors[0] *= 0.9;
  if (key == 'd') ySpeedFactors[1] *= 1.1;
  if (key == 'f') ySpeedFactors[1] *= 0.9;
  if (key == 'g') ySpeedFactors[2] *= 1.1;
  if (key == 'h') ySpeedFactors[2] *= 0.9;
  if (key == 'j') ySpeedFactors[3] *= 1.1;
  if (key == 'k') ySpeedFactors[3] *= 0.9;
  if (key == 'l') ySpeedFactors[4] *= 1.1;
  if (key == ';') ySpeedFactors[4] *= 0.9;

  // כיוון X
  if (key == 'q') xDirections[0] *= -1;
  if (key == 'w') xDirections[1] *= -1;
  if (key == 'e') xDirections[2] *= -1;
  if (key == 'r') xDirections[3] *= -1;
  if (key == 't') xDirections[4] *= -1;

  // כיוון Y
  if (key == 'u') yDirections[0] *= -1;
  if (key == 'i') yDirections[1] *= -1;
  if (key == 'o') yDirections[2] *= -1;
  if (key == 'p') yDirections[3] *= -1;
  if (key == '[') yDirections[4] *= -1;
}

void initColors() {
  colors[0] = color(230, 232, 230);
  colors[1] = color(55, 114, 255);
  colors[2] = color(223, 41, 53);
  colors[3] = color(253, 202, 64);
  colors[4] = color(80, 202, 38);
}

void initMotionArrays() {
  for (int i = 0; i < rows; i++) {
    xMotion[i] = new RowMotion(0.5 + random(0.5), false);
  }
  for (int i = 0; i < cols; i++) {
    yMotion[i] = new RowMotion(0.3 + random(0.4), true);
  }
}

void initDrawers() {
  drawers[0] = (cx, cy, s, c) -> {
    stroke(c);
    strokeWeight(5);
    float gap = s / 4;
    for (int i = -1; i <= 1; i++) {
      line(cx + i * gap, cy - s/2, cx + i * gap, cy + s/2);
    }
  };

  drawers[1] = (cx, cy, s, c) -> {
    noFill();
    stroke(c);
    strokeWeight(4);
    ellipse(cx, cy, s, s);
  };

  drawers[2] = (cx, cy, s, c) -> {
    noFill();
    stroke(c);
    strokeWeight(3);
    line(cx - s/2, cy - s/2, cx + s/2, cy + s/2);
    line(cx + s/2, cy - s/2, cx - s/2, cy + s/2);
  };

  drawers[3] = (cx, cy, s, c) -> {
    noStroke();
    fill(c);
    ellipse(cx, cy, s, s);
  };

  drawers[4] = (cx, cy, s, c) -> {
    noFill();
    stroke(c);
    strokeWeight(4);
    rect(cx, cy, s, s);
  };
}
