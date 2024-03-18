# GEM
require 'gosu'

# Helpers
require_relative 'helpers/game_helper'

# Lib
require_relative 'lib/enemy'
require_relative 'lib/projectile'
require_relative 'lib/player'

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

    # Check projectile collision
    @projectiles.dup.each do |projectile|
      @enemies.dup.each do |enemy|
        if check_collision?(projectile, enemy)
          @projectiles.delete(projectile)
          @enemies.delete(enemy)
        end
      end
    end
    
    # Check enemy collision
    @enemies.dup.each do |enemy|
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
    message = "Game Over\nPress (R) to Restart or (Q) to Quit"
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

# Initialize Game
GameWindow.new.show