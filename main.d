import std.conv;
import std.exception;
import std.stdio;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl2;

pragma(lib, "DerelictUtil.lib");
pragma(lib, "DerelictSDL2.lib");
pragma(lib, "DerelictGL3.lib");


void main(string args[])
{
  DerelictSDL2.load();
  DerelictGL3.load();
  
  enforce(SDL_Init(SDL_INIT_VIDEO) == 0, "Error initializing SDL");  
  
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
  
  auto window = SDL_CreateWindow("sandbox", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_OPENGL | SDL_WINDOW_BORDERLESS | SDL_WINDOW_SHOWN);
  
  enforce(window !is null, "Error creating window");
  
  auto context = SDL_GL_CreateContext(window);
  SDL_GL_SetSwapInterval(1);
  
  GLVersion glVersion = DerelictGL3.reload();

  writeln("hello world, we just loaded OpenGL version " ~ to!string(glVersion));
}
