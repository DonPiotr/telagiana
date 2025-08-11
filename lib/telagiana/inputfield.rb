# frozen_string_literal: true

# Custom TextInput per filtering
class NumericTextInput < Gosu::TextInput
  def initialize
    super
    @numeric_only = false
  end

  attr_accessor :numeric_only

  def filter(text_in)
    if @numeric_only
      text_in.gsub(/[^0-9.\-]/, '')
    else
      text_in
    end
  end
end

# Widget Campo di Input
class InputField < Widget

  attr_accessor :font_size, :background_color, :text_color, :border_color, :placeholder, :numeric_only

  def initialize(placeholder = '', width = 150, height = 30)
    super(nil, nil, width, height)
    @placeholder = placeholder
    @font_size = 16
    @font = Gosu::Font.new(@font_size)
    @background_color = Gosu::Color::WHITE
    @text_color = Gosu::Color::BLACK
    @border_color = Gosu::Color::GRAY
    @focused_border_color = Gosu::Color::BLUE
    @cursor_timer = 0
    @numeric_only = false
    @text_input = NumericTextInput.new
  end

  def text
    @text_input.text
  end

  def update; end

  def draw
    return unless @visible

    padding = 8
    draw_field
    draw_in_text(padding)
    draw_cursor(padding) if @focused
  end

  def draw_field
    # Disegna il rettangolo di sfondo
    Gosu.draw_rect(absolute_x, absolute_y, @width, @height, @background_color)

    # Disegna il bordo (diverso colore se focused)
    border_color = @focused ? @focused_border_color : @border_color
    draw_border(border_color)
  end

  def text_empty_and_unfocused?
    @text_input.text.empty? && !@focused
  end

  def text_to_dispaly_too_big?(display_text, padding)
    available_width = @width - (padding * 2)
    @font.text_width(display_text) > available_width
  end

  def draw_in_text(padding)
    # Testo da visualizzare
    display_text = text_empty_and_unfocused? ? @placeholder : @text_input.text
    text_color = text_empty_and_unfocused? ? Gosu::Color::GRAY : @text_color

    # Calcola la posizione del testo con padding
    text_x = absolute_x + padding
    text_y = absolute_y + ((@height - @font_size) / 2)

    # Clip del testo se troppo lungo
    if text_to_dispaly_too_big?(display_text, padding)
      # Mostra solo la parte finale del testo se è troppo lungo
      display_text = display_text[1..] while !display_text.empty? && text_to_dispaly_too_big?(display_text, padding)
    end

    @font.draw_text(display_text, text_x, text_y, 1, 1, 1, text_color)
  end

  def draw_cursor(padding)
    text_x = absolute_x + padding
    text_y = absolute_y + ((@height - @font_size) / 2)
    available_width = @width - (padding * 2)

    # Calcola il testo da visualizzare (stesso clipping di draw_in_text)
    display_text = text_empty_and_unfocused? ? @placeholder : @text_input.text

    # Applica clipping se necessario
    text_start_offset = 0
    if text_to_dispaly_too_big?(display_text, padding)
      # Trova l'offset di partenza per il testo clippato
      while !display_text.empty? && text_to_dispaly_too_big?(display_text, padding)
        display_text = display_text[1..]
        text_start_offset += 1
      end
    end

    # Calcola posizione cursore relativa al testo visualizzato
    visible_cursor_pos = [@text_input.caret_pos - text_start_offset, 0].max
    cursor_text = display_text[0...visible_cursor_pos] || ''
    cursor_x = text_x + @font.text_width(cursor_text)

    # Disegna cursore solo se è visibile nell'area del campo
    if cursor_x >= text_x && cursor_x <= text_x + available_width
      Gosu.draw_rect(cursor_x, text_y, 2, @font_size, @text_color)
    end
  end

  def on_click(x, y)
    if contains_point?(x, y)
      focus
      # Posiziona il cursore sempre alla fine del testo
      @text_input.caret_pos = @text_input.text.length
      return true
    else
      unfocus
    end
    false
  end


  def draw_border(color)
    border_width = @focused ? 3 : 2
    # Bordo superiore
    Gosu.draw_rect(absolute_x, absolute_y, @width, border_width, color)
    # Bordo inferiore
    Gosu.draw_rect(absolute_x, absolute_y + @height - border_width, @width, border_width, color)
    # Bordo sinistro
    Gosu.draw_rect(absolute_x, absolute_y, border_width, @height, color)
    # Bordo destro
    Gosu.draw_rect(absolute_x + @width - border_width, absolute_y, border_width, @height, color)
  end


  def focus
    @focused = true
    WidgetManager.main_window.text_input = @text_input if WidgetManager.main_window
  end

  def unfocus
    @focused = false
    WidgetManager.main_window.text_input = nil if WidgetManager.main_window
  end


  def numeric_only=(value)
    @numeric_only = value
    @text_input.numeric_only = value
  end


  private

  def numeric_char?(char)
    char.match?(/\A[0-9.\-]\z/)
  end
end

