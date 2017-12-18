import java.util.Collections;
import java.util.LinkedList;
import java.nio.ByteBuffer;

public class Timeline
{
  float x, y, width, height;
  ArrayList<Handle> handles;
  Handle activeHandle = null;
  float pxPerS = 10;
  PFont font;
  boolean isPanning = false;
  float prevPanMouseX = 0; // Used to calculate dx when panning
  float panOffset = 0; // Panning offset in px
  int MAX_NUMBER_OF_HANDLES = 250;
    
  Timeline(float xx, float yy, float w, float h)
  {
    x = xx; y = yy; width = w; height = h;
    
    handles = new ArrayList<Handle>();
    
    font = createFont("Arial", 11, true);
    
    Interactive.add(this);
  }
  
  void reset()
  {
    handles.clear();
    panOffset = 0;
  }
  
  void mouseMoved(float mx, float my)
  {
    boolean overTimeline = insideTimeline(mx, my);
    boolean overPanArea = insidePanArea(mx, my);
    
    if (overTimeline) {
      if (overPanArea) {
        cursor(MOVE);
      } else {
        cursor(CROSS);
      }
    } else {
      cursor(ARROW);
    }
  }
  
  boolean insideTimeline(float mx, float my)
  {
    return Interactive.insideRect(x, y, width, height, mx, my);
  }
  
  boolean insidePanArea(float mx, float my)
  {
    float panAreaWidth = 50;
    boolean insideRightArea = Interactive.insideRect(x + width - panAreaWidth, y, panAreaWidth, height, mx, my);
    boolean insideLeftArea = Interactive.insideRect(x, y, min(panOffset, panAreaWidth), height, mx, my);
    return insideRightArea || insideLeftArea;
  }
    
  void mousePressed(float mx, float my) 
  {
    prevPanMouseX = mx;
    float tx = mx + panOffset;
    
    boolean leftClick = mouseButton == LEFT; // Select, create or pan
    boolean rightClick = mouseButton == RIGHT; // Delete
    
    if (leftClick && insidePanArea(mx, my))
    {
      isPanning = true;
      return;
    }
    
    for (int i = 0; i < handles.size(); i++) {
      Handle handle = handles.get(i);
      if (handle.isInside(tx, my)) {
        if (leftClick) {
          activeHandle = handle;
        } else if (rightClick) {
          handles.remove(i);
        }
        break;
      }
    }
    
    boolean shouldCreateNewHandle = leftClick && activeHandle == null;
    
    if (shouldCreateNewHandle) {
      if (handles.size() < MAX_NUMBER_OF_HANDLES) {
        activeHandle = new Handle(tx, my);
        handles.add(activeHandle);
        Collections.sort(handles);
      } else {
        JOptionPane.showMessageDialog(
          (Component) null,
          "Cannot add more than " + MAX_NUMBER_OF_HANDLES + " points in timeline!"
        );
      }
    }
  }
    
  void mouseDragged(float mx, float my)
  {
    if (isPanning)
    {
      float dx = mx - prevPanMouseX;
      prevPanMouseX = mx;
      panOffset -= dx;
      panOffset = max(0, panOffset);
      return;
    }
    
    if (activeHandle != null) {
      int index = handles.indexOf(activeHandle);
      float lowerx = index == 0 ? x + panOffset : handles.get(index - 1).x;
      float tx = max(mx + panOffset, lowerx);
      tx = wholeSecondPx(tx);
      my = constrain(my, y, y + height);
      float dx = tx - activeHandle.x;
      activeHandle.moveTo(tx, my);
      for (int i = index + 1; i < handles.size(); i++) {
        handles.get(i).move(dx, 0);
      }
    }
  }
    
  void mouseReleased()
  {
    activeHandle = null;
    isPanning = false;
  }

