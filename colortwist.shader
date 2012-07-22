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
    vec3 texcolor = texture2D(colorMap, coords.st).rgb;
    
    vec2 middle = vec2(coords.x - 0.5, coords.y - 0.5);
    
    float distance = sqrt(middle.x*middle.x + middle.y*middle.y);

    float sinTime = sin(timer * 0.12) * 2.5;
    float cosTime = cos(timer * 0.05) * 2.5;
    
    float angle = atan(middle.x, middle.y);

    float twist = sin(distance * 3.14159 * 2 * sinTime) * 1.5 + 0.5;
    
    float spin1 = sin((angle+sinTime) * 3 + twist);
    float spin2 = sin(distance * 3.14159 * 2 * cosTime);

    float x = distance * cos(angle + twist * sin(timer * 0.3)*1.3) * 31;
    float y = distance * sin(angle + twist * cos(timer * 0.1)*1.3) * 13;
    
    //gl_FragColor = vec4(reversepolar, 1.0-(spin1 * -spin2), spin2 - spin1, 1.0);
    //gl_FragColor = vec4((y/x) / (x/y), spin2/y, x/spin1, 1.0);
    color = vec4(texcolor, 1.0) * vec4(coords.x/coords.y, coords.y/coords.x, coords.x/coords.y, 1.0) * vec4((y/x) / (x/y), spin2/y, x/spin1, 1.0);
    //color = vec4(coords.x/coords.y, coords.y/coords.x, coords.x/coords.y, 1.0) * vec4((y/x) / (x/y), spin2/y, x/spin1, 1.0);
  }
</fragment>
