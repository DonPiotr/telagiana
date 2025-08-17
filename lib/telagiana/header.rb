# frozen_string_literal: true

module TelaGiana
  # Widget Header
  class Header < Widget
  attr_accessor :text, :font_size, :color, :level

  def initialize(text = 'Header', level = 1)
    # Dimensioni basate sul livello dell'header
    font_sizes = { 1 => 24, 2 => 20, 3 => 18, 4 => 16, 5 => 14, 6 => 12 }
    @font_size = font_sizes[level] || 16
    @level = level

    super(nil, nil, 0, @font_size + 10) # Altezza con padding
    @text = text
    @color = Gosu::Color::BLACK
    @font = Gosu::Font.new(@font_size, name: "Noto Sans Mono")
  end

  def draw
    return unless @visible

    # Disegna il testo dell'header
    @font.draw_text(@text, absolute_x, absolute_y + 5, 1, 1, 1, @color)

    # Disegna una linea sotto per gli header di livello 1 e 2
    return unless @level <= 2
    line_y = absolute_y + @height - 2
    Gosu.draw_rect(absolute_x, line_y, @width, 2, @color)
  end
  end
end

