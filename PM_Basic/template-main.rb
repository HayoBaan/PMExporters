#!/usr/bin/env ruby
# coding: utf-8
##############################################################################
# Creates a basic website gallery for the selected images.
#
# Developed by Hayo Baan (info@hayobaan.com) for CameraBits.
##############################################################################

class BasicGalleryUI

  include PM::Dlg
  include AutoAccessor
  include CreateControlHelper

  def initialize(pm_api_bridge)
    @bridge = pm_api_bridge
  end

  def create_controls(parent_dlg)
    dlg = parent_dlg
    
    create_control(:main_group_box,          GroupBox,        dlg, :label=>"PM Basic Gallery")
    create_control(:main_title_static,       Static,          dlg, :label=>"Page Title:", :align=>"right")
    create_control(:main_title_edit,         EditControl,     dlg, :value=>"{folder}", :multiline=>true)
    create_control(:main_rightclick_check,   CheckBox,        dlg, :label=>"Disable Right Click", :checked=>true)
    create_control(:main_rightclick_static,  Static,          dlg, :label=>"Message:", :align=>"right");
    create_control(:main_rightclick_edit,    EditControl,     dlg, :value=>"© Please contact the author if you want to make use of the image.", :multiline=>true)    

    create_control(:thumb_group_box,         GroupBox,        dlg, :label=>"Thumbnails")
    create_control(:thumb_max_width_static,  Static,          dlg, :label=>"Max. Width:", :align=>"right")
    create_control(:thumb_max_width_edit,    EditControl,     dlg, :value=>"200", :formatter=>"unsigned")
    create_control(:thumb_max_height_static, Static,          dlg, :label=>"Max. Height:", :align=>"right")
    create_control(:thumb_max_height_edit,   EditControl,     dlg, :value=>"200", :formatter=>"unsigned")
    create_control(:thumb_highDPI_check,     CheckBox,        dlg, :label=>"Enable High DPI (@2x) thumbnails?")

    create_control(:image_group_box,         GroupBox,        dlg, :label=>"Images")
    create_control(:image_max_width_static,  Static,          dlg, :label=>"Max. Width:", :align=>"right")
    create_control(:image_max_width_edit,    EditControl,     dlg, :value=>"800", :formatter=>"unsigned")
    create_control(:image_max_height_static, Static,          dlg, :label=>"Max. Height:", :align=>"right")
    create_control(:image_max_height_edit,   EditControl,     dlg, :value=>"800", :formatter=>"unsigned")
    create_control(:image_highDPI_check,     CheckBox,        dlg, :label=>"Enable High DPI (@2x) images?")
    create_control(:preserve_exif_check,     CheckBox,        dlg, :label=>"Preserve EXIF?")
    create_control(:preserve_iptc_check,     CheckBox,        dlg, :label=>"Preserve IPTC?")
    create_control(:watermark_check,         CheckBox,        dlg, :label=>"")
    create_control(:watermark_btn,           WatermarkButton, dlg, :label=>"Watermark...")
    create_control(:image_title_static,      Static,          dlg, :label=>"Image Title:", :align=>"right")
    create_control(:image_title_edit,        EditControl,     dlg, :value=>"{caption}")
    create_control(:image_title_nr_check,    CheckBox,        dlg, :label=>"Prefix with image number?", :checked=>true)
    create_control(:image_subtitle_static,   Static,          dlg, :label=>"Image Subtitle:", :align=>"right")
    create_control(:image_subtitle_edit,     EditControl,     dlg, :value=>"{filenamebase}")
    create_control(:image_delay_static,      Static,          dlg, :label=>"Slideshow Delay:", :align=>"right")
    create_control(:image_delay_edit,        EditControl,     dlg, :value=>"4000", :formatter=>"unsigned")
    create_control(:image_milisecond_static, Static,          dlg, :label=>"(miliseconds)", :align=>"left")

    create_control(:custom_group_box,         GroupBox,        dlg, :label=>"Customization")
    create_control(:custom_font_size_static,  Static,          dlg, :label=>"Font Size:", :align=>"right")
    create_control(:custom_font_size_edit,    EditControl,     dlg, :value=>"14", :formatter=>"unsigned")
    create_control(:custom_font_static,       Static,          dlg, :label=>"Font:", :align=>"right")
    create_control(:custom_font_edit,         EditControl,     dlg, :value=>"\"Helvetica Neue\", \"Segoe UI\", Helvetica, Tahoma, Arial, sans-serif")
    create_control(:custom_foreground_static, Static,          dlg, :label=>"Foreground:", :align=>"right")
    create_control(:custom_foreground_color,  ColorButton,     dlg, :value=>"aaaaaa")
    create_control(:custom_background_static, Static,          dlg, :label=>"Background:", :align=>"right")
    create_control(:custom_background_color,  ColorButton,     dlg, :value=>"000000")
    create_control(:custom_thumb_static,      Static,          dlg, :label=>"Thumb Fill:", :align=>"right")
    create_control(:custom_thumb_color,       ColorButton,     dlg, :value=>"444444")
    create_control(:custom_thumb_f_static,    Static,          dlg, :label=>"Thumb Focused:", :align=>"right")
    create_control(:custom_thumb_f_color,     ColorButton,     dlg, :value=>"333333")
    create_control(:custom_border_static,     Static,          dlg, :label=>"Border:", :align=>"right")
    create_control(:custom_border_color,      ColorButton,     dlg, :value=>"000000")
    create_control(:custom_border_f_static,   Static,          dlg, :label=>"Border Focused:", :align=>"right")
    create_control(:custom_border_f_color,    ColorButton,     dlg, :value=>"eeeeee")
    create_control(:custom_title_fg_static,   Static,          dlg, :label=>"Title Foreground:", :align=>"right")
    create_control(:custom_title_fg_color,    ColorButton,     dlg, :value=>"ffffff")
    create_control(:custom_title_bg_static,   Static,          dlg, :label=>"Title Background:", :align=>"right")
    create_control(:custom_title_bg_color,    ColorButton,     dlg, :value=>"222222")
    
  end

  def layout_controls(container)
    w1 = 110
    l2 = w1+5
    sh = 20
    eh = 24
    deh = 38

    container.inset(15, 5, -15, -5)
    container.layout_with_contents(@main_group_box, 0,0,-1,-1) do |c|
      c.set_prev_right_pad(5).inset(5,25,-5,-5).mark_base
      c.pad_down(5).mark_base
      c << @main_title_static.layout(0, c.base+1, w1, sh)
      c << @main_title_edit.layout(l2, c.base, -1, deh)
      c.pad_down(5).mark_base
      c << @main_rightclick_check.layout(l2, c.base, -1, sh)
      c.pad_down(5).mark_base
      c << @main_rightclick_static.layout(0, c.base+1, w1, sh)
      c << @main_rightclick_edit.layout(l2, c.base, -1, deh)
      c.pad_down(5).mark_base
      c.mark_base.size_to_base
    end

    container.pad_down(5).mark_base
    container.layout_with_contents(@thumb_group_box, 0, container.base, -1, -1) do |c|
      c.set_prev_right_pad(5).inset(5,25,-5,-5).mark_base
      c << @thumb_max_width_static.layout(0, c.base+1, w1, sh)
      c << @thumb_max_width_edit.layout(l2, c.base, 60, eh)
      c << @thumb_max_height_static.layout(l2+60+5, c.base+1, w1, sh)
      c << @thumb_max_height_edit.layout(l2+60+5+w1+5, c.base, 60, eh)
      c.pad_down(5).mark_base
      c << @thumb_highDPI_check.layout(l2, c.base, -1, sh)
      c.pad_down(5).mark_base
      c.mark_base.size_to_base
    end
    
    container.pad_down(5).mark_base
    container.layout_with_contents(@image_group_box, 0, container.base, -1, -1) do |c|
      c.set_prev_right_pad(5).inset(5,25,-5,-5).mark_base
      c << @image_max_width_static.layout(0, c.base+1, w1, sh)
      c << @image_max_width_edit.layout(l2, c.base, 60, eh)
      c << @image_max_height_static.layout(l2+60+5, c.base+1, w1, sh)
      c << @image_max_height_edit.layout(l2+60+5+w1+5, c.base, 60, eh)
      c.pad_down(5).mark_base
      c << @image_highDPI_check.layout(l2, c.base, -1, sh)
      c.pad_down(5).mark_base
      c << @preserve_exif_check.layout(l2, c.base, w1+60, eh)
      c << @preserve_iptc_check.layout(l2+60+5+w1+5, c.base, w1+60, eh)
      c.pad_down(5).mark_base
      c << @watermark_check.layout(l2, c.base, 16, eh)
      c << @watermark_btn.layout(c.prev_right, c.base, 100, eh)      
      c.pad_down(10).mark_base
      c << @image_title_static.layout(0, c.base+1, w1, sh)
      c << @image_title_edit.layout(l2, c.base, -1, eh)
      c.pad_down(5).mark_base
      c << @image_title_nr_check.layout(l2, c.base, -1, sh)
      c.pad_down(5).mark_base
      c << @image_subtitle_static.layout(0, c.base+1, w1, sh)
      c << @image_subtitle_edit.layout(l2, c.base, -1, eh)
      c.pad_down(10).mark_base
      c << @image_delay_static.layout(0, c.base+1, w1, sh)
      c << @image_delay_edit.layout(l2, c.base, 60, eh)
      c << @image_milisecond_static.layout(c.prev_right, c.base+1, -1, sh)
      c.pad_down(5).mark_base
      c.mark_base.size_to_base
    end

    container.pad_down(5).mark_base
    container.layout_with_contents(@custom_group_box, 0, container.base, -1, -1) do |c|
      c.set_prev_right_pad(5).inset(5,25,-5,-5).mark_base
      c << @custom_font_size_static.layout(0, c.base+1, w1, sh)
      c << @custom_font_size_edit.layout(l2, c.base, 60, eh)
      c.pad_down(5).mark_base
      c << @custom_font_static.layout(0, c.base+1, w1, sh)
      c << @custom_font_edit.layout(l2, c.base, -1, eh)
      c.pad_down(5).mark_base
      c << @custom_foreground_static.layout(0, c.base+1, w1, sh)
      c << @custom_foreground_color.layout(l2, c.base, 60, eh)
      c << @custom_background_static.layout(l2+60+5, c.base+1, w1, sh)
      c << @custom_background_color.layout(l2+60+5+w1+5, c.base, 60, eh)
      c.pad_down(5).mark_base
      c << @custom_thumb_static.layout(0, c.base+1, w1, sh)
      c << @custom_thumb_color.layout(l2, c.base, 60, eh)
      c << @custom_thumb_f_static.layout(l2+60+5, c.base+1, w1, sh)
      c << @custom_thumb_f_color.layout(l2+60+5+w1+5, c.base, 60, eh)
      c.pad_down(5).mark_base
      c << @custom_border_static.layout(0, c.base+1, w1, sh)
      c << @custom_border_color.layout(l2, c.base, 60, eh)
      c << @custom_border_f_static.layout(l2+60+5, c.base+1, w1, sh)
      c << @custom_border_f_color.layout(l2+60+5+w1+5, c.base, 60, eh)
      c.pad_down(5).mark_base
      c << @custom_title_fg_static.layout(0, c.base+1, w1, sh)
      c << @custom_title_fg_color.layout(l2, c.base, 60, eh)
      c << @custom_title_bg_static.layout(l2+60+5, c.base+1, w1, sh)
      c << @custom_title_bg_color.layout(l2+60+5+w1+5, c.base, 60, eh)
      c.pad_down(5).mark_base
      c.mark_base.size_to_base
    end

    container.pad_down(5).mark_base     
  end

