import java.util.Collections;
import java.util.LinkedList;

public class AwesomeTimeline
{
    float x, y, width, height;
    ArrayList<TimelineHandle> handles;
    TimelineHandle activeHandle = null;
    float pxPerS = 100;
    
    AwesomeTimeline(float xx, float yy, float w, float h)
    {
        x = xx; y = yy; width = w; height = h;
        handles = new ArrayList<TimelineHandle>();
        Interactive.add(this);
    }
    
    void mousePressed(float mx, float my) 
    {
      for (TimelineHandle handle : handles) {
        if (handle.isInside(mx, my)) {
          activeHandle = handle;
          break;
        }
      }
      if (activeHandle == null) {
        activeHandle = new TimelineHandle(mx, my);
        handles.add(activeHandle);
        Collections.sort(handles);
      }
    }
    
    void mouseDragged(float mx, float my)
    {
      if (activeHandle != null) {
        int index = handles.indexOf(activeHandle);
        float lowerx = index == 0 ? x : handles.get(index - 1).x;
        mx = max(mx, lowerx);
        my = constrain(my, y, y + height);
        float dx = mx - activeHandle.x;
        activeHandle.moveTo(mx, my);
        for (int i = index + 1; i < handles.size(); i++) {
          handles.get(i).move(dx, 0);
        }
      }
    }
    
    void mouseReleased()
    {
      activeHandle = null;
    }

    void draw()
    {
      fill(255);
      rect(x, y, width, height);
        
      fill(100);
      
      for (int i = 0; i < handles.size() - 1; i++) {
        TimelineHandle current = handles.get(i);
        TimelineHandle next = handles.get(i + 1);
        
        float x1 = current.x;
        float y1 = y + height;
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
        fill(255/handles.size() * i);
        handles.get(i).draw();
      }
    }
}

class TimelineHandle implements Comparable<TimelineHandle>
{
  float x, y, width, height;
  
  TimelineHandle(float xx, float yy)
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
    //fill( 120 );
    rect(x - width / 2, y - height / 2, width, height);
  }
  
  public boolean isInside(float mx, float my)
  {
    return Interactive.insideRect(x - width / 2, y - height / 2, width, height, mx, my);
  }
  
  public int compareTo(TimelineHandle other) {
    return (int)(x - other.x);
  }
}