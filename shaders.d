module shaders;

import std.conv;
import std.exception;
import std.file;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;


uint buildShader(string shaderName)
{
  string vertexShader = shaderName ~ ".vertexshader";
  string fragmentShader = shaderName ~ ".fragmentshader";
  
  enforce(exists(vertexShader), "Could not find file " ~ vertexShader);
  enforce(exists(fragmentShader), "Could not find file " ~ fragmentShader);
  
  return buildShaderProgram(vertexShader.readText(), fragmentShader.readText());
}

uint buildShaderProgram(string vertexShaderSource, string fragmentShaderSource)
{ 
  auto shader = glCreateProgram();
  enforce(shader > 0, "Error assigning main shader program id");
         
  shader.glAttachShader(vertexShaderSource.buildShader(GL_VERTEX_SHADER));
  shader.glAttachShader(fragmentShaderSource.buildShader(GL_FRAGMENT_SHADER));
  shader.glLinkProgram();
  
  shader.check();
  
  return shader;
}

uint buildShader(string shaderSource, GLenum shaderType)
{
  auto shader = glCreateShader(shaderType);
  enforce(shader > 0, "Error assigning " ~ (shaderType==GL_VERTEX_SHADER?"vertex":shaderType==GL_FRAGMENT_SHADER?"fragment":shaderType==GL_GEOMETRY_SHADER?"geometry":to!string(shaderType)) ~ " shader program id");
  
  auto shaderZ = toStringz(shaderSource);
  shader.glShaderSource(1, &shaderZ, null);
  
  shader.glCompileShader();
  shader.check();
         
  return shader;
}

void check(uint shader)
{
  int status;
  shader.glGetShaderiv(GL_LINK_STATUS, &status);
  enforce(status != GL_FALSE, 
         {
           int errorLength;
           shader.glGetShaderiv(GL_INFO_LOG_LENGTH, &errorLength);
           char[] error = new char[errorLength];
           shader.glGetShaderInfoLog(errorLength, null, error.ptr);
           
           writeln(error);
         });
}
