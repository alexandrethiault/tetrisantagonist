from PIL.Image import open as ImOpen

im = ImOpen("tetris_blocs.bmp")
fi = open("tetris_blocs.txt", "w")

for i in range(im.height):
    line = ""
    for j in range(im.width):
        pixel = im.getpixel((j,i))
        if pixel[0] == 0:
            line += "X"
        elif pixel[0] == 255:
            line += " "
        else:
            line += "."
    line+="\n"
    fi.write(line)
fi.close()