pragma(lib, "DerelictUtil.lib");
pragma(lib, "DerelictSDL2.lib");
pragma(lib, "DerelictGL3.lib");


import std.conv;
import std.exception;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

import shaders;
import textures;


void main(string args[])
{
  DerelictSDL2.load();
  DerelictSDL2Image.load();
  DerelictGL3.load();
  
  auto window = setupWindow(800, 600);

  auto shader = makeShader("texture");
  auto vao = makeVAO();
  
  initUniforms(shader);
  
  auto textureId = makeTexture("bugship.png");
  
  bool running = true;
  while (running)
  {
    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
      switch (event.type)
      {
        case SDL_KEYDOWN:
          running = false;
          break;
          
        default:
          break;
      }
    }
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    shader.glUseProgram();
    
    vao.glBindVertexArray();
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindVertexArray(0);
    glUseProgram(0);
    
    SDL_GL_SwapWindow(window);
  }
  
}


SDL_Window* setupWindow(int width, int height)
{
  enforce(SDL_Init(SDL_INIT_VIDEO) == 0, "Error initializing SDL");  
  
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
  
  auto window = SDL_CreateWindow("sandbox", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_OPENGL | SDL_WINDOW_BORDERLESS | SDL_WINDOW_SHOWN);
  
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


uint makeVAO()
{
  immutable float[] vertices = [-0.75, -0.75, 0.0,
                                 0.75,  0.75, 0.0,
                                -0.75,  0.75, 0.0,
                                 
                                 0.75, -0.75, 0.0,
                                -0.75, -0.75, 0.0,
                                 0.75,  0.75, 0.0];
                                 
  immutable float[] texCoords = [0.0, 0.0,
                                 1.0, 1.0,
                                 0.0, 1.0,
                                 
                                 1.0, 0.0,
                                 0.0, 0.0,
                                 1.0, 1.0];
               
  uint vao = 0;
  glGenVertexArrays(1, &vao);
  
  vao.glBindVertexArray();
  {
    uint verticesVBO;
    glGenBuffers(1, &verticesVBO);
    enforce(verticesVBO > 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, verticesVBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.length * GL_FLOAT.sizeof, vertices.ptr, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    uint texCoordsVBO;
    glGenBuffers(1, &texCoordsVBO);
    enforce(texCoordsVBO > 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, texCoordsVBO);
    glBufferData(GL_ARRAY_BUFFER, texCoords.length * GL_FLOAT.sizeof, texCoords.ptr, GL_STATIC_DRAW);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, null);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
  } 
  glBindVertexArray(0);
  
  return vao;
}


void initUniforms(uint shader)
{
  auto colorLocation = shader.glGetUniformLocation("colorMap");
  
  enforce(colorLocation != -1, "Error: main shader did not assign id to sampler2D colorMap");
  
  shader.glUseProgram();
  colorLocation.glUniform1i(0);
  glUseProgram(0);
}
