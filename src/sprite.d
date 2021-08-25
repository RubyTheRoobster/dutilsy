/*sprite.d by Ruby The Roobster*/
/*Version 0.3.5 Release*/
/*Last Update: 08/23/2021*/
/*Module for sprites in the D Programming Language 2.0*/

/*    This file is part of dutils.

    dutils is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    dutils is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with dutils.  If not, see <https://www.gnu.org/licenses/>.*/

module dutils.sprite;

version(USE_BUILT_IN_SPRITES)	{ //Use built in sprites(garbage .spr format coded by me, that still needs an editor: Editor using GtKD for .spr comes out later this year, if I can get myself to do it)...
	public struct Color	{
		ubyte r = 0;
		ubyte g = 0;
		ubyte b = 0;
		ubyte a = 255;
		void opAssign(Color rhs)	{
			this.r = rhs.r;
			this.g = rhs.g;
			this.b = rhs.b;
			this.a = rhs.a;
		}
	}
	
	public struct Pixel	{
		ushort x;
		ushort y;
		void opAssign(Pixel rhs)	{
			this.x = rhs.x;
			this.y = rhs.y;
		}
	}
	
	public struct Sprite	{
		Color[] colors;
		Pixel[][] pixels;
		invariant()	{
			assert(colors.length == pixels.length, "Assertion failure: Sprite.colors.length and Sprite.pixels.length must always be equal...");
		}
		void opAssign(Sprite rhs)	{
			this.colors.length = rhs.colors.length;
			this.pixels.length = rhs.pixels.length;
			foreach(i;0 .. this.colors.length)	{
				this.colors[i] = rhs.colors[i];
			}
			foreach(i;0 .. this.pixels.length)	{
				this.pixels[i].length = rhs.pixels[i].length;
				foreach(j;0 .. this.pixels[i].length)	{
					this.pixels[i][j] = rhs.pixels[i][j];
				}
			}
		}
		package void ChangeLengths(uint c)	{ //Change both lengths so invariant doesn't get triggered...
			this.colors.length = c;
			this.pixels.length = c;
		}
	}
	
	public ubyte ReadSpriteFromFile(immutable(char)[] filename, ref Sprite dest)	{ //Reads a sprite in my made up .spr format(trash, why does this even exist)
		import std.stdio;
		File file = File(filename, "r");
		import std.string;
		import std.format;
		import std.conv : to;
		string buffer;
		bool first = true;
		long i = -1;
		uint j = 0;
		while(!file.eof())	{
			buffer = file.readln();
			buffer = strip(buffer);
			switch(buffer)	{
				case "RGB":
					i += 1;
					j = 0;
					dest.ChangeLengths(cast(uint)i+1);
					dest.pixels[i].length = 0;
					foreach(k;0 .. 2)	{
						buffer = file.readln(',');
						buffer = cast(string)parse(cast(char[])buffer);
						switch(k)	{
							case 0:
								dest.colors[cast(uint)i].r = to!ubyte(buffer);
								break;
							case 1:
								dest.colors[cast(uint)i].g = to!ubyte(buffer);
								break;
							default:
								break;
						}
					}
					buffer = file.readln();
					buffer = strip(buffer);
					dest.colors[cast(uint)i].b = to!ubyte(buffer);
					break;
				case "RGBA":
					i += 1;
					j = 0;
					dest.ChangeLengths(cast(uint)i+1);
					dest.pixels[i].length = 0;
					foreach(k;0 .. 3)	{
						buffer = file.readln(',');
						buffer = cast(string)parse(cast(char[])buffer);
						switch(k)	{
							case 0:
								dest.colors[cast(uint)i].r = to!ubyte(buffer);
								break;
							case 1:
								dest.colors[cast(uint)i].g = to!ubyte(buffer);
								break;
							case 2:
								dest.colors[cast(uint)i].b = to!ubyte(buffer);
								break;
							default:
								break;
						}
					}
					buffer = file.readln();
					buffer = strip(buffer);
					dest.colors[cast(uint)i].a = to!ubyte(buffer);
					break;
				case "PIXEL":
					dest.pixels[i].length += 1;
					buffer = file.readln(',');
					buffer = cast(string)parse(cast(char[])buffer);
					dest.pixels[i][j].x = to!ushort(buffer);
					buffer = file.readln();
					buffer = strip(buffer);
					dest.pixels[i][j].y = to!ushort(buffer);
					j+=1;
					break;
				case "END":
					goto Close;
					break;
				default:
					throw new Exception(format("Invalid Statement: %s", buffer));
					break;
			}
		}
		Close:
		file.close();
		return 0;
		assert(0);
	}
	
	package char[] parse(char[] toparse)	{
		foreach(i;0 .. toparse.length)	{
			if(toparse[i] == ',')	{
				for(uint j = cast(uint)i;j < (toparse.length-1);j++)	{
					toparse[j] = toparse[j+1];
				}
				toparse.length-=1;
			}
		}
	return toparse;
	}
}

version(USE_OTHER_SPRITE)	{ //If the user wants to work with sprites their own way...
	public alias Sprite = uint function();
}

version(USE_FILE_SPRITE)	{  //If the user wants to read the sprites from a file and do it that way...
	public alias Sprite = wchar[];
}
