# frozen_string_literal: true

# Widget Bottone
class Button < Widget
  attr_accessor :text, :font_size, :background_color, :text_color, :border_color
  attr_reader :clicked

  def initialize(text = 'Button', width = nil, height = 30, &block)
    @text = text
    @font_size = 16
    @font = Gosu::Font.new(@font_size)

    # Calcola larghezza automatica se non specificata
    width = @font.text_width(text) + 20 if width.nil?

    super(nil, nil, width, height)
    @background_color = Gosu::Color::GRAY
    @text_color = Gosu::Color::BLACK
    @border_color = Gosu::Color::BLACK
    @clicked = false
    @hover = false
    @on_click_block = block
  end

  def update
    @clicked = false
  end

  def draw
    return unless @visible

    # Colore di sfondo diverso se in hover
    bg_color = @hover ? @background_color.dup.tap { |c| c.alpha = 200 } : @background_color

    # Disegna il rettangolo di sfondo
    Gosu.draw_rect(absolute_x, absolute_y, @width, @height, bg_color)

    # Disegna il bordo
    draw_border

    # Centra il testo
    text_x, text_y = text_position

    @font.draw_text(@text, text_x, text_y, 1, 1, 1, @text_color)
  end

  def text_position
    text_width = @font.text_width(@text)
    text_x = absolute_x + ((@width - text_width) / 2)
    text_y = absolute_y + ((@height - @font_size) / 2)
    [text_x, text_y]
  end

  def on_click(x, y)
    if contains_point?(x, y) && @enabled
      @clicked = true
      @on_click_block&.call
      return true
    end
    false
  end

  def on_key_down(key)
    return unless @focused && [Gosu::KB_RETURN, Gosu::KB_SPACE].include?(key)

    @clicked = true
    @on_click_block&.call
  end

  def on_mouse_move(x, y)
    @hover = contains_point?(x, y)
  end

  def button_down(id)
    return unless @focused

    case id
    when Gosu::KB_RETURN, Gosu::KB_SPACE
      # Simula un click quando Enter o Spazio vengono premuti
      @on_click_block&.call
    end
  end

  private

  def draw_border
    border_color = @focused ? Gosu::Color::BLUE : @border_color
    border_width = @focused ? 3 : 2

    # Bordo superiore
    Gosu.draw_rect(absolute_x, absolute_y, @width, border_width, border_color)
    # Bordo inferiore
    Gosu.draw_rect(absolute_x, absolute_y + @height - border_width, @width, border_width, border_color)
    # Bordo sinistro
    Gosu.draw_rect(absolute_x, absolute_y, border_width, @height, border_color)
    # Bordo destro
    Gosu.draw_rect(absolute_x + @width - border_width, absolute_y, border_width, @height, border_color)
  end
end

