from python import Python, PythonObject


struct PIL:
    var pil: PythonObject
    var pil_imagefont: PythonObject
    var pil_imagedraw: PythonObject

    def __init__(inout self):
        self.pil = Python.import_module("PIL")
        self.pil_imagefont = Python.import_module("PIL.ImageFont")
        self.pil_imagedraw = Python.import_module("PIL.ImageDraw")

    def render_text(self, text: String) -> PythonObject:
        font = self.pil_imagefont.load_default()
        bbox = font.getbbox(text)
        print(str(bbox))
        size = (bbox[2] - bbox[0], bbox[3] - bbox[1] + 2) # Hack +2 for the baseline
        image = self.pil.Image.new("RGB", size, (255, 255, 255))
        draw = self.pil_imagedraw.Draw(image)
        draw.text((0, 0), text, font=font, fill=(0, 0, 0))
        return image

    def pil_image_to_list(self, image: PythonObject) -> List[UInt8]:
        rgb_image = image.convert("RGB")
        pixel_data = rgb_image.tobytes()
        result = List[SIMD[DType.uint8, 1]]()
        for i in range(len(pixel_data)):
            result.append(atof(str(pixel_data[i])).cast[DType.uint8]())
        return result
