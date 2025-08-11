# frozen_string_literal: true

# Widget Paragrafo per visualizzare testo
class Paragraph < Widget
  attr_accessor :font_size, :color
  attr_reader :text

  def initialize(text = '', font_size = 16, width = nil)
    @font_size = font_size
    @font = Gosu::Font.new(font_size)

    # Calcola larghezza automatica se non specificata
    width = @font.text_width(text) + 10 if width.nil?

    # Calcola altezza basata sul testo e larghezza
    height = calculate_height(text, width)

    super(nil, nil, width, height)
    @text = text
    @color = Gosu::Color::BLACK
  end

  def text=(new_text)
    @text = new_text
    @height = calculate_height(@text, @width)
  end

  def draw
    return unless @visible

    # Dividi il testo in righe che si adattano alla larghezza
    words = @text.split

    lines = words_to_lines words, @width
    draw_lines lines
  end

  private

  def words_to_lines(words, width)
    lines = []
    current_line = ''
    words.each do |word|
      test_line = current_line.empty? ? word : "#{current_line} #{word}"
      if @font.text_width(test_line) <= width - 10 # padding
        current_line = test_line
      else
        lines << current_line unless current_line.empty?
        current_line = word
      end
    end
    lines << current_line unless current_line.empty?
    lines
  end

  def draw_lines(lines)
    lines.each_with_index do |line, index|
      @font.draw_text(line, absolute_x + 5, absolute_y + 5 + (index * @font_size * 1.2), 1, 1, 1, @color)
    end
  end

  def calculate_height(text, width)
    return @font_size + 10 if text.empty?

    words = text.split
    lines = words_to_lines(words, width).length

    (lines * @font_size * 1.2) + 10
  end
end

