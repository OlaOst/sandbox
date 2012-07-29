module main;

pragma(lib, "DerelictUtil.lib");
pragma(lib, "DerelictSDL2.lib");
pragma(lib, "DerelictGL3.lib");
pragma(lib, "Glamour.lib");

import core.time;
import std.conv;
import std.datetime;
import std.exception;
import std.file;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

import glamour.shader;
import glamour.texture;
import glamour.vbo;


immutable float[] vertices = [-0.75, -0.75, 0.0,
                              -0.75,  0.75, 0.0,
                               0.75,  0.75, 0.0,
                               0.75, -0.75, 0.0];
                               
immutable float[] texCoords = [0.0, 0.0,
                               0.0, 1.0,
                               1.0, 1.0,
                               1.0, 0.0];


void main(string args[])
{
  DerelictSDL2.load();
  DerelictSDL2Image.load();
  DerelictGL3.load();
  
  auto window = setupWindow(1024, 768);

  string shaderfile = "colortwist.shader";
  
  auto shader = new Shader(shaderfile);
  auto texture = Texture2D.from_image("bugship.png");
  
  auto verticesVBO = new Buffer(vertices);
  auto texVBO = new Buffer(texCoords);
  
  float mouseX = 0.0;
  float mouseY = 0.0;
  
  StopWatch timer;
  timer.start();
  
  SysTime shaderLastModified;
  SysTime shaderLastChecked;
  
  bool running = true;
  while (running)
  {
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
      switch (event.type)
      {
        case SDL_KEYDOWN:
          switch (event.key.keysym.sym)
          {
            case SDLK_ESCAPE:
              running = false;
              break;
              
            case SDLK_F5:
              shader.remove();
              collectException(shader = new Shader(shaderfile));
              break;
              
            default:
              break;
          }
          break;
          
        case SDL_MOUSEMOTION:
          mouseX = event.motion.x * (2.0 / 1024) - 1.0;
          mouseY = event.motion.y * (-2.0 / 768) + 1.0;
          writeln("setting mouse to " ~ to!string(mouseX) ~ "," ~ to!string(mouseY));
          break;
          
        default:
          break;
      }
    }
    
    SysTime checkLastAccessed;
    SysTime checkLastModified;
    // check periodically if the shader file has been modified
    if ((Clock.currTime() - shaderLastChecked).total!"msecs" > 200)
    {
      shaderLastChecked = Clock.currTime();
      
      getTimes(cast(const(char[]))shaderfile, checkLastAccessed, checkLastModified);
      if (checkLastModified > shaderLastModified)
      {
        shaderLastModified = checkLastModified;
        
        shader.remove();
        shader = new Shader(shaderfile);
      }
    }
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    shader.bind();
    verticesVBO.bind(0, GL_FLOAT, 3);
    texVBO.bind(1, GL_FLOAT, 2);
    texture.bind_and_activate();
    
    shader.uniform1f("timer", timer.peek().msecs * 0.001);
    shader.uniform1f("mouseX", mouseX);
    shader.uniform1f("mouseY", mouseY);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    texture.unbind();
    texVBO.unbind();
    verticesVBO.unbind();
    shader.unbind();
    
    SDL_GL_SwapWindow(window);
  }
  
  texture.remove();
  texVBO.remove();
  verticesVBO.remove();
  shader.remove();
}


SDL_Window* setupWindow(int width, int height)
{
  enforce(SDL_Init(SDL_INIT_VIDEO) == 0, "Error initializing SDL");  
  
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
  
  auto window = SDL_CreateWindow("sandbox", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
  
  enforce(window !is null, "Error creating window");
  scope(failure) SDL_Quit();
  
  auto context = SDL_GL_CreateContext(window);
  SDL_GL_SetSwapInterval(1);
  
  glClearColor(0.0, 0.0, 0.5, 1.0);
  glViewport(0, 0, width, height);
  
  GLVersion glVersion = DerelictGL3.reload();

  writeln("loaded OpenGL version " ~ to!string(glVersion));  
  
  return window;
}
