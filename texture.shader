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

  in vec2 coords;

  out vec4 color;

  void main(void)
  {
    color = texture2D(colorMap, coords.st).rgba;
    
    vec2 center = coords - vec2(0.5, 0.5);
    
    float dist = sqrt(center.x*center.x + center.y*center.y);
    
    const float threshold = (1.0 + sin(timer)) * 0.4*dist + 0.0 + (sin(dist * 3.141)+1.0)*0.1;
    
    if (color.r > threshold && color.g > threshold && color.b > threshold)
      discard;
  }
