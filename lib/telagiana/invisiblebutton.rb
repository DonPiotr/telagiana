# frozen_string_literal: true

module TelaGiana
  # Widget Bottone Invisibile (solo area cliccabile)
  class InvisibleButton < Widget
  attr_reader :clicked, :hover

  def initialize(width, height, &block)
    super(nil, nil, width, height)
    @clicked = false
    @hover = false
    @on_click_block = block
  end

  def update
    @clicked = false
  end

  def draw
    # Non disegna nulla - è invisibile
    # Opzionalmente puoi disegnare un bordo di debug
    return unless @focused

    Gosu.draw_rect(absolute_x, absolute_y, @width, 2, Gosu::Color::RED)
    Gosu.draw_rect(absolute_x, absolute_y + @height - 2, @width, 2, Gosu::Color::RED)
    Gosu.draw_rect(absolute_x, absolute_y, 2, @height, Gosu::Color::RED)
    Gosu.draw_rect(absolute_x + @width - 2, absolute_y, 2, @height, Gosu::Color::RED)
  end

  def on_click(x, y)
    # CAMBIARE QUESTO PRESUME CAMBIAMENTO IN TUTTE LE CLASSI
    if contains_point?(x, y) && @enabled
      @clicked = true
      @on_click_block&.call
      return true
    end
    false
  end

  def on_mouse_move(x, y)
    @hover = contains_point?(x, y)
  end

  def button_down(id)
    return unless @focused

    case id
    when Gosu::KB_RETURN, Gosu::KB_SPACE
      @clicked = true
      @on_click_block&.call
    end
  end
  end
end

