# frozen_string_literal: true

require_relative '../lib/telagiana'

include TelaGiana

# Demo InputBox widget
class InputBoxWindow < Gosu::Window
  def initialize
    super(600, 500)
    self.caption = 'InputBox Demo - Multi-line Text Input'

    @widget_manager = WidgetManager.new(self)

    # Crea un box principale
    main_box = @widget_manager.add_box(Box.new(20, 20, width - 40, height - 40))

    # Titolo
    main_box.add_child(Header.new('InputBox Demo', 1))
    
    # Istruzioni
    main_box.add_child(
      Paragraph.new(
        'Type in the box below. Use Enter for new lines, arrow keys to navigate, click to position cursor.',
        16,   # font size
        main_box.width - (main_box.padding * 2)   # larghezza disponibile nel box
      )
    )

    # InputBox multiriga
    @input_box = main_box.add_child(InputBox.new('Type your multi-line text here...', 550, 200))

    # Bottone per stampare il contenuto
    main_box.add_child(Button.new('Print Content to Console', 200) do
      content = @input_box.text
      puts '=' * 50
      puts 'INPUT BOX CONTENT:'
      puts '=' * 50
      if content.strip.empty?
        puts '(empty)'
      else
        puts content
      end
      puts '=' * 50
    end)

    # Bottone per impostare testo di esempio
    main_box.add_child(Button.new('Load Sample Text', 200) do
      sample_text = "This is line 1\nThis is line 2\nThis is a longer line with more text to demonstrate scrolling\nLine 4\nLine 5"
      @input_box.text = sample_text
    end)

    # Bottone per pulire
    main_box.add_child(Button.new('Clear Text', 200) do
      @input_box.text = ''
    end)
  end

  def draw
    # Sfondo bianco
    Gosu.draw_rect(0, 0, width, height, Gosu::Color::WHITE)

    @widget_manager.draw
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      @widget_manager.on_click(mouse_x, mouse_y)
    else
      @widget_manager.button_down(id)
    end
  end

  def button_up(id)
    @widget_manager.button_up(id)
  end

  def update
    @widget_manager.update
    @widget_manager.on_mouse_move(mouse_x, mouse_y)
  end


end

# Avvia l'applicazione
if __FILE__ == $PROGRAM_NAME
  puts "Starting InputBox Demo..."
  puts "Try typing multi-line text and use the buttons to test functionality"
  
  window = InputBoxWindow.new
  window.show
end