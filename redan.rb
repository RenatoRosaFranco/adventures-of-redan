require 'gosu'
require_relative 'helpers/game_helper'

module ZOrder
  BACKGROUND, ENEMIES, PROJECTILES, PLAYER, UI = *0..4
end

# Main
class GameWindow < Gosu::Window
  def initialize
    super 640, 480
    self.caption = "Game Title"
    @player = Player.new(self)
    @enemies = []
    @projectiles = []
    @enemy_spawn_timer = 0
    @paused = false
    @font = Gosu::Font.new(20)
    @state = :playing
  end

  def update
    return if paused? || game_over?
  
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

    if @player.hp <= 0
      @state = :game_over
    end

    @enemy_spawn_timer -= 1
    if @enemy_spawn_timer <= 0
      @enemies.push(Enemy.new(self))
      @enemy_spawn_timer = rand(60..120)
    end
  
    @enemies.each(&:move_down)
    @enemies.reject! { |enemy| enemy.y > self.height }

    @projectiles.each(&:move)
    @projectiles.reject!{ |projectile| projectile.y < 0 }

    @enemies.each do |enemy|
      if check_collision?(@player, enemy)
        @player.take_damage(10)
        @enemies.delete(enemy)
      end
    end
  end

  def draw
    if @paused
      draw_paused_screen
    elsif game_over?
      draw_game_over_screen
    else
      @player.draw
      @enemies.each(&:draw)
      @projectiles.each(&:draw)
      @font.draw_text("HP: #{@player.hp}", 10, self.height - 30, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end
  end

  def draw_game_over_screen
    message = "Game Over\nPress R to Restar or Q to Quit"
    @font.draw_text(message, 320, 240, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  end

  def button_down(id)
    case id
    when Gosu::KB_SPACE
      unless @paused
        projectile_width = 10
        @projectiles.push(Projectile.new(self, @player.x + @player.width / 2 - projectile_width / 2, @player.y))
      end
    when Gosu::KB_R
      restart_game if game_over?
    when Gosu::KB_Q
      close if game_over?
    when Gosu::KB_ESCAPE
      @paused = !@paused
    end
  end

  private

  def paused?
    @paused == true
  end

  def game_over?
    @state == :game_over
  end

  def restart_game
    @player = Player.new(self)
    @enemies.clear
    @projectiles.clear
    @enemy_spawn_timer = 0
    @paused = false
    @state = :playing
  end

  def draw_paused_screen
    @font ||= Gosu::Font.new(20)
    @font.draw_text("Paused", 320, 240, 0) 
  end
end

# Enemy Class
class Enemy < Object
  attr_reader :x, :y

  def initialize(window)
    @image = Gosu::Image.new("sprites/enemy.png")
    @x = rand(window.width - @image.width)
    @y = -@image.height
    @speed = rand(5..10)
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def width
    @image.width
  end

  def height
    @image.height
  end

  def move_down
    @y += @speed
  end
end

# Projectile
class Projectile < Object
  attr_reader :x, :y

  def initialize(window, start_x, start_y)
    @image = Gosu::Image.new('sprites/projectile.png')
    @x = start_x
    @y = start_y
    @speed = -10
  end

  def move
    @y += @speed
  end

  def draw
    @image.draw(@x, @y, 1)
  end
end

# Player Class
class Player < Object
  attr_reader :x, :y
  attr_accessor :speed, :hp

  def initialize(window)
    @window = window
    @image = Gosu::Image.new("sprites/player.png")
    @x = @window.width / 2 - @image.width / 2
    @y = @window.height - @image.height - 100
    @speed = 5
    @hp = 100
  end

  def take_damage(amount)
    @hp -= amount
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def width
    @image.width
  end

  def height
    @image.height
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