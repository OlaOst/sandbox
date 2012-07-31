vertex:
  layout(location = 0) in vec3 position;
  layout(location = 1) in vec2 texCoords;

  out vec2 coords;

  void main(void)
  {
    coords = texCoords.st;
    
    gl_Position = vec4(position, 1.0);
  }

fragment:
  uniform sampler2D colorMap;
  uniform float timer;
  uniform float mouseX;
  uniform float mouseY;

  in vec2 coords;

  out vec4 color;

  float PI = 3.14159;
  float TAU = PI*2.0;
  
  float pulser(float period)
  {
    return sin(timer * TAU / period);
  }
  
  void main(void)
  {
    vec3 texcolor = texture2D(colorMap, coords.st).rgb;
    
    vec2 center = coords - vec2(0.5, 0.5);
    center += vec2(mouseX, mouseY);
    
    float mouseDistance = sqrt(mouseX*mouseX + mouseY*mouseY);
    
    float distance = sqrt(center.x*center.x + center.y*center.y) * (1.0 + mouseDistance * mouseDistance * 5);
    float angle = atan(center.x, center.y);
    
    float red = sin(angle*5 + sin(distance*TAU * (3+pulser(12))) * pulser(5)*mouseDistance);
    float green = cos(angle*5 + sin(distance*TAU * (2+pulser(11))) * pulser(6)*2);
    float blue = -sin(angle*5 + sin(distance*TAU * (1+pulser(10))) * pulser(7)*3);
    
    color = vec4(red, green, blue, 1.0);
  }
  