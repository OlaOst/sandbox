pragma(lib, "DerelictUtil.lib");
pragma(lib, "DerelictSDL2.lib");
pragma(lib, "DerelictGL3.lib");

import std.conv;
import std.exception;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl2;

import shaders;


const string vertexShaderSource=`
#version 330

layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 texCoords;

out vec2 coords;

void main(void)
{
  coords = texCoords.st;
  
  gl_Position = vec4(pos, 1.0);
}
`;

const string fragmentShaderSource=`
#version 330

uniform sampler2D colMap;

in vec2 coords;

void main(void)
{
  vec3 color = texture2D(colMap, coords.st).xyz;
  
  gl_FragColor = vec4((coords.yyx + color), 1.0);
}
`;


void setupWindow(int width, int height)
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
  
  glClearColor(0.0, 0.0, 0.0, 1.0);
  glViewport(0, 0, width, height);
  
  GLVersion glVersion = DerelictGL3.reload();

  writeln("loaded OpenGL version " ~ to!string(glVersion));
}



void main(string args[])
{
  DerelictSDL2.load();
  DerelictGL3.load();
  
  setupWindow(800, 600);
  
  auto shader = makeShader(vertexShaderSource, fragmentShaderSource);
}
