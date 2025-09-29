


import ddf.minim.*;
import themidibus.*;

Minim minim;
AudioPlayer song;
MidiBus myBus;

int cols = 14;
int rows = 14;
int cellSize = 90;

Drawer[] drawers = new Drawer[5];
color[] colors = new color[5];
RowMotion[] xMotion = new RowMotion[rows];
RowMotion[] yMotion = new RowMotion[cols];

// מצב לכל צורה
boolean[] shapeVisible = new boolean[5];
float[] shapeScale = new float[5]; // פי כמה לגדול
float[] shapeSpeed = new float[5]; // מהירות

// כיוונים
float[] xDirections = new float[5];
float[] yDirections = new float[5];

float controlSpeed = 500000000; // בסיס מהירות

interface Drawer {
  void draw(float cx, float cy, float s, color c, float scale);
}

class RowMotion {
  float offset;
  float speed;

  RowMotion(float speed, boolean vertical) {
    this.speed = speed;
    this.offset = vertical ? random(height) : 0;
  }

  void update(boolean vertical, float direction, float speedFactor) {
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
  song = minim.loadFile("Four-Tet-Parallel-Jalebi.mp3");
  song.play();

  MidiBus.list();
  myBus = new MidiBus(this, "LPD8 mk2", "LPD8 mk2");

  rectMode(CENTER);
  textSize(20);
  fill(255);

  initColors();
  initDrawers();
  initMotionArrays();

  for (int i = 0; i < 5; i++) {
    xDirections[i] = 1;
    yDirections[i] = -1;
    shapeScale[i] = 1.0;
    shapeSpeed[i] = 1.0;
    shapeVisible[i] = false;
  }

  // צורה 5 תמיד נראית
  shapeVisible[4] = true;
}

void draw() {
  background(8, 7, 8);

  drawHorizontalLayer();
  blendMode(DIFFERENCE);
  drawVerticalLayer();
  blendMode(BLEND);

  // טקסט מידע
  fill(255);
  for (int i = 0; i < 5; i++) {
    text("Shape " + i + " Speed: " + nf(shapeSpeed[i], 1, 2), 10, height - 120 + i * 20);
    text("Shape " + i + " Scale: " + nf(shapeScale[i], 1, 2), 200, height - 120 + i * 20);
  }
}

void drawHorizontalLayer() {
  for (int y = 0; y < rows; y++) {
    int type = y % 5;
    if (!shapeVisible[type]) continue; // רק אם הצורה גלויה
    color c = colors[type];
    xMotion[y].update(false, xDirections[type], shapeSpeed[type]);

    for (int x = 0; x <= cols; x++) {
      float cx = ((x * cellSize + xMotion[y].getOffset()) % (cols * cellSize) + cols * cellSize) % (cols * cellSize);
      float cy = y * cellSize + cellSize * 0.5;
      drawers[type].draw(cx, cy, cellSize, c, shapeScale[type]);
    }
  }
}

void drawVerticalLayer() {
  for (int x = 0; x < cols; x++) {
    int type = x % 5;
    if (!shapeVisible[type]) continue;
    color c = colors[type];
    yMotion[x].update(true, yDirections[type], shapeSpeed[type]);

    for (int i = 0; i <= rows + 2; i++) {
      float cy = ((height + yMotion[x].getOffset() - i * cellSize) % (rows * cellSize) + rows * cellSize) % (rows * cellSize);
      float cx = x * cellSize + cellSize * 0.5;
      drawers[type].draw(cx, cy, cellSize, c, shapeScale[type]);
    }
  }
}

// ---------------- MIDI -----------------

void controllerChange(int channel, int number, int value) {
  float mapped;
  // מהירות CC70-74 לצורות 1-4
  if (channel == 0 && number >= 70 && number <= 74) {
    int idx = number - 70;
    mapped = map(value, 0, 127, 50000, 50000000);
    shapeSpeed[idx] = mapped / controlSpeed;
  }
  // צורה 5 - מהירות CC76
  if (channel == 0 && number == 76) {
    mapped = map(value, 0, 127, 50000, 50000000);
    shapeSpeed[4] = mapped / controlSpeed;
  }
  // צורה 5 - גודל CC77
  if (channel == 0 && number == 77) {
    shapeScale[4] = map(value, 0, 127, 1, 4);
  }
}

void noteOn(int channel, int pitch, int velocity) {
  if (channel == 9) {
    int idx = -1;
    if (pitch == 40) idx = 2; // X
    if (pitch == 41) idx = 1;
    if (pitch == 42) idx = 3;
    if (pitch == 43) idx = 0;
    if (pitch == 44) idx = 4; // צורה 5 לא צריכה Note On, אבל שיהיה

    if (idx >= 0 && idx < 4) {
      shapeScale[idx] = (velocity < 30) ? 1.0 : map(velocity, 30, 127, 1, 4);
    }
  }
}

void noteOff(int channel, int pitch, int velocity) {
  if (channel == 9) {
    if (pitch == 36) shapeVisible[2] = true; // X
    if (pitch == 37) shapeVisible[1] = true;
    if (pitch == 38) shapeVisible[3] = true;
    if (pitch == 39) shapeVisible[0] = true;
    // צורה 5 תמיד גלויה
  }
}

// ---------------- SETUP HELPERS -----------------

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
  drawers[0] = (cx, cy, s, c, scale) -> {
    stroke(c);
    strokeWeight(5);
    float gap = s / 4 * scale;
    for (int i = -1; i <= 1; i++) {
      line(cx + i * gap, cy - s/2 * scale, cx + i * gap, cy + s/2 * scale);
    }
  };

  drawers[1] = (cx, cy, s, c, scale) -> {
    noFill();
    stroke(c);
    strokeWeight(4);
    ellipse(cx, cy, s * scale, s * scale);
  };

  drawers[2] = (cx, cy, s, c, scale) -> {
    noFill();
    stroke(c);
    strokeWeight(3);
    line(cx - s/2 * scale, cy - s/2 * scale, cx + s/2 * scale, cy + s/2 * scale);
    line(cx + s/2 * scale, cy - s/2 * scale, cx - s/2 * scale, cy + s/2 * scale);
  };

  drawers[3] = (cx, cy, s, c, scale) -> {
    noStroke();
    fill(c);
    ellipse(cx, cy, s * scale, s * scale);
  };

  drawers[4] = (cx, cy, s, c, scale) -> {
    noFill();
    stroke(c);
    strokeWeight(4);
    rect(cx, cy, s * scale, s * scale);
  };
}
