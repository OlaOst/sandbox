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
  uniform sampler2D tex;
  uniform float cellwidth;
  uniform float cellheight;

  in vec2 texCoords;

  out vec4 color;
  
  void main(void)
  {
    vec4 c = texture2D(tex, texCoords);
    vec4 e = texture2D(tex, vec2(texCoords.x + cellwidth, texCoords.y));
    vec4 w = texture2D(tex, vec2(texCoords.x - cellwidth, texCoords.y));
    vec4 n = texture2D(tex, vec2(texCoords.x, texCoords.y + cellheight));
    vec4 s = texture2D(tex, vec2(texCoords.x, texCoords.y - cellheight));
    vec4 ne = texture2D(tex, vec2(texCoords.x + cellwidth, texCoords.y + cellheight));
    vec4 se = texture2D(tex, vec2(texCoords.x + cellwidth, texCoords.y - cellheight));
    vec4 nw = texture2D(tex, vec2(texCoords.x - cellwidth, texCoords.y + cellheight));
    vec4 sw = texture2D(tex, vec2(texCoords.x - cellwidth, texCoords.y - cellheight));
    
    int count = 0;
    
    if (e.r > 0.9) { count++; }
    if (w.r > 0.9) { count++; }
    if (n.r > 0.9) { count++; }
    if (s.r > 0.9) { count++; }
    if (ne.r > 0.9) { count++; }
    if (se.r > 0.9) { count++; }
    if (nw.r > 0.9) { count++; }
    if (sw.r > 0.9) { count++; }
    
    if ((c.r < 0.1 && count == 3) || (c.r > 0.9 && (count == 2 || count == 3)))
    {
      color = vec4(1.0, 1.0, 1.0, 1.0);
    }
    else
    {
      color = vec4(0.0, 0.0, 0.0, 1.0);
    }
  }
  