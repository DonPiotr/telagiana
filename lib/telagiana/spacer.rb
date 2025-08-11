# frozen_string_literal: true

# Widget per spostare il cursore del layout a una posizione specifica
class Spacer < Widget
  def initialize(x = nil, y = nil)
    super(x, y, 0, 0)
  end

  def draw
    # Non disegna nulla
  end
end