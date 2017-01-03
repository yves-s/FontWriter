import processing.pdf.*;
import controlP5.*;
import java.util.Map;

ControlP5 cp5;

RadioButton rAlign;

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

HashMap<Integer, ArrayList> charsInRow = new HashMap<Integer, ArrayList>();

Align align;

int x = -letterWidth;
int y = 0;

boolean newletter;
boolean savePDF = false;
boolean changed = true;

int numChars = 26;
PShape[] keyArray = new PShape[numChars];
//String input = "d \nq";
String input = "";

void setup() {
  size(594, 840);
  pixelDensity(2);

  noStroke();
  background(255);

  cp5 = new ControlP5(this);
  //align=Align.RIGHT;

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

  rAlign = cp5.addRadioButton("radioButton")
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

  for (int i = 0; i < numChars; i++) {
    keyArray[i] = loadShape(i + ".svg");
  }
}

void draw() {
  if(
    letterWidth != oldLetterWidth ||
    letterSpacing != oldLetterSpacing
  ) {
    changed = true;
  }
  
  // `changed` is used to aviod running into out of memory
  if (
    !changed
  ) return;

  if (savePDF) {
    beginRecord(PDF, "documents/nice.pdf");
  }
  background(255);
  char letter;
  int charCount = input.length();
  int maxCharsInRow = parseInt((width-(documentPadding*2)) / letterWidth);
  int currentRowWidth = 0;
  int c=0;
  int keyIndex;
  int keyValue;
  row=0;

  y = 0;
  
  charsInRow.put(0, new ArrayList());

    println("---------------------------");
  for (int i=0; i<charCount; i++) {
    letter = input.charAt(i);
    keyValue = parseInt(letter);
    
    if(
      keyValue == 10 ||
      (
        i%maxCharsInRow == 0 &&
        i != 0
      )
    ) {
      row++;
      c=0;
    }
    
    println("OLD ROW " + oldRow);
    println(" MODULO " + (i%maxCharsInRow) + charsInRow.get(row) + " - ROW: "+ row +" - CHAR COUNT IN ROW: "+ charCountInRow + " - C: "+c+" CHAR COUNT " + charCount + " MAX CHAR " + maxCharsInRow);  

    if (align==Align.RIGHT) {
      x = (letterWidth*c) + (width-(charCountInRow*letterWidth+documentPadding));
      println(align);
      println("X " + x + " -- " + (letterWidth*c) + " -- " + (width-(letterWidth+documentPadding)) + " WIDTH " + width);
    } else if (align==Align.CENTER) {

      //if(charCount>maxCharsInRow){charCountInRow=maxCharsInRow;}

      currentRowWidth = (charCountInRow*letterWidth/2);
      x = ((width/2)-(currentRowWidth))+(c*letterWidth);
    } else {
      x = (letterWidth*c)+documentPadding;
    }


    if (letter <= 'Z') {
      keyIndex = int(letter)-'A';
    } else {
      keyIndex = int(letter)-'a';
    }

    //dont draw shape if letter is whitespace or return
    if (
      keyValue!=32 &&
      keyValue!=10
      ) {
      shape(keyArray[keyIndex], x, y+documentPadding, letterWidth, letterWidth);
    }

    oldLetterSpacing = letterSpacing;
    oldLetterWidth = letterWidth;
    oldRow = row;
    if (i == charCount-1) {
      changed = false;
    }

    c++;
    if (((c+1)*letterWidth)>(width-(documentPadding*2)) || keyValue==10) {
      y+=letterSpacing;
      //row++;
      c=0;
    }
  }

  if (savePDF == true) {
    endRecord();
    savePDF = false;
  }
}

void keyPressed() {
  changed = true;
  
  println("ROW " + row);
  if(row != oldRow) {
    charsInRow.put(row, new ArrayList()); 
  }
  
  println("KEY PRESSED" + charsInRow + " " + key);

  if ((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) {
    charsInRow.get(row).add(key);
    input += key;
  }
  if (key == ' ') {
    charsInRow.get(row).add(key);
    input += key;
  }
  if (key == RETURN || key == ENTER) {
    charsInRow.get(row).add(key);
    input+="\n";
  }
  if (keyCode == BACKSPACE) {
    if (input.length()>0) {
      //charsInRow.get(row).remove(charCountInRow-1);
      input = input.substring(0, input.length()-1);
    }
  }
  
  charCountInRow = charsInRow.get(row).size();
}

void radioButton(int a) {
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

public void save() {
  changed = true;

  endRecord();
  savePDF = true;
}