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
import std.random;
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



/*class FrameBuffer
{
  uint fbo;
  Texture2D texture;
  int width;
  int height;
  
  this(int width, int height, float[] data)
  {
    this.width = width;
    this.height = height;
    
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    
    if (data != null)
    {
      texture = new Texture2D();
      texture.set_data(data, GL_RGBA, width, height, GL_RGBA, GL_FLOAT, false);
      
      glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);

      enforce(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
  }
  
  void bindAndView()
  {
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    glViewport(0, 0, width, height); // set viewport to size of texture
  }
  
  void unbind()
  {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
  }
}*/
               
               
void main(string args[])
{
  DerelictSDL2.load();
  DerelictSDL2Image.load();
  DerelictGL3.load();
  
  enum int screenWidth = 1024;
  enum int screenHeight = 768;
  
  auto window = setupWindow(screenWidth, screenHeight);

  //string shaderfile = "automata.shader";
  
  //auto shader = new Shader(shaderfile);
  auto textureShader = new Shader("colortwist.shader");
  
  /*enum int width = 512;
  enum int height = 512;
  
  float[] data;
  data.length = width * height * 4;
  data[] = 0.5;
  
  for (int i = 0; i < data.length; i++)
    data[i] = uniform(0.0, 1.0);*/
  
  /*auto frames = [new FrameBuffer(width, height, data)];
  frames ~= new FrameBuffer(width, height, data);
  
  frames[0].texture = Texture2D.from_image("bugship.png");
  frames[1].texture = Texture2D.from_image("bugship.png");*/
  
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
  int counter = 0;
  
  while (running)
  {
    counter++;
    
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
              //shader.remove();
              //collectException(shader = new Shader(shaderfile));
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
    
    /*SysTime checkLastAccessed;
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
    }*/
    
    /*{ // this section draws to one of the framebuffers, not to the screen
      frames[counter % 2].bindAndView();
      
      glClearColor(0.0, 0.5, 0.0, 1.0);
      glClear(GL_COLOR_BUFFER_BIT);
      
      shader.bind();
      
      shader.uniform1f("cellwidth", 1.0 / cast(float)width);
      shader.uniform1f("cellheight", 1.0 / cast(float)height);
      
      frames[(counter+1) % 2].texture.bind_and_activate();
      
      verticesVBO.bind(0, GL_FLOAT, 3);
      texVBO.bind(1, GL_FLOAT, 2);
      
      glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
      
      texVBO.unbind();
      verticesVBO.unbind();
      shader.unbind();
      
      frames[counter % 2].unbind();
    }*/
    
    glClearColor(0.0, 0.0, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, screenWidth, screenHeight);
    
    textureShader.bind();
        
    verticesVBO.bind(0, GL_FLOAT, 3);
    texVBO.bind(1, GL_FLOAT, 2);
    
    texture.bind_and_activate();
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    texture.unbind();
    texVBO.unbind();
    verticesVBO.unbind();
    textureShader.unbind();
    
    SDL_GL_SwapWindow(window);
  }
  
  scope(exit)
  {
    //foreach (frame; frames)
      //frame.texture.remove();
    texture.remove();
    texVBO.remove();
    verticesVBO.remove();
    //shader.remove();
    textureShader.remove();
  }
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
