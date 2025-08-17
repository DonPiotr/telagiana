# frozen_string_literal: true

module TelaGiana
  # Widget InputBox per testo multiriga - Versione semplificata
  class InputBox < Widget
  attr_accessor :font_size, :background_color, :text_color, :border_color, :placeholder, :padding
  attr_reader :lines

  def initialize(placeholder = '', width = 300, height = 150)
    super(nil, nil, width, height)
    @placeholder = placeholder
    @font_size = 16
    @font = Gosu::Font.new(@font_size, name: "Noto Sans Mono")
    @background_color = Gosu::Color::WHITE
    @text_color = Gosu::Color::BLACK
    @border_color = Gosu::Color::GRAY
    @focused_border_color = Gosu::Color::BLUE
    @padding = 8
    @line_height = @font_size + 4

    # Calcola numero massimo di righe
    @max_rows = calculate_rows
    @max_chars_per_row = calculate_chars_per_row

    @current_row = 0  # Riga attualmente attiva

    # Inizializza array delle righe vuote
    @lines = Array.new(@max_rows, "")

    # TextInput singolo che verrà usato per la riga corrente
    @current_text_input = Gosu::TextInput.new
  end

  def text
    @lines.reject(&:empty?).join("\n")
  end

  def text=(new_text)
    @lines = new_text.split("\n")
    # Limita al numero massimo di righe
    @lines = @lines[0, @max_rows] if @lines.length > @max_rows
    # Assicura che abbiamo sempre @max_rows elementi
    while @lines.length < @max_rows
      @lines << ""
    end

    # Se focused, ricarica la riga corrente
    if @focused
      @current_text_input.text = @lines[@current_row]
    end
  end

  def calculate_rows
    text_area_height = @height - (@padding * 2)
    (text_area_height / @line_height).to_i
  end

  def update
    # Sincronizza SOLO in modo sicuro: TextInput -> Array (mai il contrario!)
    if @focused && TelaGiana::WidgetManager.main_window&.text_input == @current_text_input
      @lines[@current_row] = @current_text_input.text
    end

    # Applica il limite di caratteri per riga
    if @focused && @current_text_input.text.length > @max_chars_per_row
      @current_text_input.text = @current_text_input.text[0, @max_chars_per_row]
      @current_text_input.caret_pos = @current_text_input.text.length
      @current_text_input.selection_start = @current_text_input.caret_pos
    end
  end

  def draw
    return unless @visible

    draw_field
    draw_text
    draw_cursor if @focused
  end

  def draw_field
    # Disegna il rettangolo di sfondo
    Gosu.draw_rect(absolute_x, absolute_y, @width, @height, @background_color)

    # Disegna il bordo
    border_color = @focused ? @focused_border_color : @border_color
    draw_border(border_color)
  end

  def draw_text
    text_x = absolute_x + @padding
    start_y = absolute_y + @padding

    if text_empty_and_unfocused?
      # Mostra placeholder
      @font.draw_text(@placeholder, text_x, start_y, 1, 1, 1, Gosu::Color::GRAY)
    else
      # Mostra le righe di testo
      last_row = last_row_with_content
      (0..last_row).each do |line_idx|
        line_y = start_y + (line_idx * @line_height)

        # Evidenzia la riga corrente
        # if @focused && line_idx == @current_row
          # Disegna sfondo della riga attiva
        #  Gosu.draw_rect(absolute_x + 2, line_y - 2, @width - 4, @line_height, Gosu::Color.new(240, 240, 255, 255))
        # end

        @font.draw_text(@lines[line_idx] || '', text_x, line_y, 1, 1, 1, @text_color)
      end
    end
  end

  def draw_cursor
    return if text_empty_and_unfocused?

    cursor_pos = @current_text_input.caret_pos
    text_x = absolute_x + @padding
    cursor_y = absolute_y + @padding + (@current_row * @line_height)

    # Ottieni il testo prima del cursore nella riga corrente
    line_text = @lines[@current_row] || ''
    text_before_cursor = line_text[0...cursor_pos] || ''
    cursor_x = text_x + @font.text_width(text_before_cursor)

    # Disegna il cursore
    Gosu.draw_rect(cursor_x, cursor_y, 2, @font_size, @text_color)
  end

  def on_click(x, y)
    if contains_point?(x, y)
      # NON fa focus qui - sarà fatto da WidgetManager

      # Calcola quale riga è stata cliccata
      relative_y = y - (absolute_y + @padding)
      clicked_row = (relative_y / @line_height).to_i
      clicked_row = [clicked_row, 0].max

      # Limita al numero di righe utilizzate
      last_used_row = last_row_with_content
      clicked_row = [clicked_row, last_used_row].min

      # Calcola posizione cursore basata sul click X
      relative_x = x - (absolute_x + @padding)
      line_text = @lines[clicked_row] || ''

      # Trova la posizione del carattere più vicina al click
      click_pos = 0
      unless line_text.empty?
        (0..line_text.length).each do |pos|
          text_before = line_text[0...pos]
          text_width = @font.text_width(text_before)

          if text_width > relative_x
            click_pos = [pos - 1, 0].max
            break
          else
            click_pos = pos
          end
        end
      end

      # Cambia riga se diversa
      if clicked_row != @current_row
        # Salva la riga che stiamo lasciando SOLO se siamo già focused
        # (se non siamo focused, TextInput potrebbe avere contenuto stantio)
        old_row = @current_row  # SALVA LA RIGA PRECEDENTE!
        if @focused
          @lines[old_row] = @current_text_input.text
        end

        # Cambia alla nuova riga
        @current_row = clicked_row
        @need_text_reload = true  # Flag per focus() per ricaricare il testo
      end

      # Salva la posizione del click per focus()
      @click_pos = click_pos

      return true
    else
      unfocus
    end
    false
  end

  def button_down(id)
    return unless @focused

    case id
    when Gosu::KB_UP
      move_to_previous_row
    when Gosu::KB_DOWN
      move_to_next_row
    when Gosu::KB_RETURN
      handle_enter
    end
  end

  def button_up(id)
    return unless @focused

    case id
    when Gosu::KB_BACKSPACE
      handle_backspace
    when Gosu::KB_DELETE
      handle_delete
    end
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

    # Carica la riga corrente nel TextInput SOLO se necessario
    if @need_text_reload || !TelaGiana::WidgetManager.main_window.text_input
      @current_text_input.text = @lines[@current_row]
      @need_text_reload = false
    end

    TelaGiana::WidgetManager.main_window.text_input = @current_text_input if TelaGiana::WidgetManager.main_window

    # Se abbiamo una posizione di click, usala
    if @click_pos
      @current_text_input.caret_pos = @click_pos
      @current_text_input.selection_start = @click_pos
      @click_pos = nil  # Reset per prossimo uso
    end
  end

  def unfocus
    @focused = false
    # NON salviamo qui - il salvataggio è gestito esplicitamente in on_click
    # perché quando unfocus() viene chiamato, @current_row potrebbe essere già cambiato!
    TelaGiana::WidgetManager.main_window.text_input = nil if TelaGiana::WidgetManager.main_window
  end

  private

  def text_empty_and_unfocused?
    @lines.all?(&:empty?) && !@focused
  end

  def calculate_chars_per_row
    available_width = @width - (@padding * 2)
    # Usa una stringa di caratteri misti per calcolare la larghezza media
    sample_text = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    avg_char_width = @font.text_width(sample_text) / sample_text.length.to_f
    (available_width / avg_char_width).to_i
  end

  def change_to_row(new_row)
    return if new_row == @current_row || new_row < 0 || new_row >= @max_rows

    # Salva la riga corrente
    @lines[@current_row] = @current_text_input.text

    # Cambia riga
    @current_row = new_row

    # Carica la nuova riga
    @current_text_input.text = @lines[@current_row]
    @current_text_input.caret_pos = @current_text_input.text.length
  end

  def last_row_with_content
    # NON salviamo automaticamente qui - causa corruzione dell'array!
    # Il salvataggio deve essere esplicito e controllato

    # Trova l'ultima riga che ha contenuto
    @lines.each_with_index.reverse_each do |line, idx|
      return idx unless line.empty?
    end
    0 # Se tutte le righe sono vuote, ritorna 0
  end

  def move_to_previous_row
    return if @current_row <= 0

    # Salva la posizione corrente del cursore
    desired_caret_pos = @current_text_input.caret_pos

    # Cambia alla riga precedente
    change_to_row(@current_row - 1)

    # Mantieni la posizione del cursore, limitata alla lunghezza della nuova riga
    new_caret_pos = [desired_caret_pos, @current_text_input.text.length].min
    @current_text_input.caret_pos = new_caret_pos
    @current_text_input.selection_start = new_caret_pos
  end

  def move_to_next_row
    last_row = last_row_with_content
    return if @current_row >= last_row

    # Salva la posizione corrente del cursore
    desired_caret_pos = @current_text_input.caret_pos

    # Cambia alla riga successiva
    change_to_row(@current_row + 1)

    # Mantieni la posizione del cursore, limitata alla lunghezza della nuova riga
    new_caret_pos = [desired_caret_pos, @current_text_input.text.length].min
    @current_text_input.caret_pos = new_caret_pos
    @current_text_input.selection_start = new_caret_pos
  end

  def handle_enter
    # Controlla se abbiamo già il massimo di righe possibili
    last_used_row = last_row_with_content
    return if last_used_row >= @max_rows - 1

    current_line = @current_text_input.text
    cursor_pos = @current_text_input.caret_pos

    # 1. Divide il testo della riga corrente dove c'è il cursore
    first_part = current_line[0...cursor_pos] || ''
    second_part = current_line[cursor_pos..-1] || ''

    # 2. Nella riga corrente mette la prima parte
    @lines[@current_row] = first_part
    @current_text_input.text = first_part

    # 3. Aggiunge la riga dopo la riga corrente (shift verso il basso)
    new_row = @current_row + 1

    # Shift tutte le righe successive verso il basso
    (@max_rows - 2).downto(new_row) do |i|
      @lines[i + 1] = @lines[i]
    end

    # Mette la seconda parte nella nuova riga
    @lines[new_row] = second_part

    # 4. Viene selezionata la nuova riga
    @current_row = new_row
    @current_text_input.text = @lines[@current_row]
    @current_text_input.caret_pos = 0
    @current_text_input.selection_start = 0
  end

  def move_to_next_available_row
    last_row = last_row_with_content

    # Se sulla riga corrente c'è testo e non siamo all'ultima riga possibile, crea nuova riga
    if !@lines[@current_row].empty? && @current_row < @max_rows - 1
      target_row = @current_row + 1
      change_to_row(target_row)
    end
  end

  def handle_backspace
    return unless @current_text_input.caret_pos == 0 && @current_row > 0

    # Salva la riga corrente prima della fusione
    current_line = @current_text_input.text

    # Passa alla riga precedente
    previous_row = @current_row - 1
    previous_line = @lines[previous_row]

    # Fonde le righe: riga precedente + riga corrente
    merged_text = previous_line + current_line

    # Controlla se il testo fuso supera il limite di larghezza
    if @font.text_width(merged_text) > (@width - @padding * 2)
      # Divide il testo dopo il massimo delle parole che centrano
      words = merged_text.split(/\s+/)
      first_part = ''
      remaining_words = []

      words.each_with_index do |word, idx|
        test_text = first_part.empty? ? word : "#{first_part} #{word}"

        if @font.text_width(test_text) <= (@width - @padding * 2)
          first_part = test_text
        else
          # Questa parola non entra, inizia la parte rimanente
          remaining_words = words[idx..-1]
          break
        end
      end

      # Se non è entrata nemmeno una parola, forza almeno qualche carattere
      if first_part.empty? && !words.empty?
        first_word = words[0]
        max_chars = 0
        (1..first_word.length).each do |i|
          test_text = first_word[0...i]
          if @font.text_width(test_text) <= (@width - @padding * 2)
            max_chars = i
          else
            break
          end
        end

        if max_chars > 0
          first_part = first_word[0...max_chars]
          remaining_text = first_word[max_chars..-1]
          remaining_text += ' ' + words[1..-1].join(' ') if words.length > 1
        else
          # Fallback: usa limite caratteri
          first_part = merged_text[0...@max_chars_per_row]
          remaining_text = merged_text[@max_chars_per_row..-1] || ''
        end
      else
        remaining_text = remaining_words.join(' ')
      end

      # Prima parte va nella riga precedente
      @lines[previous_row] = first_part

      # Parte rimanente nella riga corrente
      @lines[@current_row] = remaining_text

      # Nessuna riga viene cancellata, resta sulla riga precedente
      @current_row = previous_row
      @current_text_input.text = @lines[@current_row]
      @current_text_input.caret_pos = first_part.length
      @current_text_input.selection_start = @current_text_input.caret_pos

    else
      # Il testo fuso entra nella riga, comportamento normale
      @lines[previous_row] = merged_text

      # CANCELLA completamente la riga corrente (shift delle righe successive)
      @current_row.upto(@max_rows - 2) do |i|
        @lines[i] = @lines[i + 1]
      end
      @lines[@max_rows - 1] = ''

      # Seleziona riga precedente e posiziona cursore alla giunzione
      @current_row = previous_row
      @current_text_input.text = @lines[@current_row]
      @current_text_input.caret_pos = previous_line.length
      @current_text_input.selection_start = @current_text_input.caret_pos
    end

    # Riordina tutto il testo
    # adjust_text  # DISATTIVATO TEMPORANEAMENTE
  end

  def handle_delete
    current_line = @current_text_input.text
    return unless @current_text_input.caret_pos == current_line.length && @current_row < @max_rows - 1

    # Prende semplicemente la riga successiva se esiste
    next_row = @current_row + 1
    return unless next_row < @max_rows

    next_line = @lines[next_row]

    # Fonde le righe: riga corrente + riga successiva
    merged_text = current_line + next_line

    # Controlla se il testo fuso supera il limite di larghezza
    if @font.text_width(merged_text) > (@width - @padding * 2)
      # Divide il testo dopo il massimo delle parole che centrano
      words = merged_text.split(/\s+/)
      first_part = ''
      remaining_words = []

      words.each_with_index do |word, idx|
        test_text = first_part.empty? ? word : "#{first_part} #{word}"

        if @font.text_width(test_text) <= (@width - @padding * 2)
          first_part = test_text
        else
          # Questa parola non entra, inizia la parte rimanente
          remaining_words = words[idx..-1]
          break
        end
      end

      # Se non è entrata nemmeno una parola, forza almeno qualche carattere
      if first_part.empty? && !words.empty?
        first_word = words[0]
        max_chars = 0
        (1..first_word.length).each do |i|
          test_text = first_word[0...i]
          if @font.text_width(test_text) <= (@width - @padding * 2)
            max_chars = i
          else
            break
          end
        end

        if max_chars > 0
          first_part = first_word[0...max_chars]
          remaining_text = first_word[max_chars..-1]
          remaining_text += ' ' + words[1..-1].join(' ') if words.length > 1
        else
          # Fallback: usa limite caratteri
          first_part = merged_text[0...@max_chars_per_row]
          remaining_text = merged_text[@max_chars_per_row..-1] || ''
        end
      else
        remaining_text = remaining_words.join(' ')
      end

      # Prima parte rimane nella riga corrente
      @lines[@current_row] = first_part
      @current_text_input.text = first_part
      @current_text_input.caret_pos = current_line.length
      @current_text_input.selection_start = @current_text_input.caret_pos

      # Parte rimanente va nella riga successiva
      @lines[next_row] = remaining_text

      # Nessuna riga viene cancellata

    else
      # Il testo fuso entra nella riga, comportamento normale
      @lines[@current_row] = merged_text
      @current_text_input.text = merged_text
      @current_text_input.caret_pos = current_line.length
      @current_text_input.selection_start = @current_text_input.caret_pos

      # CANCELLA completamente la riga successiva (shift delle righe successive)
      next_row.upto(@max_rows - 2) do |i|
        @lines[i] = @lines[i + 1]
      end
      @lines[@max_rows - 1] = ''
    end

    # Seleziona riga corrente (già selezionata)

    # Riordina tutto il testo
    # adjust_text  # DISATTIVATO TEMPORANEAMENTE
  end

  def adjust_text
    # Salva la riga corrente prima di riorganizzare
    @lines[@current_row] = @current_text_input.text if @focused

    # Raccogli tutto il testo non vuoto
    all_text = @lines.reject(&:empty?).join(' ')

    # Se non c'è testo, pulisce tutto
    if all_text.strip.empty?
      @lines.fill('')
      @current_text_input.text = ''
      @current_row = 0
      return
    end

    # Divide il testo in parole
    words = all_text.split(/\s+/)

    # Riorganizza le parole nelle righe
    @lines.fill('')
    current_line = 0
    current_text = ''
    cursor_pos = 0
    found_cursor_line = false

    words.each_with_index do |word, word_idx|
      # Testa se la parola può essere aggiunta alla riga corrente
      test_text = current_text.empty? ? word : "#{current_text} #{word}"

      if @font.text_width(test_text) <= (@width - @padding * 2) && current_line < @max_rows
        # La parola entra nella riga corrente
        current_text = test_text

        # Controlla se il cursore dovrebbe essere qui
        if !found_cursor_line && should_cursor_be_here?(word_idx, words)
          @current_row = current_line
          cursor_pos = current_text.length
          found_cursor_line = true
        end
      else
        # La parola non entra, passa alla riga successiva
        @lines[current_line] = current_text if current_line < @max_rows
        current_line += 1

        # Se abbiamo esaurito le righe, tronca il testo
        if current_line >= @max_rows
          break
        end

        current_text = word

        # Controlla se il cursore dovrebbe essere qui
        if !found_cursor_line && should_cursor_be_here?(word_idx, words)
          @current_row = current_line
          cursor_pos = current_text.length
          found_cursor_line = true
        end
      end
    end

    # Salva l'ultima riga se non abbiamo esaurito lo spazio
    if current_line < @max_rows && !current_text.empty?
      @lines[current_line] = current_text
    end

    # Se non abbiamo trovato dove mettere il cursore, mettilo alla fine
    unless found_cursor_line
      @current_row = [current_line, @max_rows - 1].min
      cursor_pos = @lines[@current_row].length
    end

    # Aggiorna il TextInput con la riga corrente
    if @focused
      @current_text_input.text = @lines[@current_row]
      @current_text_input.caret_pos = [cursor_pos, @lines[@current_row].length].min
      @current_text_input.selection_start = @current_text_input.caret_pos
    end
  end

  def should_cursor_be_here?(word_idx, words)
    # Logica semplificata: mette il cursore nella prima riga disponibile
    # In futuro potremmo implementare una logica più sofisticata
    word_idx == 0
  end

  end
end
