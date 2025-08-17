# frozen_string_literal: true

require 'gosu'

# Semplice test per monitorare cambiamenti TextInput
class TestWindow < Gosu::Window
  def initialize
    super(400, 300)
    self.caption = 'Test TextInput - Monitoraggio cambiamenti'
    
    @text_input = Gosu::TextInput.new
    @text_input.text = "Valore prefissato"
    @text_input.caret_pos = 5
    @text_input.selection_start = 5
    
    # Stato precedente per rilevare cambiamenti
    @prev_text = @text_input.text.dup
    @prev_caret_pos = @text_input.caret_pos
    @prev_selection_start = @text_input.selection_start
    
    # Attiva TextInput
    self.text_input = @text_input
    
    puts "INIT - text: '#{@text_input.text}', caret_pos: #{@text_input.caret_pos}, selection_start: #{@text_input.selection_start}"
  end
  
  def draw
    # Sfondo bianco
    Gosu.draw_rect(0, 0, width, height, Gosu::Color::WHITE)
    
    # Disegna il testo
    font = Gosu::Font.new(20)
    font.draw_text("Text: #{@text_input.text}", 10, 50, 1, 1, 1, Gosu::Color::BLACK)
    font.draw_text("Caret: #{@text_input.caret_pos}", 10, 80, 1, 1, 1, Gosu::Color::BLACK)
    font.draw_text("Selection: #{@text_input.selection_start}", 10, 110, 1, 1, 1, Gosu::Color::BLACK)
    font.draw_text("Premi ENTER per reset, ESC per uscire", 10, 150, 1, 1, 1, Gosu::Color::GRAY)
  end
  
  def update
    # Controlla cambiamenti nel testo
    if @text_input.text != @prev_text
      puts "CHANGE text: '#{@prev_text}' -> '#{@text_input.text}'"
      @prev_text = @text_input.text.dup
    end
    
    # Controlla cambiamenti nella posizione cursore
    if @text_input.caret_pos != @prev_caret_pos
      puts "CHANGE caret_pos: #{@prev_caret_pos} -> #{@text_input.caret_pos}"
      @prev_caret_pos = @text_input.caret_pos
    end
    
    # Controlla cambiamenti nella selezione
    if @text_input.selection_start != @prev_selection_start
      puts "CHANGE selection_start: #{@prev_selection_start} -> #{@text_input.selection_start}"
      @prev_selection_start = @text_input.selection_start
    end
  end
  
  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_RETURN
      # Reset ai valori iniziali
      @text_input.text = "Valore prefissato"
      @text_input.caret_pos = 5
      @text_input.selection_start = 5
      @prev_text = @text_input.text.dup
      @prev_caret_pos = @text_input.caret_pos
      @prev_selection_start = @text_input.selection_start
      puts "RESET - text: '#{@text_input.text}', caret_pos: #{@text_input.caret_pos}, selection_start: #{@text_input.selection_start}"
    end
  end
end

# Avvia il test
if __FILE__ == $PROGRAM_NAME
  puts "=== TEST TextInput Monitor ==="
  puts "Digita, usa frecce, backspace, delete per testare"
  puts "Ogni cambiamento verrà annotato sulla console"
  puts "================================"
  
  window = TestWindow.new
  window.show
end