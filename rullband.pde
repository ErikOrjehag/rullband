
import processing.serial.*;
import de.bezier.guido.*;
import java.awt.Component;
import javax.swing.JOptionPane;

Timeline timeline;

void setup ()
{
  int width = 1000;
  int height = 300;
  size(1000, 300);
    
  Interactive.make( this );
  
  int pad = 10;
  int buttonW = 100;
  int buttonH = 30;
    
  timeline = new Timeline(0, pad * 2 + buttonH, width - pad * 2, height - buttonH - pad * 3);
  Button newBtn = new Button(0, pad, buttonW, buttonH, "New");
  Button openBtn = new Button(buttonW, pad, buttonW, buttonH, "Open");
  Button saveBtn = new Button(buttonW * 2, pad, buttonW, buttonH, "Save");
  Button uploadBtn = new Button(buttonW * 3, pad, buttonW, buttonH, "Upload");
  
  Interactive.on(newBtn, "click", this, "newProject");
  Interactive.on(openBtn, "click", this, "openFile");
  Interactive.on(saveBtn, "click", this, "saveFile");
  Interactive.on(uploadBtn, "click", this, "uploadProject");
}

void draw ()
{
    background( 0 );
}

void newProject ()
{
  boolean chooseOK = JOptionPane.showConfirmDialog(
    (Component) null, 
    "Unsaved work will be lost", 
    "Are you sure?", 
    JOptionPane.OK_CANCEL_OPTION
  ) == 0;
  
  if (chooseOK) {
    timeline.reset();
  }
}

void saveFile ()
{
  selectOutput("Select a file to write to:", "saveFileCb");
}

void saveFileCb (File selection)
{
  if (selection != null)
  {
    String path = selection.getAbsolutePath();
    byte[] data = timeline.toByteArray();
    saveBytes(path, data);
  }
}

void openFile ()
{
  selectInput("Select a file to read from:", "openFileCb");
}

void openFileCb (File selection)
{
  if (selection != null)
  {
    String path = selection.getAbsolutePath();
    byte[] data = loadBytes(path);
    timeline.fromByteArray(data);
  }
}

void uploadProject ()
{
  // TODO: This is completely untested and maybe needs a way to select the correct serial device.
  Serial port;
  printArray(Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
  byte[] data = timeline.toByteArray();
  port.write(data);
}