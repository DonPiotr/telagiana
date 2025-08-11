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
  attr_accessor :font_size, :background_color, :text_color, :border_color, :placeholder, :numeric_only, :padding

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
    @padding = 8
  end

  def text
    @text_input.text
  end

  def update; end

  def draw
    return unless @visible

    set_display_text
    draw_field
    draw_in_text
    draw_cursor if @focused
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

  def display_text_too_long?
    available_width = @width - (@padding * 2)
    @font.text_width(@display_text) > available_width
  end

  def set_display_text
    full_text = text_empty_and_unfocused? ? @placeholder : @text_input.text
    @text_start_offset = 0
    @display_text = full_text

    return unless display_text_too_long?

    # Calcola l'offset per centrare il cursore nell'area visibile
    cursor_pos = text_empty_and_unfocused? ? 0 : @text_input.caret_pos
    available_width = @width - (@padding * 2)
    
    # Trova l'offset ottimale per mostrare il cursore
    @text_start_offset = calculate_scroll_offset(full_text, cursor_pos, available_width)
    
    # Applica l'offset
    @display_text = full_text[@text_start_offset..-1] || ''
    
    # Taglia ulteriormente se necessario
    while @font.text_width(@display_text) > available_width && !@display_text.empty?
      @display_text = @display_text[0..-2]
    end
  end

  def calculate_scroll_offset(text, cursor_pos, available_width)
    return 0 if cursor_pos == 0 || text.empty?

    # Se tutto il testo entra nell'area visibile, non serve offset
    if @font.text_width(text) <= available_width
      return 0
    end

    # Calcola quanti caratteri possono entrare approssimativamente nell'area
    avg_char_width = @font.text_width(text) / text.length.to_f
    chars_in_view = (available_width / avg_char_width).to_i

    # Cerca di centrare il cursore: metti metà caratteri prima e metà dopo
    half_chars = chars_in_view / 2
    desired_start = cursor_pos - half_chars

    # Aggiusta i limiti
    desired_start = [desired_start, 0].max
    desired_start = [desired_start, text.length - chars_in_view].min if chars_in_view < text.length

    # Ora affina l'offset basandoti sulla larghezza effettiva del testo
    offset = desired_start
    
    # Aggiusta per assicurarti che il cursore sia visibile
    loop do
      # Calcola il testo che sarebbe visibile con questo offset
      visible_text = text[offset..-1]
      
      # Taglia il testo per farlo entrare nell'area
      while @font.text_width(visible_text) > available_width && !visible_text.empty?
        visible_text = visible_text[0..-2]
      end
      
      # Controlla se il cursore è nel range visibile
      cursor_in_visible = cursor_pos >= offset && cursor_pos <= offset + visible_text.length
      
      if cursor_in_visible
        break
      elsif cursor_pos < offset
        offset -= 1
        offset = [offset, 0].max
      else
        offset += 1
        break if offset >= text.length
      end
      
      # Evita loop infiniti
      break if offset < 0 || offset > cursor_pos + 10
    end

    offset
  end

  def draw_in_text
    # Testo da visualizzare
    text_color = text_empty_and_unfocused? ? Gosu::Color::GRAY : @text_color

    # Calcola la posizione del testo con padding
    text_x = absolute_x + @padding
    text_y = absolute_y + ((@height - @font_size) / 2)

    @font.draw_text(@display_text, text_x, text_y, 1, 1, 1, text_color)
  end

  def draw_cursor
    text_x = absolute_x + @padding
    text_y = absolute_y + ((@height - @font_size) / 2)
    available_width = @width - (@padding * 2)

    # Calcola posizione cursore relativa al testo visualizzato
    visible_cursor_pos = [@text_input.caret_pos - @text_start_offset, 0].max
    cursor_text = @display_text[0...visible_cursor_pos] || ''
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

