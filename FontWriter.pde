import processing.pdf.*;
import controlP5.*;
import java.util.Map;

ControlP5 cp5;
RadioButton rAlign;
Align align;

public static final int[] ENTER = {10, 13};
public static final int BACKSPACE = 8;
public static final int A = 65;
public static final int Z = 90;
public static final int SPACE = 32;

int maxCharsInRow;
int letterHeight = 50;
int oldLetterHeight = 0;
int letterWidth = 44;
int oldLetterWidth = 0;
int documentPadding = 20;
float letterSpacing = letterHeight+letterHeight/5;
float oldLetterSpacing = 0;
int row = 0;
int oldRow = -1;
int charCountInRow = 0;
int currentRowWidth;

HashMap<Integer, ArrayList> rows = new HashMap<Integer, ArrayList>();

int x = -letterWidth;
int y = 0;

boolean newletter;
boolean savePDF = false;
boolean changed = true;

void setup() {
  size(594, 840);
  pixelDensity(2);

  noStroke();
  background(255);

  cp5 = new ControlP5(this);
  align=Align.LEFT;
  rows.put(row, new ArrayList());

  cp5.addSlider("letterWidth")
    .setPosition(10, height-30)
    .setRange(10, 100)
    .setSize(100, 20)
    .setValue(letterWidth)
    .setColorBackground(color(83, 83, 83))
    .setColorForeground(color(69, 69, 69))
    .setColorActive(color(56, 56, 56));

  cp5.addSlider("letterSpacing")
    .setPosition(150, height-30)
    .setRange(10, 700)
    .setSize(100, 20)
    .setValue(letterSpacing)
    .setColorBackground(color(83, 83, 83))
    .setColorForeground(color(69, 69, 69))
    .setColorActive(color(56, 56, 56));

  rAlign = cp5.addRadioButton("changeAlignment")
    .setPosition(290, height - 30)
    .setSize(40, 20)
    .setColorBackground(color(83, 83, 83))
    .setColorForeground(color(69, 69, 69))
    .setColorActive(color(56, 56, 56))
    .setColorLabel(color(83, 83, 83))
    .setItemsPerRow(3)
    .setSpacingColumn(40)
    .addItem("LEFT", 1)
    .addItem("CENTER", 2)
    .addItem("RIGHT", 3);

  cp5.addButton("save")
    .setValue(0)
    .setPosition(width - 64, height -30)
    .setSize(54, 20)
    .setColorBackground(color(83, 83, 83))
    .setColorForeground(color(69, 69, 69))
    .setColorActive(color(56, 56, 56));
}

int rowCount;
int keyValue;

void draw() {
  if(
    letterWidth != oldLetterWidth ||
    letterSpacing != oldLetterSpacing
  ) {
    changed = true;
  }
  
  // `changed` is used to avoid unnecessary drawing
  if (!changed) return;

  if (savePDF) {
    beginRecord(PDF, "documents/nice.pdf");
  }
  
  background(255);
  
  rowCount = rows.containsKey(row) ? rows.size() : 0;
  maxCharsInRow = parseInt((width-(documentPadding*2)) / letterWidth);
  
  // Loop through rows
  for(int i=0; i<rowCount; i++) {
    
    charCountInRow = rows.get(i).size();
    // Loop through characters in specific row
    for(int j=0; j<charCountInRow; j++) {
      
      keyValue = (int)rows.get(i).get(j);
      
      x = handleAlignment(j, charCountInRow, align);
      
      if(keyValue != SPACE) {
        shape(loadShape(keyValue + ".svg"), x, (i*letterSpacing)+documentPadding, letterWidth, letterWidth);
      }
      
    }
    
  }

  if (savePDF == true) {
    
    endRecord();
    savePDF = false;
    
  }
  
  oldLetterSpacing = letterSpacing;
  oldLetterWidth = letterWidth;
  oldRow = row;
  changed = false;
}

public int handleAlignment(int charPos, int charCount, Align align) {
  switch(align) {
    case RIGHT:
      return (letterWidth*charPos)+(width-(charCountInRow*letterWidth+documentPadding));
    case CENTER:
      int offsetLeft = (width/2)-(charCount*(letterWidth/2));
      return offsetLeft+(charPos*letterWidth);
    case LEFT:
      return (letterWidth*charPos)+documentPadding;
    default:
      return (letterWidth*charPos)+documentPadding; 
  }
}

public void changeAlignment(int a) {
  changed = true;

  if (a>0) {
    
    switch(a) {
      case 2: 
        align = Align.CENTER;
        break;
      case 3:
        align = Align.RIGHT;
        break;
      default:
        align = Align.LEFT;
        break;
    }
    
  }
}

public void keyPressed() {
  //int keyCode = parseInt(key);
  changed = true;

  // New Line (Enter)
  // If Enter get's hit or char-count hits max-chars-in-row
  // increment row
  if(
    keyCode == ENTER[0] ||
    keyCode == ENTER[1] ||
    (
      charCountInRow == maxCharsInRow &&
      keyCode != BACKSPACE
    )
  ) {
    
    row++;
    rows.put(row, new ArrayList());
    currentRowWidth = (charCountInRow*letterWidth/2);
    
  }
  
  ArrayList charsInRow = rows.get(row);
  charCountInRow = charsInRow.size();
  
  // Remove Element (Backspace)
  if (keyCode == BACKSPACE) {
    
    if (
      row >= 0 &&
      charCountInRow > 0
    ) {
      charsInRow.remove(charCountInRow - 1);
    } else if (
      row > 0 &&
      charCountInRow == 0
    ) {
      
      rows.remove(row);
      row--;
      
    }
    
  }
  
  // Add key to array
  /*
    key >= 'a' && key <= 'z'
  */
  if (
    keyCode == SPACE ||
    (
      keyCode >= A &&
      keyCode <= Z
    )
  ) {
    charsInRow.add(keyCode);
  }
  
  println("KEY PRESSED END - ROW " + row + " ROWS " + rows);
}

public void save() {
  changed = true;

  endRecord();
  savePDF = true;
}