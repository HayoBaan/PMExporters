#!/usr/bin/env ruby
##############################################################################
# Creates images and thumbnails for use on e.g., a website.
#
# Developed by Hayo Baan
##############################################################################

class WebSiteUpdateUI

  include PM::Dlg
  include AutoAccessor
  include CreateControlHelper

  def initialize(pm_api_bridge)
    @bridge = pm_api_bridge
  end

  def create_controls(parent_dlg)
    dlg = parent_dlg

    create_control(:type_group_box,          GroupBox,        dlg, :label=>"UpdateWeb")
    create_control(:type_static,             Static,          dlg, :label=>"Update type:", :align=>"right")
    create_control(:type_edit,               EditControl,     dlg, :value=>"Enter update type description")

    create_control(:thumb_group_box,         GroupBox,        dlg, :label=>"Thumbnails")
    create_control(:thumb_check,             CheckBox,        dlg, :label=>"Generate thumbnails?", :checked=>true)
    create_control(:thumb_max_width_static,  Static,          dlg, :label=>"Max. Width:", :align=>"right")
    create_control(:thumb_max_width_edit,    EditControl,     dlg, :value=>"200", :formatter=>"unsigned")
    create_control(:thumb_max_height_static, Static,          dlg, :label=>"Max. Height:", :align=>"right")
    create_control(:thumb_max_height_edit,   EditControl,     dlg, :value=>"200", :formatter=>"unsigned")
    create_control(:thumb_highDPI_check,     CheckBox,        dlg, :label=>"Enable High DPI (@2x) thumbnails?")

    create_control(:image_group_box,         GroupBox,        dlg, :label=>"Images")
    create_control(:image_check,             CheckBox,        dlg, :label=>"Generate images?", :checked=>true)
    create_control(:image_max_width_static,  Static,          dlg, :label=>"Max. Width:", :align=>"right")
    create_control(:image_max_width_edit,    EditControl,     dlg, :value=>"800", :formatter=>"unsigned")
    create_control(:image_max_height_static, Static,          dlg, :label=>"Max. Height:", :align=>"right")
    create_control(:image_max_height_edit,   EditControl,     dlg, :value=>"800", :formatter=>"unsigned")
    create_control(:image_highDPI_check,     CheckBox,        dlg, :label=>"Enable High DPI (@2x) images?")
    create_control(:preserve_exif_check,     CheckBox,        dlg, :label=>"Preserve EXIF?")
    create_control(:preserve_iptc_check,     CheckBox,        dlg, :label=>"Preserve IPTC?")
    create_control(:watermark_check,         CheckBox,        dlg, :label=>"")
    create_control(:watermark_btn,           WatermarkButton, dlg, :label=>"Watermark...")

  end

  def layout_controls(container)
    w1 = 110
    l2 = w1+5
    sh = 20
    eh = 24

    container.inset(15, 5, -15, -5)
    container.layout_with_contents(@type_group_box, 0,0,-1,-1) do |c|
      c.set_prev_right_pad(5).inset(5,25,-5,-5).mark_base
      c.pad_down(5).mark_base
      c << @type_static.layout(0, c.base, w1, sh)
      c << @type_edit.layout(c.prev_right, c.base, -1, eh)
      c.pad_down(5).mark_base
      c.mark_base.size_to_base
    end

    container.pad_down(5).mark_base
    container.layout_with_contents(@thumb_group_box, 0, container.base, -1, -1) do |c|
      c.set_prev_right_pad(5).inset(5,25,-5,-5).mark_base
      c << @thumb_check.layout(0, c.base, -1, sh)
      c.pad_down(5).mark_base
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
      c << @image_check.layout(0, c.base, -1, sh)
      c.pad_down(5).mark_base
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
      c.pad_down(5).mark_base
      c.mark_base.size_to_base
    end

    container.pad_down(5).mark_base
  end

end

class WebSiteUpdate

  # must include PM::HTMLWebGenTemplate so that
  # the template manager can find our class in
  # ObjectSpace
  include PM::HTMLWebGenTemplate

  def self.template_display_name  # template name shown in dialog list box
    "UpdateWeb"
  end

  def self.template_description  # shown in dialog box
    "Creates images and thumbnails for use on e.g., a website."
  end

  def initialize(pm_api_bridge, num_images)
    @bridge = pm_api_bridge
    @num_images = num_images
  end

  def generate_site(global_spec, progress_dialog)
    raise "generate_site called with no @ui instantiated" unless @ui
    spec = build_template_spec(global_spec, @ui)

    @bridge.template_dest_mkdir("images")
    @bridge.template_dest_mkdir("thumbs")

    thumb_dimensions = {}
    image_dimensions = {}


    # Save original size specs
    org_thumb_max_width = spec.thumb_max_width
    org_thumb_max_height = spec.thumb_max_height
    org_image_max_width = spec.image_max_width
    org_image_max_height = spec.image_max_height

    # We're going to iterate once for num_images
    num_progress_steps = spec.num_images
    progress_dialog.set_range(1, num_progress_steps)

    type = "";
    type << "images" if (spec.images)
    type << " and " if (spec.images && spec.thumbs)
    type << "thumbnails" if (spec.thumbs)
    # Generate thumbs & images
    # NOTE: prefer to generate both thumbnail and image together
    # for a given image index, to maximize disk cache hits.
    1.upto(spec.num_images) do |cur_img_idx|
      progress_dialog.message = "Generating #{type}... (#{cur_img_idx} of #{spec.num_images})"

      if (spec.thumbs)
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
      end

      if (spec.images)
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
      end

      progress_dialog.increment
    end

  end

  def preflight_settings(global_spec)
    raise "preflight_settings called with no @ui instantiated" unless @ui
    spec = build_template_spec(global_spec, @ui)
  end

  def create_controls(parent_dlg)
    @ui = WebSiteUpdateUI.new(@bridge)
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

    spec.highDPI = false;

    spec.thumbs = ui.thumb_check.checked?
    spec.thumb_max_width = ui.thumb_max_width_edit.get_text.to_i
    spec.thumb_max_height = ui.thumb_max_height_edit.get_text.to_i
    spec.thumb_highDPI = ui.thumb_highDPI_check.checked?

    spec.images = ui.image_check.checked?
    spec.image_max_width = ui.image_max_width_edit.get_text.to_i
    spec.image_max_height = ui.image_max_height_edit.get_text.to_i
    spec.image_highDPI = ui.image_highDPI_check.checked?

    spec.image_preserve_exif = ui.preserve_exif_check.checked?
    spec.image_preserve_iptc = ui.preserve_iptc_check.checked?
    spec.do_watermark = ui.watermark_check.checked?
    spec.watermark_settings = ui.watermark_btn.settings

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
