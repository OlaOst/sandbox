module shaders;

import std.algorithm;
import std.conv;
import std.exception;
import std.file;
import std.range;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;


uint buildShader(string shaderName)
{
  scope(failure) writeln("Failed to build shader " ~ shaderName);
  
  string shaderFile = shaderName ~ ".shader";
  
  enforce(exists(shaderFile), "Could not find file " ~ shaderFile);
  
  string shaderSource = shaderFile.readText();
  
  enforce(!shaderSource.find("<vertex>").empty && !shaderSource.find("</vertex>").empty, "Could not find vertex shader section in " ~ shaderFile);
  enforce(!shaderSource.find("<fragment>").empty && !shaderSource.find("</fragment>").empty, "Could not find fragment shader section in " ~ shaderFile);
    
  string vertexShader = shaderSource.findSplitAfter("<vertex>")[1].until("</vertex>").to!string();
  string fragmentShader = shaderSource.findSplitAfter("<fragment>")[1].until("</fragment>").to!string();
  
  try
  {
    return buildShaderProgram(vertexShader, fragmentShader);
  }
  catch (Exception e)
  {
    writeln("Error reading shader file: " ~ e.text);
    return -1;
  }
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
  enforce(shader > 0, "Error assigning " ~ (shaderType==GL_VERTEX_SHADER?"vertex":
                                            shaderType==GL_FRAGMENT_SHADER?"fragment":
                                            shaderType==GL_GEOMETRY_SHADER?"geometry":
                                            shaderType.to!string()) ~ " shader program id");
  
  auto shaderZ = shaderSource.toStringz();
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
