module shaders;

import std.exception;
import std.file;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;


int makeShader(string shaderName)
{
  string vertexShader = shaderName ~ ".vertexshader";
  string fragmentShader = shaderName ~ ".fragmentshader";
  
  enforce(exists(vertexShader), "Could not find file " ~ vertexShader);
  enforce(exists(fragmentShader), "Could not find file " ~ fragmentShader);
  
  return makeShader(vertexShader.readText(), fragmentShader.readText());
}

int makeShader(string vertexShaderSource, string fragmentShaderSource)
{ 
  auto shader = glCreateProgram();
  enforce(shader > 0, "Error assigning main shader program id");
  
  auto vertexShader = glCreateShader(GL_VERTEX_SHADER);
  enforce(vertexShader > 0, "Error assigning vertex shader program id");
  
  auto vertexShaderZ = toStringz(vertexShaderSource);
  vertexShader.glShaderSource(1, &vertexShaderZ, null);
  
  vertexShader.glCompileShader();
  
  int status;
  vertexShader.glGetShaderiv(GL_COMPILE_STATUS, &status);
  enforce(status != GL_FALSE, 
         {
           int errorLength;
           vertexShader.glGetShaderiv(GL_INFO_LOG_LENGTH, &errorLength);
           char[] error = new char[errorLength];
           vertexShader.glGetShaderInfoLog(errorLength, null, error.ptr);
           
           writeln(error);
         });

         
  auto fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  enforce(fragmentShader > 0, "Error assigning fragment shader program id");
  
  auto fragmentShaderZ = toStringz(fragmentShaderSource);
  fragmentShader.glShaderSource(1, &fragmentShaderZ, null);
  
  fragmentShader.glCompileShader();
  
  fragmentShader.glGetShaderiv(GL_COMPILE_STATUS, &status);
  enforce(status != GL_FALSE, 
         {
           int errorLength;
           fragmentShader.glGetShaderiv(GL_INFO_LOG_LENGTH, &errorLength);
           char[] error = new char[errorLength];
           fragmentShader.glGetShaderInfoLog(errorLength, null, error.ptr);
           
           writeln(error);
         });
         
         
  shader.glAttachShader(vertexShader);
  shader.glAttachShader(fragmentShader);
  shader.glLinkProgram();
  shader.glGetShaderiv(GL_LINK_STATUS, &status);
  enforce(status != GL_FALSE, 
         {
           int errorLength;
           shader.glGetShaderiv(GL_INFO_LOG_LENGTH, &errorLength);
           char[] error = new char[errorLength];
           shader.glGetShaderInfoLog(errorLength, null, error.ptr);
           
           writeln(error);
         });
         
  
  return shader;
}
