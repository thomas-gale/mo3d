from python import Python, PythonObject
from memory import UnsafePointer

struct PIL:
    var pil: PythonObject
    var pil_imagefont: PythonObject
    var pil_imagedraw: PythonObject

    def __init__(inout self):
        self.pil = Python.import_module("PIL")
        self.pil_imagefont = Python.import_module("PIL.ImageFont")
        self.pil_imagedraw = Python.import_module("PIL.ImageDraw")

    def _text_to_image(self, text: String) -> PythonObject:
        font = self.pil_imagefont.load_default()
        bbox = font.getbbox(text)
        size = (bbox[2] - bbox[0], bbox[3] - bbox[1] + 2) # Hack +2 for the baseline
        image = self.pil.Image.new("RGB", size, (255, 255, 255))
        draw = self.pil_imagedraw.Draw(image)
        draw.text((0, 0), text, font=font, fill=(0, 0, 0))
        return image

    def _image_to_pixels(self, image: PythonObject) -> List[UInt8]:
        rgb_image = image.convert("RGB")
        pixel_data = rgb_image.tobytes()
        result = List[SIMD[DType.uint8, 1]]()
        for i in range(len(pixel_data)):
            result.append(atof(str(pixel_data[i])).cast[DType.uint8]())
        return result

    def render_to_texture[T: DType](self, inout texture: UnsafePointer[Scalar[T]], texture_width: Int, text_x: Int, text_y: Int, text: String):
        txt_img = self._text_to_image(text)
        pixels = self._image_to_pixels(txt_img)
        text_width = txt_img.width
        text_height = txt_img.height
        
        for y in range(text_height):
                for x in range(text_width):
                    var texture_index = ((text_y + y) * texture_width + (text_x + x)) * 4 # RGBA
                    var text_index = (y * text_width + x) * 3  # RGB
                    for c in range(3):  # RGB channels
                        var text_color = pixels[text_index + c].cast[T]() / 255.0
                        (texture + texture_index + c)[] = text_color
