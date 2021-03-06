module Metro

  #
  # Image is a wrapper class for a Gosu Image. This allows for additional data
  # to be stored without relying on monkey-patching on functionality.
  #
  class Image < SimpleDelegator

    def initialize(gosu_image,path,tileable)
      super(gosu_image)
      @path = path
      @tileable = tileable
    end

    # The relative path of the image
    attr_reader :path

    # The tileability of the image
    attr_reader :tileable

    def dimensions
      Metro::Units::Dimensions.of width, height
    end

    #
    # Finds an existing image or creates a new image given the window, path,
    # and tileablilty.
    #
    # @example Finding or creating an Image
    #
    #     Metro::Image.find_or_create window: model.window,
    #       path: "asset_path", tileable: tileable
    #
    def self.find_or_create(options)
      begin
        File.open(File.join("assets", options[:path]), "r")
      rescue Exception
        puts $! # <- make this prettier
        options[:path] = "missing.png" # <- make this file installed by default into the assets folder of the game
      end
      path = AssetPath.with(options[:path])
      images[path.to_s] or (images[path.to_s] = create(options))
    end

    #
    # Create an image given the window, path, and tileability.
    #
    # @example Creating an Image
    #
    #     Metro::Image.create window: model.window,
    #       path: "asset_path", tileable: tileable
    #
    def self.create(options)
      window, asset_path, tileable = create_params(options)
      gosu_image = Gosu::Image.new(window,asset_path.filepath,tileable)
      new gosu_image, asset_path.path, tileable
    end

    def self.crop(window,image,bounds)
      cropped_image = TexPlay.create_image(window,bounds.width,bounds.height)
      cropped_image.refresh_cache
      cropped_image.splice image, 0, 0, crop: [ bounds.left, bounds.top, bounds.right, bounds.bottom ]
      cropped_image
    end

    private

    def self.create_params(options)
      options.symbolize_keys!
      asset_path = AssetPath.with(options[:path])
      window = options[:window]
      tileable = !!options[:tileable]
      [ window, asset_path, tileable ]
    end

    def self.images
      @images ||= {}
    end

  end
end