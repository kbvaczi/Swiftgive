# encoding: utf-8

class MarketingProductImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  #storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "images/marketing_products"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process :convert => 'png'
  process :resize_and_pad => [250, 250, 'white', 'center']
  process :remove_background_and_extend => [300, 300]
  
  
  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_and_pad => [100, 100]
    
  end

  def remove_background_and_extend(width, height)
    manipulate! do |img|      
      img.combine_options do |c|
        c.fill "none"
        c.fuzz "3%"
        c.draw 'matte 0,0 floodfill'
        c.flop
        c.draw 'matte 0,0 floodfill'
        c.flop
      end
      img.combine_options do |c|
        c.gravity 'center'
        c.background "rgba(255,255,255,0.0)"
        c.extent "#{width}x#{height}"
      end
      img.strip
      img = yield(img) if block_given?
      img
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{model.name.downcase}.png"
  end

end