end

class BasicGallery

  # must include PM::HTMLWebGenTemplate so that
  # the template manager can find our class in
  # ObjectSpace
  include PM::HTMLWebGenTemplate

  def self.template_display_name  # template name shown in dialog list box
    "PM Basic Gallery"
  end
  
  def self.template_description  # shown in dialog box
    "Creates a basic website gallery for the selected images."
  end

  def initialize(pm_api_bridge, num_images)
    @bridge = pm_api_bridge
    @num_images = num_images
  end

  def generate_site(global_spec, progress_dialog)
    raise "generate_site called with no @ui instantiated" unless @ui
    spec = build_template_spec(global_spec, @ui)

    # Copy supporting files
    @bridge.template_src_dest_copy_folder("icons", "icons")
    @bridge.template_src_dest_copy_folder("js", "js")
    @bridge.template_src_dest_copy_folder("css", "css")

    @bridge.template_dest_mkdir("images")
    @bridge.template_dest_mkdir("thumbs")

    thumb_dimensions = {}
    image_dimensions = {}

    # Content of images.js
    imagesJS = "// Image info
var highDPIImages = #{spec.image_highDPI};
var highDPIThumbs = #{spec.thumb_highDPI};
var disableRightClick = #{spec.disable_rightclick};
var rightClickMsg = \"#{escapeHTML(@bridge.expand_vars(spec.rightclick_message, 1))}\";
var slideshowDelay = #{spec.slideshow_delay};
var nrImages = #{spec.num_images};
var images = new Array();
var titles = new Array();
var subtitles = new Array();
var xSizes = new Array(); var ySizes = new Array();
var thumbxSizes = new Array(); var thumbySizes = new Array();
"
    maxX = 0
    maxY = 0

    # We're going to iterate once for num_images
    num_progress_steps = spec.num_images
    progress_dialog.set_range(1, num_progress_steps)

    # Save original size specs
    org_thumb_max_width = spec.thumb_max_width
    org_thumb_max_height = spec.thumb_max_height
    org_image_max_width = spec.image_max_width
    org_image_max_height = spec.image_max_height

    # Generate html, thumbs & images
    # NOTE: prefer to generate both thumbnail and image together
    # for a given image index, to maximize disk cache hits.
    1.upto(spec.num_images) do |cur_img_idx|
      progress_dialog.message = "Generating site, images and thumbnails... (#{cur_img_idx} of #{spec.num_images})"
      
      thumb_dimensions[cur_img_idx] = generate_thumb(spec, cur_img_idx)
      if (spec.thumb_highDPI)
        spec.thumb_max_width *= 2
        spec.thumb_max_height *= 2
        spec.highDPI = true
        generate_thumb(spec, cur_img_idx)
        spec.highDPI = false;
        spec.thumb_max_width = org_thumb_max_width
        spec.thumb_max_height = org_thumb_max_height
      end
      
      image_dimensions[cur_img_idx] = generate_image(spec, cur_img_idx)
      if (spec.image_highDPI)
        spec.image_max_width *= 2
        spec.image_max_height *= 2
        spec.highDPI = true
        generate_image(spec, cur_img_idx)
        spec.highDPI = false;
        spec.image_max_width = org_image_max_width
        spec.image_max_height = org_image_max_height
      end

      image_width, image_height = image_dimensions[cur_img_idx]
      thumb_width, thumb_height = thumb_dimensions[cur_img_idx]
      title = @bridge.expand_vars(spec.image_title, cur_img_idx);
      title = (spec.image_title_prefix_nr ? "\##{cur_img_idx}" + (title != "" ? " – " : "") : "") + title
      title = escapeHTML(title);
      subtitle = @bridge.expand_vars(spec.image_subtitle, cur_img_idx);
      subtitle = escapeHTML(subtitle);
      maxX = [maxX, image_width].max
      maxY = [maxY, image_height].max
      imagesJS << "images[#{cur_img_idx-1}] = \"#{get_image_fname(spec, cur_img_idx)}\";
