require 'gosu'

# Main
class GameWindow < Gosu::Window
  def initialize
    super 640, 480
    self.caption = "Game Title"
    @player = Player.new(self)
  end

  def update
    if Gosu.button_down?(Gosu::KB_LEFT) || 
      Gosu.button_down?(Gosu::GP_LEFT)
      @player.move_left
    end
    
    if Gosu.button_down?(Gosu::KB_RIGHT) || 
      Gosu.button_down?(Gosu::GP_RIGHT)
      @player.move_right
    end
    
    if Gosu.button_down?(Gosu::KB_UP) || 
      Gosu.button_down?(Gosu::GP_UP)
      @player.move_up
    end
    
    if Gosu.button_down?(Gosu::KB_DOWN) || 
      Gosu.button_down?(Gosu::GP_DOWN)
      @player.move_down
    end
  end

  def draw
    @player.draw
  end
end

# Enemy Class
class Enemy < Object
  attr_reader :x, :y

  def initialize(window)
    @image = Gosu::Image.new(window, "", false)
    @x = rand(window.width - @image.width)
    @y = -@image.height
    @speed = rand(3..6)
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def move_down
    @y += @speed
  end
end

# Player Class
class Player < Object
  attr_reader :x, :y
  attr_accessor :speed

  def initialize(window)
    @image = Gosu::Image.new(window, "", false)
    @x = @y = 0.0
    @speed = 5
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def move_left
    @x = [@x - @speed, 0].max
  end

  def move_right
    @x = [@x + @speed, window.width - @image.width].min
  end

  def move_up
    @y = [@y - @speed, 0].max
  end

  def move_down
    @y = [@y + @speed, window.height - @image.height].min
  end
end

# Initialize Game
GameWindow.new.show