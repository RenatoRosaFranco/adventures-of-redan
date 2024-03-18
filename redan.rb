require 'gosu'

# Main
class GameWindow < Gosu::Window
  def initialize
    super 640, 480
    self.caption = "Game Title"
    @player = Player.new(self)
    @enemies = []
    @enemy_spawn_timer = 0
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

    @enemy_spawn_timer -= 1
    if @enemy_spawn_timer <= 0
      @enemies.push(Enemy.new(self))
      @enemy_spawn_timer = rand(60..120)
    end
  
    @enemies.each(&:move_down)
    @enemies.reject! { |enemy| enemy.y > self.height }
  end

  def draw
    @player.draw
    @enemies.each(&:draw)
  end
end

# Enemy Class
class Enemy < Object
  attr_reader :x, :y

  def initialize(window)
    @image = Gosu::Image.new("enemy.png")
    @x = rand(window.width - @image.width)
    @y = -@image.height
    @speed = rand(5..10)
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
    @window = window
    @image = Gosu::Image.new("player.png")
    @x = @window.width / 2 - @image.width / 2
    @y = @window.height - @image.height - 100
    @speed = 5
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def move_left
    @x = [@x - @speed, 0].max
  end

  def move_right
    @x = [@x + @speed, @window.width - @image.width].min
  end

  def move_up
    @y = [@y - @speed, 0].max
  end

  def move_down
    @y = [@y + @speed, @window.height - @image.height].min
  end
end

# Initialize Game
GameWindow.new.show