
Namespace mojo.graphics.glutil

Private

Global bindings:=New IntStack

Public

#rem monkeydoc @hidden
#end
Global glGraphicsSeq:Int=1

#rem monkeydoc @hidden
#end
Function glCheck()
	Local err:=glGetError()
	If err=GL_NO_ERROR Return
	RuntimeError( "GL ERROR! err="+err )
End

#rem monkeydoc @hidden
#end
Function glPushTexture:Void( target:GLenum,texture:GLuint )

	Assert( target=GL_TEXTURE_2D Or target=GL_TEXTURE_CUBE_MAP )
	
	Local binding:Int
	glGetIntegerv( target=GL_TEXTURE_2D ? GL_TEXTURE_BINDING_2D Else GL_TEXTURE_BINDING_CUBE_MAP,Varptr binding )

	bindings.Push( binding )
	bindings.Push( target )
	
	glBindTexture( target,texture )
End

#rem monkeydoc @hidden
#end
Function glPopTexture:Void()
	
	Local target:=bindings.Pop()
	Assert( target=GL_TEXTURE_2D Or target=GL_TEXTURE_CUBE_MAP )
	
	glBindTexture( target,bindings.Pop() )
End

#rem monkeydoc @hidden
#end
Function glPushBuffer( target:GLenum,buf:GLuint )
	
	Assert( target=GL_ARRAY_BUFFER Or target=GL_ELEMENT_ARRAY_BUFFER )
	
	Local binding:Int
	glGetIntegerv( target=GL_ARRAY_BUFFER ? GL_ARRAY_BUFFER_BINDING Else GL_ELEMENT_ARRAY_BUFFER_BINDING,Varptr binding )
	
	bindings.Push( binding )
	bindings.Push( target )
	
	glBindBuffer( target,buf )
End

#rem monkeydoc @hidden
#end
Function glPopBuffer()
	
	Local target:=bindings.Pop()
	Assert( target=GL_ARRAY_BUFFER Or target=GL_ELEMENT_ARRAY_BUFFER )
	
	glBindBuffer( target,bindings.Pop() )
End

#rem monkeydoc @hidden
#end
Function glPushFramebuffer:Void( target:GLenum,framebuf:GLuint )
	
	Assert( target=GL_FRAMEBUFFER )
	
	Local binding:Int
	glGetIntegerv( GL_FRAMEBUFFER_BINDING,Varptr binding )
	
	bindings.Push( framebuf )
	bindings.Push( target )
	
	glBindFramebuffer( target,framebuf )
End

#rem monkeydoc @hidden
#end
Function glPopFramebuffer:Void()
	
	Local target:=bindings.Pop()
	Assert( target=GL_FRAMEBUFFER )
	
	glBindFramebuffer( target,bindings.Pop() )
End

#rem monkeydoc @hidden
#end
Function glCompile:Int( type:Int,source:String )
	
#If __TARGET__="windows" Or __TARGET__="emscripten"
	Const prefix:="
#extension GL_EXT_draw_buffers : require	
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif
"
#Else if __TARGET__="linux"
	Const prefix:="
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif
"
#Else
	Const prefix:="
"
#Endif

	source=prefix+source
	
	Local shader:=glCreateShader( type )
	glShaderSourceEx( shader,source )
	glCompileShader( shader )
	
	Local status:Int
	glGetShaderiv( shader,GL_COMPILE_STATUS,Varptr status )
	If Not status
		
		Local lines:=source.Split( "~n" )
		
		For Local i:=0 Until lines.Length
			Print (i+1)+":~t"+lines[i]
		Next
		
		RuntimeError( "Failed to compile fragment shader:"+glGetShaderInfoLogEx( shader ) )
	Endif
	Return shader
End

#rem monkeydoc @hidden
#end
Function glLink:Void( program:Int )
	glLinkProgram( program )

	Local status:Int
	glGetProgramiv( program,GL_LINK_STATUS,Varptr status )
	If Not status
		RuntimeError( "Failed to link program:"+glGetProgramInfoLogEx( program ) )
	Endif
End
