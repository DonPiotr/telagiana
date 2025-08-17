# frozen_string_literal: true

module TelaGiana
  # Classe base per tutti i widget
  class Widget
  attr_accessor :x, :y, :width, :height, :visible, :enabled, :parent_container
  attr_reader :focused

  def initialize(x = nil, y = nil, width = 0, height = 0)
    @x = x
    @y = y
    @width = width
    @height = height
    @visible = true
    @enabled = true
    @focused = false
    @parent_container = nil
  end

  def absolute_x
    if @parent_container
      @parent_container.absolute_x + (@x || 0)
    else
      @x || 0
    end
  end

  def absolute_y
    if @parent_container
      @parent_container.absolute_y + (@y || 0)
    else
      @y || 0
    end
  end

  def bounds
    [absolute_x, absolute_y, absolute_x + @width, absolute_y + @height]
  end

  def contains_point?(px, py)
    px.between?(absolute_x, absolute_x + @width) && py.between?(absolute_y, absolute_y + @height)
  end

  def focus
    @focused = true
  end

  def unfocus
    @focused = false
  end

  # Metodi da implementare nelle sottoclassi
  def update; end

  def draw; end

  def on_click(x, y); end

  def on_key_down(key); end

  def on_text_input(text); end

  def button_down(id); end
  end
end

