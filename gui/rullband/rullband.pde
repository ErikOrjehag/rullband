
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
  
  int buttonW = 100;
  int buttonH = 30;
    
  timeline = new Timeline(0, buttonH, width, height - buttonH);
  
  Button newBtn =    new Button(0,           0, buttonW, buttonH, "New");
  Button openBtn =   new Button(buttonW,     0, buttonW, buttonH, "Open");
  Button saveBtn =   new Button(buttonW * 2, 0, buttonW, buttonH, "Save");
  Button uploadBtn = new Button(buttonW * 3, 0, buttonW, buttonH, "Upload");
  
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
  //printArray(Serial.list());
  
  String[] ports = {"USB", "COM"};
  String[] options = filter(Serial.list(), ports);
  String device;
  
  if (timeline.handles.size() < 2) {
    JOptionPane.showMessageDialog(
      (Component) null,
      "The timeline needs at least two points!"
    );
    return;
  }
 
  if (options.length == 0)
  {
    JOptionPane.showMessageDialog(
      (Component) null,
      "No serial device connected."
    );
    return;
  }
  else if (options.length == 1)
  {
    device = options[0];
  }
  else
  {
    device = (String)JOptionPane.showInputDialog(
      (Component) null,
      "Select serial device",
      "Select Dialog",
      JOptionPane.PLAIN_MESSAGE,
      null,
      options,
      options[0]
    );
  
    if ((device == null) || (device.length() == 0)) {
      return;
    }
  }
  
  Serial port = new Serial(this, device, 9600);

  byte[] data = timeline.toByteArray();
  port.write(timeline.handles.size());
  port.write(data);
  port.stop();
  
  JOptionPane.showMessageDialog(
    (Component) null,
    "Upload complete."
  );
}

String[] filter(String[] array, String[] things)
{
  ArrayList<String> result = new ArrayList<String>();
  for (String s : array) {
    if (containsAny(s, things)) {
      result.add(s);
    }
  }
  return result.toArray(new String[result.size()]);
}

boolean containsAny(String s, String[] things) {
  for (String thing : things) {
    if (s.contains(thing)) {
      return true;
    }
  }
  return false;
}