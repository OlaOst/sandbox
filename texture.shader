<vertex>
  #version 330

  layout(location = 0) in vec3 position;
  layout(location = 1) in vec2 texCoords;

  out vec2 coords;

  void main(void)
  {
    coords = texCoords.st;
    
    gl_Position = vec4(position, 1.0);
  }
</vertex>

<fragment>
  #version 330

  uniform sampler2D colorMap;
  uniform float timer;

  in vec2 coords;

  out vec4 color;

  void main(void)
  {
    color = texture2D(colorMap, coords.st).rgba;
    
    const float threshold = 0.75;
    
    if (color.r > threshold && color.g > threshold && color.b > threshold)
      color = (color.rgb, 0.88);
  }
</fragment>
