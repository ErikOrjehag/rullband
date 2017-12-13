
public class Button
{
  float x, y, width, height;
  String text;
  
  Button(float xx, float yy, float w, float h, String t)
  {
    x = xx;
    y = yy;
    width = w;
    height = h;
    text = t;
    
    Interactive.add(this);
  }
  
  void mousePressed(float mx, float my) 
  {
    print("PRESS!");
  }
  
  void mouseReleased()
  {
    print(text);
    Interactive.send(this, "click");
  }
  
  void draw()
  {
    fill( 255 );
    rect(x, y, width, height);
    fill( 0 );
    int pad = 20;
    text(text, x + pad, y + pad);
  } 
}