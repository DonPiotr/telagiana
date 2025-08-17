# TelaGiana

A Ruby widget library for Gosu that simplifies creating user interfaces with automatic layout.

"Tela" means "canvas"; "Giana" means "of Janus" - it's because the library was made nearby Giano - Janus river.

## Features

- **Automatic layout**: Widgets position themselves automatically without manual coordinate specification
- **Ready-to-use widgets**: Button, InputField, InputBox, Header, Paragraph, Box and more
- **Focus management**: TAB navigation between widgets
- **Mouse and keyboard events**: Complete input event handling
- **Nested boxes**: Containers that can hold other widgets and boxes
- **Customizable**: Colors, borders, padding and styles fully configurable

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'telagiana'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install telagiana
```

## Basic Usage

```ruby
require 'telagiana'

# Include TelaGiana module to use widgets without namespace prefix
include TelaGiana

class GameWindow < Gosu::Window
  def initialize
    super(800, 600)
    self.caption = 'My App'

    # Create the widget manager
    @widget_manager = WidgetManager.new(self)

    # Create a main box
    main_box = @widget_manager.add_box(Box.new(20, 20, width - 40, height - 40))

    # Add widgets
    main_box.add_child(Header.new('Title', 1))
    main_box.add_child(Paragraph.new('Descriptive text'))

    main_box.add_child(Button.new('Click me!') do
      puts 'Button clicked!'
    end)

    @input = main_box.add_child(InputField.new('Type something...'))
  end

  def draw
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
```

## TelaGiana Module

All widgets are wrapped in the `TelaGiana` module. You can either:

**Option 1: Use the namespace explicitly**
```ruby
@widget_manager = TelaGiana::WidgetManager.new(self)
main_box = @widget_manager.add_box(TelaGiana::Box.new(20, 20, 400, 300))
```

**Option 2: Include the module (recommended)**
```ruby
include TelaGiana
@widget_manager = WidgetManager.new(self)
main_box = @widget_manager.add_box(Box.new(20, 20, 400, 300))
```

## Available Widgets

### Header
```ruby
Header.new('Title', 1)  # level 1-6
```

### Paragraph
```ruby
Paragraph.new('Paragraph text', font_size=16, width=nil)
```

### Button
```ruby
Button.new('Label', width=nil, height=30) do
  # action on click
end
```

### InputField
```ruby
input = InputField.new('placeholder', width=150, height=30)
input.mode = :numeric_only  # numbers, dots and dashes only
input.mode = :one_word      # no spaces allowed
input.mode = nil            # default - all characters allowed
puts input.text  # read the text
```

### InputBox
```ruby
input_box = InputBox.new('placeholder', width=300, height=150)
input_box.text = "Line 1\nLine 2\nLine 3"  # set multi-line text
puts input_box.text  # read the text
```

### Box (Container)
```ruby
box = Box.new(x, y, width, height)
box.padding = 10
box.margin_x = 5
box.margin_y = 5
box.background_color = Gosu::Color::GRAY
box.border_color = Gosu::Color::BLACK
box.border_size = 2

box.add_child(widget)
```

### InvisibleButton
```ruby
InvisibleButton.new(width, height) do
  # action on click
end
```

### Spacer
```ruby
Spacer.new(x=nil, y=nil)  # empty space
```

### Br
```ruby
Br.new  # line break
```

## Event Handling

### Focus and Navigation
- **TAB**: Focus next widget
- **Shift+TAB**: Focus previous widget
- **Enter/Space**: Activate button when focused

### Mouse
- **Click**: Activate widget and set focus
- **Hover**: Visual effects on widgets

### InputBox Navigation
- **Enter**: New line
- **Arrow keys**: Navigate cursor
- **Home/End**: Beginning/end of line
- **Backspace/Delete**: Delete characters
- **Mouse click**: Position cursor

## Nested Boxes

```ruby
main_box = Box.new(0, 0, 400, 300)
inner_box = Box.new(10, 10, 200, 100)

inner_box.add_child(Button.new('In inner box'))
main_box.add_child(inner_box)
```

## Style Customization

```ruby
button = Button.new('Styled Button')
button.background_color = Gosu::Color::BLUE
button.text_color = Gosu::Color::WHITE
button.border_color = Gosu::Color::RED

input = InputField.new('Styled Input')
input.background_color = Gosu::Color::YELLOW
input.border_color = Gosu::Color::GREEN
input.mode = :one_word  # single word only
```

## Examples

- **Complete demo**: `example/example.rb` - Shows all widgets and features
- **InputBox demo**: `example/example_input_box.rb` - Multi-line text input demo

## Dependencies

- Ruby >= 2.7
- Gosu gem

## Version

Current version: 0.5.3

## License

This project is released under the LGPL-3.0 license. See the `LICENSE` file for details.

## Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
