vertex:
  layout(location = 0) in vec3 position;
  layout(location = 1) in vec2 texCoords;

  out vec2 coords;

  void main(void)
  {
    coords = texCoords.st;
    
    mat2 rot = mat2(0.707, -0.707, 0.707, 0.707); // rotate 45 degrees
    
    position.xy = rot * position.xy;
    
    position.y *= sqrt(3);
    
    gl_Position = vec4(position, 1.0);
  }
  
fragment:
  uniform sampler2D tex;
  in vec2 coords;

  out vec4 color;

  void main(void)
  {
    color = texture2D(tex, coords).rgba;
  }
