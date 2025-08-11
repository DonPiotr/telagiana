# frozen_string_literal: true

require_relative '../lib/telagiana'

# Esempio di utilizzo
class GameWindow < Gosu::Window
  def initialize
    super(800, 600)
    self.caption = 'Gosu Widget Library Demo - Layout Automatico'

    @widget_manager = WidgetManager.new(self)

    # Crea un box principale per l'interfaccia
    main_box = @widget_manager.add_box(Box.new(20, 20, width - 40, height - 40))

    # Header principale
    main_box.add_child(Header.new('Gestione Interfaccia', 1))

    # Paragrafo introduttivo
    main_box.add_child(
      Paragraph.new(
        'Benvenuto nella demo della libreria widget! Gli elementi si posizionano automaticamente.'
      )
    )

    # Sottosezione con header di livello 2
    main_box.add_child(Header.new('Controlli', 2))

    # Bottoni su una riga
    main_box.add_child(Button.new('Primo') do
      puts 'Cliccato primo bottone!'
    end)

    main_box.add_child(Button.new('Secondo') do
      puts 'Cliccato secondo bottone!'
    end)

    main_box.add_child(Button.new('Terzo') do
      puts 'Cliccato terzo bottone!'
    end)

    # Interruzione di riga
    main_box.add_child(Br.new)

    # Campo input e bottone sulla riga successiva
    @input = main_box.add_child(InputField.new('Scrivi qualcosa...'))

    main_box.add_child(Button.new('Invia') do
      puts "Testo inviato: #{@input.text}"
    end)

    # Nuova sezione
    main_box.add_child(Header.new('Box Nidificati', 2))

    # Box interno per dimostrare il nesting
    inner_box = Box.new(0, 190, 350, 120)
    inner_box.padding = 10
    inner_box.margin_x = 8
    inner_box.margin_y = 8
    inner_box.background_color = Gosu::Color.new(220, 220, 220, 255)  # Grigio chiaro
    inner_box.border_color = Gosu::Color.new(50, 200, 200, 255)      # Bordo ciano
    inner_box.border_size = 2

    inner_box.add_child(Paragraph.new('Questo è un box interno con i suoi widget:'))
    inner_box.add_child(Button.new('A') { puts 'Bottone A' })
    inner_box.add_child(Button.new('B') { puts 'Bottone B' })
    inner_box.add_child(Button.new('C') { puts 'Bottone C' })
    inner_box.add_child(Br.new)
    input_in_box = inner_box.add_child(InputField.new('Campo nel box interno'))
    input_in_box.numeric_only = true

    main_box.add_child(inner_box)

    # Bottone invisibile personalizzato
    # main_box.add_child(Br.new)
    main_box.add_child(Spacer.new(0, 330))
    main_box.add_child(Paragraph.new('Bottone invisibile personalizzato:'))
    @invisible_btn = main_box.add_child(InvisibleButton.new(200, 60) do
      puts 'Cliccato bottone invisibile personalizzato!'
    end)
  end

  def draw
    # Disegna sfondo chiaro per tutta la finestra
    Gosu.draw_rect(0, 0, width, height, Gosu::Color::WHITE)

    @widget_manager.draw

    # Disegna il contenuto del bottone invisibile
    draw_custom_invisible_button
  end

  def draw_custom_invisible_button
    return unless @invisible_btn

    abs_x = @invisible_btn.absolute_x
    abs_y = @invisible_btn.absolute_y
    w = @invisible_btn.width
    h = @invisible_btn.height

    if @invisible_btn.hover
      Gosu.draw_rect(abs_x, abs_y, w, h, Gosu::Color.new(255, 150, 150, 255))
      Gosu.draw_rect(abs_x, abs_y, w, h / 2, Gosu::Color.new(100, 200, 200, 255))
    else
      # Sfondo gradiente
      Gosu.draw_rect(abs_x, abs_y, w, h, Gosu::Color.new(255, 100, 150, 255))
      Gosu.draw_rect(abs_x, abs_y, w, h / 2, Gosu::Color.new(100, 150, 200, 255))
    end

    # Bordo decorativo
    border_color = @invisible_btn.focused ? Gosu::Color::YELLOW : Gosu::Color::WHITE
    3.times do |i|
      Gosu.draw_rect(abs_x + i, abs_y + i, w - (i * 2), 2, border_color)
      Gosu.draw_rect(abs_x + i, abs_y + h - 2 - i, w - (i * 2), 2, border_color)
      Gosu.draw_rect(abs_x + i, abs_y + i, 2, h - (i * 2), border_color)
      Gosu.draw_rect(abs_x + w - 2 - i, abs_y + i, 2, h - (i * 2), border_color)
    end

    # Testo personalizzato
    font = Gosu::Font.new(16)
    text = "Bottone\nPersonalizzato"
    lines = text.split("\n")
    lines.each_with_index do |line, index|
      text_width = font.text_width(line)
      text_x = abs_x + ((w - text_width) / 2)
      text_y = abs_y + ((h - (lines.length * 20)) / 2) + (index * 20)
      font.draw_text(line, text_x, text_y, 2, 1, 1, Gosu::Color::WHITE)
    end
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      @widget_manager.on_click(mouse_x, mouse_y)
    else
      @widget_manager.button_down(id)
    end
  end

  def update
    @widget_manager.update

    # Gestisce gli effetti hover tracciando la posizione del mouse
    @widget_manager.on_mouse_move(mouse_x, mouse_y)
  end
end

# Avvia l'applicazione di esempio
if __FILE__ == $PROGRAM_NAME
  window = GameWindow.new
  window.show
end

