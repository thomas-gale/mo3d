from testing import assert_true, assert_false, assert_equal, assert_almost_equal

from mo3d.gui.pil import PIL


fn test_import_pil() raises:
    var p = PIL()
    assert_true(p.pil is not None)


fn test_pil_render_text() raises:
    var p = PIL()
    var txt = p.render_text("Hello, World!")
    print(str(txt))
    assert_true(txt is not None)


fn test_pil_image_to_list() raises:
    var p = PIL()
    var txt_img = p.render_text("Hello, World!")
    var width = txt_img.width
    var height = txt_img.height
    var img = p.pil_image_to_list(txt_img)
    assert_true(len(img) == width * height * 3)
