/**
 *    Simple buttons
 *
 *    .. works with JavaScript mode since Processing 2.0a5
 */

import de.bezier.guido.*;

void setup ()
{
  size(400, 400);
    
  Interactive.make( this );
    
  new AwesomeTimeline(10, 10, 300, 100);
}

void draw ()
{
    background( 0 );
}