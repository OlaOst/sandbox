module textures;

import std.exception;
import std.file;
import std.stdio;
import std.string;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.sdl2.image;


uint makeTexture(string fileName)
{
  enforce(exists(fileName), "Could not find file " ~ fileName);

  auto surface = IMG_Load(fileName.toStringz());
  
  enforce(surface, "Error loading image " ~ fileName);
  
  glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
  
  uint textureId;
  glGenTextures(1, &textureId);
  enforce(textureId > 0, "Error assigning texture id");
  
  glBindTexture(GL_TEXTURE_2D, textureId);
  
  int mode = GL_RGB;
  
  if (surface.format.BytesPerPixel == 4)
    mode = GL_RGBA;
    
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

  glTexImage2D(GL_TEXTURE_2D, 0, mode, surface.w, surface.h, 0, mode, GL_UNSIGNED_BYTE, surface.flip().pixels);

  surface.SDL_FreeSurface();
  
  return textureId;
}


//thanks to tito http://stackoverflow.com/questions/5862097/sdl-opengl-screenshot-is-black 
SDL_Surface* flip(SDL_Surface* surface) 
{ 
  SDL_Surface* result = SDL_CreateRGBSurface(surface.flags, surface.w, surface.h, 
                                             surface.format.BytesPerPixel * 8, surface.format.Rmask, surface.format.Gmask, 
                                             surface.format.Bmask, surface.format.Amask); 
  
  ubyte* pixels = cast(ubyte*) surface.pixels; 
  ubyte* rpixels = cast(ubyte*) result.pixels; 
  uint pitch = surface.pitch;
  uint pxlength = pitch * surface.h; 
  
  assert(result != null); 

  for(uint line = 0; line < surface.h; ++line) 
  {  
    uint pos = line * pitch; 
    rpixels[pos..pos+pitch] = pixels[(pxlength-pos)-pitch..pxlength-pos]; 
  } 

  return result; 
}
