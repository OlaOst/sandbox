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

  in vec2 coords;

  out vec4 color;
  
  vec2 rand(in vec2 coord) //generating random noise
  {
    float noiseX = (fract(sin(dot(coord ,vec2(12.9898,78.233))) * 43758.5453));
    float noiseY = (fract(sin(dot(coord ,vec2(12.9898,78.233)*2.0)) * 43758.5453));

    return vec2(noiseX,noiseY)*0.004;
  }
  
  void main(void)
  {
    vec4 c = texture2D(tex, coords);
    vec4 e = texture2D(tex, vec2(coords.x + cellwidth, coords.y));
    vec4 w = texture2D(tex, vec2(coords.x - cellwidth, coords.y));
    vec4 n = texture2D(tex, vec2(coords.x, coords.y + cellheight));
    vec4 s = texture2D(tex, vec2(coords.x, coords.y - cellheight));
    vec4 ne = texture2D(tex, vec2(coords.x + cellwidth, coords.y + cellheight));
    vec4 sw = texture2D(tex, vec2(coords.x - cellwidth, coords.y - cellheight));
    vec4 se = texture2D(tex, vec2(coords.x + cellwidth, coords.y - cellheight));
    vec4 nw = texture2D(tex, vec2(coords.x - cellwidth, coords.y + cellheight));
        
    int boundaries = 0;
    
    if (e.b > 0.9) { boundaries++; }
    if (w.b > 0.9) { boundaries++; }
    if (n.b > 0.9) { boundaries++; }
    if (s.b > 0.9) { boundaries++; }
    if (ne.b > 0.9) { boundaries++; }
    if (sw.b > 0.9) { boundaries++; }
    
    /*if (e.g > 1.9 || e.b > 0.9) { boundaries++; }
    if (w.g > 1.9 || w.b > 0.9) { boundaries++; }
    if (n.g > 1.9 || n.b > 0.9) { boundaries++; }
    if (s.g > 1.9 || s.b > 0.9) { boundaries++; }
    if (ne.g > 1.9 || ne.b > 0.9) { boundaries++; }
    if (sw.g > 1.9 || sw.b > 0.9) { boundaries++; }*/
    
    float vaporMass = (c.r+e.r+w.r+n.r+s.r+ne.r+sw.r) / 7.0; // + (rand(coords) * 0.001);
    
    float boundaryMass = c.g;
    float crystalMass = c.b;
    
    float boundaryProportion = 0.2;
    float attachBeta = 1.01; // with 1 or 2 boundaries, should be between 1.05 and 3
    float attachAlpha = 0.0;
    float attachDelta = 0.0;
    
    // if boundaries > 0, crystallize proportion of vaporMass
    if (boundaries > 0)
    {
      boundaryMass += (1.0 - boundaryProportion) * vaporMass;
      crystalMass += boundaryProportion * vaporMass;
      vaporMass = 0.0;
    }
    
    if ((boundaries == 1 || boundaries == 2) && boundaryMass > attachBeta)
    {
      boundaryMass = 0.0;
      crystalMass = 1.0;
    }
    else if (boundaries == 3 && boundaryMass > 1.0 || (vaporMass < attachDelta && boundaryMass > attachAlpha))
    //else if (boundaries == 3 && (vaporMass < attachDelta && boundaryMass > attachAlpha))
    {
      boundaryMass = 0.0;
      crystalMass = 1.0;
    }
    else if (boundaries >= 4)
    {
      boundaryMass = 0.0;
      crystalMass = 1.0;
    }
    
    color = vec4(vaporMass, boundaryMass, crystalMass, 1.0);
  }
  