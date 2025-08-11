# frozen_string_literal: true

# Gestore dei Widget
class WidgetManager
  @@main_window = nil

  def self.main_window
    @@main_window
  end

  def initialize(window)
    @@main_window = window
    @root_box = Box.new(0, 0, window.width, window.height)
    @focusable_widgets = []
    @focused_widget = nil
    @focused_index = -1
  end

  def add_widget(widget)
    @root_box.add_child(widget)
    collect_focusable_widgets
  end

  def remove_widget(widget)
    @root_box.remove_child(widget)
    collect_focusable_widgets
    return unless @focused_widget == widget

    @focused_widget = nil
    @focused_index = -1
  end

  def add_box(box)
    @root_box.add_child(box)
    # Imposta il riferimento al WidgetManager nel box per le notifiche
    box.widget_manager = self
    collect_focusable_widgets
    box
  end

  def update
    @root_box.update
  end

  def draw
    @root_box.draw
  end

  def on_click(x, y)
    all_widgets = @root_box.all_widgets

    # Controlla dal widget più in alto (ultimo aggiunto) al primo
    all_widgets.reverse.each do |widget|
      if widget.on_click(x, y)
        focused_widget(widget)
        return true
      end
    end

    # Se non si è cliccato su nessun widget, rimuovi il focus
    focused_widget(nil)
    false
  end

  def has_input_field_focused?
    @focused_widget.is_a?(InputField)
  end

  def on_mouse_move(x, y)
    all_widgets = @root_box.all_widgets
    all_widgets.each do |widget|
      widget.on_mouse_move(x, y) if widget.respond_to?(:on_mouse_move)
    end
  end


  def collect_focusable_widgets
    @focusable_widgets = []
    collect_focusable_from_box(@root_box)
  end

  def button_down(id)
    case id
    when Gosu::KB_TAB
      if @@main_window&.button_down?(Gosu::KB_LEFT_SHIFT) || @@main_window&.button_down?(Gosu::KB_RIGHT_SHIFT)
        focus_previous_widget
      else
        focus_next_widget
      end
    else
      @focused_widget&.button_down(id)
    end
  end

  private

  def collect_focusable_from_box(box)
    box.children.each do |widget|
      if widget.is_a?(InputField) || widget.is_a?(Button) || widget.is_a?(InvisibleButton)
        @focusable_widgets << widget
      elsif widget.is_a?(Box)
        collect_focusable_from_box(widget)
      end
    end
  end

  def focused_widget(widget)
    @focused_widget&.unfocus
    @focused_widget = widget
    @focused_widget&.focus

    # Aggiorna l'indice del focus
    @focused_index = if widget
                       @focusable_widgets.index(widget) || -1
                     else
                       -1
                     end
  end

  def focus_next_widget
    return if @focusable_widgets.empty?

    @focused_index = (@focused_index + 1) % @focusable_widgets.length
    focused_widget(@focusable_widgets[@focused_index])
  end

  def focus_previous_widget
    return if @focusable_widgets.empty?

    @focused_index = (@focused_index - 1) % @focusable_widgets.length
    focused_widget(@focusable_widgets[@focused_index])
  end

end

