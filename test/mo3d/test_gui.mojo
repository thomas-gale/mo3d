from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.gui.pil import PIL


fn test_import_pil() raises:
    var p = PIL()
    assert_true(p.pil is not None)


fn test_pil_render_text() raises:
    var p = PIL()
    var txt_img = p._text_to_image("Hello, World!")
    print(str(txt_img))
    assert_true(txt_img is not None)


fn test_pil_image_to_list() raises:
    var p = PIL()
    var txt_img = p._text_to_image("Hello, World!")
    var width = txt_img.width
    var height = txt_img.height
    var pixels = p._image_to_pixels(txt_img)
    assert_true(len(pixels) == width * height * 3)
