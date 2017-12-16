
public class Button
{
  float x, y, width, height;
  String text;
  PFont font;
  
  Button(float xx, float yy, float w, float h, String t)
  {
    x = xx;
    y = yy;
    width = w;
    height = h;
    text = t;
    font = createFont("Arial", 11, true);
    
    Interactive.add(this);
  }
  
  void mousePressed(float mx, float my) 
  {
  }
  
  void mouseReleased()
  {
    Interactive.send(this, "click");
  }
  
  void draw()
  {
    boolean mouseOver = Interactive.insideRect(x, y, width, height, mouseX, mouseY);
    
    if (mouseOver) {
      fill(255);
    } else {
      fill(200);
    }
    
    rect(x, y, width, height);
    
    fill(0);
    
    int pad = 20;
    textFont(font);
    text(text, x + pad, y + pad);
  } 
}