module Metro
  module UI

    #
    # Draws a a menu of options. A menu model inserts itself into the scene as an event
    # target as it needs to maintain the state of the menu. When an option is selected
    # an event is fired based on the name of the option.
    #
    # @note Only one 'menu' can be defined for a given scene
    #
    # @example Creating a menu with basic options
    #
    #     menu:
    #       model: metro::ui::menu
    #       position: "472.0,353.0,5.0"
    #       alpha: 0
    #       unselected_color: "rgba(119,119,119,1.0)"
    #       selected_color: "rgba(255,255,255,1.0)"
    #       options: [ 'Start Game', 'Exit' ]
    #
    # @example Creating a menu with a selected item
    #
    #     menu:
    #       model: metro::ui::menu
    #       position: "472.0,353.0,5.0"
    #       alpha: 0
    #       unselected_color: "rgba(119,119,119,1.0)"
    #       selected_color: "rgba(255,255,255,1.0)"
    #       options:
    #         selected: 0
    #         items: [ 'Start Game', 'Exit' ]
    #
    #
    # @example Creating a menu with complex options
    #
    #     menu:
    #       model: metro::ui::menu
    #       position: "472.0,353.0,5.0"
    #       alpha: 0
    #       unselected_color: "rgba(119,119,119,1.0)"
    #       selected_color: "rgba(255,255,255,1.0)"
    #       options:
    #         selected: 1
    #         items:
    #         -
    #           model: "metro::ui::label"
    #           text: "Start Game"
    #           action: start_game
    #         -
    #           model: metro::ui::label
    #           text: Exit
    #           action: exit_game
    #
    #
    class Menu < Model

      property :position, default: Game.center
      property :alpha, default: 255

      property :scale, default: Scale.one

      property :padding, default: 10

      property :dimensions do
        Dimensions.none
      end

      property :options

      property :unselected_color, type: :color, default: "rgba(119,119,119,1.0)"
      property :selected_color, type: :color, default: "rgba(255,255,255,1.0)"

      def alpha_changed(alpha)
        adjust_alpha_on_colors(alpha)
        options.each { |option| option.alpha = alpha.floor }
      end

      def adjust_alpha_on_colors(alpha)
        self.selected_color_alpha = alpha
        self.unselected_color_alpha = alpha
      end

      def contains?(x,y)
        bounds.contains?(x,y)
      end

      def bounds
        Bounds.new x: x, y: y, width: width, height: height
      end

      # @TODO: enable the user to define the events for this interaction
      # @TODO: enable the user to define the layout of the menu items
      # @TODO: enable the user to enable/disable the menu
      # @TODO: setup sample sounds for movement and selection
      #################################################################

      property :selection_sample, type: :sample, path: "menu-selection.wav"
      property :movement_sample, type: :sample, path: "menu-movement.wav"

      event :on_up, KbLeft, GpLeft, KbUp, GpUp do
        movement_sample.play
        options.previous!
        update_options
      end

      event :on_up, KbRight, GpRight, KbDown, GpDown do
        movement_sample.play
        options.next!
        update_options
      end

      event :on_up, KbEnter, KbReturn, GpButton0 do
        selection_sample.play
        scene.send options.selected_action
      end

      #################################################################

      def show
        adjust_alpha_on_colors(alpha)

        options.each_with_index do |option,index|
          option.color = unselected_color
          option.scale = scale
          label_y_position = y + (option.height + padding) * index
          option.position = "#{x},#{label_y_position},#{z}"
        end

        options.selected.color = selected_color
      end

      def update_options
        options.unselected.each { |option| option.color = unselected_color }
        options.selected.color = selected_color
      end

      def draw
        options.each_with_index { |label| label.draw }
      end

    end
  end
end