titles[#{cur_img_idx-1}] = \"#{title}\";
subtitles[#{cur_img_idx-1}] = \"#{subtitle}\";
xSizes[#{cur_img_idx-1}] = #{image_width}; ySizes[#{cur_img_idx-1}] = #{image_height};
thumbxSizes[#{cur_img_idx-1}] = #{thumb_width}; thumbySizes[#{cur_img_idx-1}] = #{thumb_height};
"
      progress_dialog.increment
    end
    imagesJS << "var maxxSize = #{maxX}; var maxySize = #{maxY};
var maxthumbxSize = #{spec.thumb_max_width}; var maxthumbySize = #{spec.thumb_max_height};
"
    @bridge.template_dest_write_file("js/images.js", imagesJS)

    # Content of index.html
    indexHTML = %Q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta content="text/html; charset=UTF-8" http-equiv="content-type" />
  <link rel="stylesheet" href="css/pm_basic.css" type="text/css" />
  <link rel="stylesheet" href="css/custom.css" type="text/css" />
  <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0" />
  <meta http-equiv="imagetoolbar" content="no" />
  <title>#{escapeHTML(@bridge.expand_vars(spec.main_title, 1))}</title>
  <script type="text/javascript" src="http://code.jquery.com/jquery-1.11.3.min.js"></script>
  <script type="text/javascript" src="js/resizebody.js"></script>
  <script type="text/javascript" src="js/norightclick.js"></script>
  <script type="text/javascript" src="js/navhover.js"></script>
  <script type="text/javascript" src="js/images.js"></script>
  <script type="text/javascript" src="js/imagenav.js"></script>
</head>
<body>
<div id="title">
  <h1>#{escapeHTML(@bridge.expand_vars(spec.main_title, 1))}</h1>
  <h2 id="image_title">&nbsp;</h2>
  <h3 id="image_subtitle">&nbsp;</h3>
</div>
<div id="mainbody">
</div>
<div id="fullimagebg" onclick="hideFullImage()"></div>
<div><img id="imageleft" src="icons/left.png" alt="prev" onclick="showPrevNextImg(-1)" /></div>
<div><img id="fullimage_1" src="icons/empty.png" alt="" onclick="hideFullImage()" /></div>
<div><img id="fullimage_0" src="icons/empty.png" alt="" onclick="hideFullImage()" /></div>
<div><img id="fullimage_2" src="icons/empty.png" alt="" onclick="hideFullImage()" /></div>
<div><img id="imageright" src="icons/right.png" alt="next" onclick="showPrevNextImg(1)" /></div>
<div><img id="slideshow" src="icons/play.png" alt="play" title="Play slideshow" onclick="toggleSlideshow()" /></div>
<div id="fullimagetitle_1" onclick="hideFullImage()"></div>
<div id="fullimagetitle_0" onclick="hideFullImage()"></div>
<div id="fullimagetitle_2" onclick="hideFullImage()"></div>
</body>
</html>
}
    @bridge.template_dest_write_file("index.html", indexHTML)

    # Content of custom.css
    customCSS = %Q|/* CSS Customisations */
body {
    font-size: #{spec.custom_font_size}px;
    font-family: #{spec.custom_font};
    color: ##{spec.custom_foreground_color};
    background: ##{spec.custom_background_color};
}
#mainbody td.thumb {
    background-color: ##{spec.custom_thumb_color};
    border-color: ##{spec.custom_border_color};
}
#mainbody td.thumb:hover {
    background-color: ##{spec.custom_thumb_f_color};
    border-color: ##{spec.custom_border_f_color};
}
#fullimagebg {
    background-color: ##{spec.custom_background_color};
}
#fullimagetitle_1, #fullimagetitle_0, #fullimagetitle_2 {
    background: ##{spec.custom_title_bg_color};
}
#fullimagetitle_1 h1, #fullimagetitle_0 h1, #fullimagetitle_2 h1, #fullimagetitle_1 h2, #fullimagetitle_0 h2, #fullimagetitle_2 h2 {
    color: ##{spec.custom_title_fg_color};
}|
    @bridge.template_dest_write_file("css/custom.css", customCSS)
    
  end

  def preflight_settings(global_spec)
    raise "preflight_settings called with no @ui instantiated" unless @ui
    spec = build_template_spec(global_spec, @ui)
  end

  def create_controls(parent_dlg)
    @ui = BasicGalleryUI.new(@bridge)
    @ui.create_controls(parent_dlg)
  end

  def layout_controls(container)
    @ui.layout_controls(container)
  end
  
  def destroy_controls
    @ui = nil
  end

  protected

  def build_template_spec(global_spec, ui)
    spec = AutoStruct.new

    spec.num_images = @num_images

    spec.render_options = global_spec.render_options
    spec.use_original_filenames = global_spec.use_original_filenames

    spec.main_title = ui.main_title_edit.get_text
    spec.disable_rightclick = ui.main_rightclick_check.checked?
    spec.rightclick_message = ui.main_rightclick_edit.get_text

    spec.highDPI = false;
    
    spec.thumb_max_width = ui.thumb_max_width_edit.get_text.to_i
    spec.thumb_max_height = ui.thumb_max_height_edit.get_text.to_i
    spec.thumb_highDPI = ui.thumb_highDPI_check.checked?

    spec.image_max_width = ui.image_max_width_edit.get_text.to_i
    spec.image_max_height = ui.image_max_height_edit.get_text.to_i
    spec.image_highDPI = ui.image_highDPI_check.checked?

    spec.image_preserve_exif = ui.preserve_exif_check.checked?
    spec.image_preserve_iptc = ui.preserve_iptc_check.checked?
    spec.do_watermark = ui.watermark_check.checked?
    spec.watermark_settings = ui.watermark_btn.settings

    spec.image_title = ui.image_title_edit.get_text
    spec.image_title_prefix_nr = ui.image_title_nr_check.checked?
    spec.image_subtitle = ui.image_subtitle_edit.get_text

    spec.slideshow_delay = ui.image_delay_edit.get_text.to_i

    spec.custom_font_size = ui.custom_font_size_edit.get_text.to_i
    spec.custom_font = ui.custom_font_edit.get_text
    spec.custom_foreground_color = ui.custom_foreground_color.get_color_hex
    spec.custom_background_color = ui.custom_background_color.get_color_hex
    spec.custom_thumb_color = ui.custom_thumb_color.get_color_hex
    spec.custom_thumb_f_color = ui.custom_thumb_f_color.get_color_hex
    spec.custom_border_color = ui.custom_border_color.get_color_hex
    spec.custom_border_f_color = ui.custom_border_f_color.get_color_hex
    spec.custom_title_fg_color = ui.custom_title_fg_color.get_color_hex
    spec.custom_title_bg_color = ui.custom_title_bg_color.get_color_hex

    spec
  end

  def append_fname_suffix(path_to_file, suffix)
    fext = File.extname(path_to_file)
    path_to_file[0..(-(fext.length+1))] + suffix + fext
  end

  # Overrides default naming scheme
  def get_image_fname(spec, img_idx)
    if spec.use_original_filenames
      fname = @bridge.get_image_filename(img_idx).dup
      fname << ".jpg" unless fname =~ /\.(jpe|jpg|jpeg)$/i
    else
      fname = "IMG_#{img_idx}.jpg"
    end
    fname = append_fname_suffix(fname, "@2x") if spec.highDPI

    fname
  end
  
end
