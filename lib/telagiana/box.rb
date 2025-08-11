# frozen_string_literal: true

# Container invisibile per organizzare l'interfaccia
class Box < Widget
  attr_reader :children
  attr_accessor :padding, :margin_x, :margin_y, :background_color, :border_color, :border_size, :widget_manager

  def initialize(x = 0, y = 0, width = 0, height = 0)
    super
    @children = []
    @padding = 5
    @margin_x = 5
    @margin_y = 5
    @current_line_x = @padding
    @current_line_y = @padding
    @current_line_height = 0
    @background_color = nil
    @border_color = nil
    @border_size = 1
  end

  def add_child(widget)
    widget.parent_container = self
    @children << widget

    # Posiziona automaticamente tutti i widget (anche Br e Spacer che hanno x,y = 0)
    position_widget_automatically(widget)

    # Notifica al WidgetManager di riscannare i widget focusabili se questo box è gestito da uno
    notify_widget_manager_if_needed

    widget
  end

  def remove_child(widget)
    @children.delete(widget)
    widget.parent_container = nil
  end

  def add_line_break
    @current_line_x = @padding
    @current_line_y += @current_line_height + @margin_y
    @current_line_height = 0
  end

  def available_width
    @width.positive? ? @width - (@padding * 2) : Float::INFINITY
  end

  def update
    @children.each(&:update)
  end

  def draw
    # Disegna lo sfondo se specificato
    Gosu.draw_rect(absolute_x, absolute_y, @width, @height, @background_color) if @background_color && @width.positive? && @height.positive?

    # Disegna il bordo se specificato
    draw_border if @border_color && @border_size.positive? && @width.positive? && @height.positive?

    # Disegna i figli
    @children.each(&:draw)
  end

  def all_widgets
    result = []
    @children.each do |child|
      result << child
      result.concat(child.all_widgets) if child.is_a?(Box)
    end
    result
  end

  private

  def draw_border
    # Bordo superiore
    Gosu.draw_rect(absolute_x, absolute_y, @width, @border_size, @border_color)
    # Bordo inferiore
    Gosu.draw_rect(absolute_x, absolute_y + @height - @border_size, @width, @border_size, @border_color)
    # Bordo sinistro
    Gosu.draw_rect(absolute_x, absolute_y, @border_size, @height, @border_color)
    # Bordo destro
    Gosu.draw_rect(absolute_x + @width - @border_size, absolute_y, @border_size, @height, @border_color)
  end

  def notify_widget_manager_if_needed
    # Se abbiamo un riferimento al widget manager, notificicalo
    @widget_manager&.collect_focusable_widgets if defined?(@widget_manager) && @widget_manager
  end

  def position_widget_automatically(widget)
    if widget.is_a?(Header)
      # Se è un Header, posizionalo all'inizio della riga e prende tutta la larghezza
      position_header_automatically widget
    elsif widget.is_a?(Br)
      # Se è un Br, aggiungi interruzione di riga
      position_br_automatically widget
    elsif widget.is_a?(Spacer)
      # Se è un Spacer, sposta il cursore alla posizione specificata
      position_spacer_automatically widget
    else
      # Per gli altri widget, controlla se c'è spazio nella riga corrente
      position_other_automatically widget
    end
  end

  def position_other_automatically widget
    widget_width = widget.width

    # Non c'è spazio, vai alla riga successiva
    add_line_break if @current_line_x + widget.width > available_width && @current_line_x > @padding

    widget.x = @current_line_x
    widget.y = @current_line_y

    @current_line_x += widget_width + @margin_x
    @current_line_height = [widget.height, @current_line_height].max
  end

  def position_header_automatically(widget)
    add_line_break if @current_line_x > @padding
    widget.x = @padding
    widget.y = @current_line_y
    widget.width = available_width == Float::INFINITY ? 400 : available_width
    @current_line_height = [widget.height, @current_line_height].max
    add_line_break
  end

  def position_br_automatically(widget)
    widget.x = @current_line_x
    widget.y = @current_line_y
    add_line_break
  end

  def position_spacer_automatically(widget)
    # Sposta il cursore alla posizione specificata dal Spacer
    @current_line_x = widget.x.nil? ? @current_line_x : widget.x + @padding
    @current_line_y = widget.y.nil? ? @current_line_y : widget.y + @padding
    @current_line_height = 0

    # Il widget Spacer non ha bisogno di posizione specifica, serve solo per il cursore
    widget.x = 0
    widget.y = 0
  end
end