  void draw()
  {
    
    fill(255);
    rect(x, y, width, height);
    
    // Nice to have...
    float middleY = y + height / 2;
   
    pushMatrix();
    translate(-panOffset, 0);
      
    fill(36, 157, 244);
    
    for (int i = 0; i < handles.size() - 1; i++) {
      Handle current = handles.get(i);
      Handle next = handles.get(i + 1);
      
      float x1 = current.x;
      float y1 = middleY;
      float x2 = x1;
      float y2 = current.y;
      float x3 = next.x;
      float y3 = next.y;
      float x4 = x3;
      float y4 = y1;
      beginShape();
      vertex(x1, y1);
      vertex(x2, y2);
      vertex(x3, y3);
      vertex(x4, y4);
      endShape();
      
    }
      
    for (int i = 0; i < handles.size(); i++) {
      Handle handle = handles.get(i);
      //fill(255/handles.size() * i);
      fill(255);
      handle.draw();
      
      fill(0);
      textFont(font);
      String text = pxToPrettyTime(handle.x);
      float textW = textWidth(text);
      float textH = textAscent() - textDescent();
      float textX = x + handle.x - textW / 2;
      float textY = middleY + textH / 2 + 10 * (handle.y < middleY ? 1 : -1);
      text(text, textX, textY);
    }
    
    popMatrix();
    
    // The middle zero line
    line(x, middleY, x + width, middleY);
  }
    
  float pxToSeconds (float px)
  {
    return (px - x) / pxPerS;
  }
  
  float secondsToPx (float seconds)
  {
    return seconds * pxPerS + x;
  }
  
  float wholeSecondPx(float px)
  {
    return secondsToPx(round(pxToSeconds(px)));
  }
  
  float pxToDecimalValue(float px)
  {
    // Between [-1, 1]
    float middleY = y + height / 2;
    return ((px - middleY) / height) * -2;
  }
  
  float decimalValueToPx(float decimal)
  {
    float middleY = y + height / 2;
    return middleY + decimal * height / -2;
  }
  
  String pxToPrettyTime (float px)
  {
    int seconds = floor(pxToSeconds(px));
    int minutes = floor(seconds / 60);
    seconds = floor(seconds - 60 * minutes);
    String time = minutes + "m" + seconds + "s";
    return time;
  }
  
  byte[] toByteArray()
  {
    /*
      Every keyframe is 4 bytes
      t0 t1 t2 v0
      This gives us a max time of ((2^(8*3)) / 60) / 60 = 4660 minutes
      Data resolution will be 2^8-1 = 255 steps. The first bit in the value byte decides direction.
      The EEPROM is 1KB and can hold 1024/4 = 256 keyframes.
    */
    
    int packetSize = 4;
    
    byte[] data = new byte[handles.size() * packetSize];
    
    for (int i = 0; i < handles.size(); i ++)
    {
      Handle handle = handles.get(i);
      
      // Create seconds bytes.
      int seconds = round(pxToSeconds(handle.x));
      byte[] t = ByteBuffer.allocate(4).putInt(seconds).array();
      
      // Create value byte.
      float decimal = pxToDecimalValue(handle.y);
      byte v0 = (byte)((decimal / 2) * 255);
      
      // Create package.
      data[packetSize * i] = t[3];     // LSB
      data[packetSize * i + 1] = t[2];
      data[packetSize * i + 2] = t[1]; // MSB
      data[packetSize * i + 3] = v0;
    }
    
    return data;
  }
  
  void fromByteArray(byte[] data)
  {
    reset();
    
    int packetSize = 4;
    
    for (int i = 0; i < data.length; i += packetSize) {
      
      // Decode seconds.
      byte[] bytes = { 0, data[i+2], data[i+1], data[i] };
      int seconds = ByteBuffer.wrap(bytes).getInt();
      
      // Decode value.
      float value = (data[i + 3] * 2.) / 255.;
      
      // Convert to pixels and create handle.
      float hx = secondsToPx(seconds);
      float hy = decimalValueToPx(value);
      Handle handle = new Handle(hx, hy);
      handles.add(handle);
    }
  }
}

class Handle implements Comparable<Handle>
{
  float x, y, width, height;
  
  Handle(float xx, float yy)
  {
    x = xx;
    y = yy;
    width = 10;
    height = 10;
  }
  
  void moveTo(float xx, float yy)
  {
    x = xx;
    y = yy;
  }
  
  void move(float dx, float dy)
  {
    x += dx;
    y += dy;
  }
  
  void draw()
  {
    rect(x - width / 2, y - height / 2, width, height);
  }
  
  public boolean isInside(float mx, float my)
  {
    return Interactive.insideRect(x - width / 2, y - height / 2, width, height, mx, my);
  }
  
  public int compareTo(Handle other) {
    return (int)(x - other.x);
  }
}