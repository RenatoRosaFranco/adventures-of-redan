# Gem
require 'gosu'

# Helpers
require_relative 'helpers/game_helper'

# Lib
require_relative 'lib/explosion'
require_relative 'lib/boss'
require_relative 'lib/enemy'
require_relative 'lib/player'
require_relative 'lib/projectile'

module ZOrder
  BACKGROUND, ENEMIES, PROJECTILES, PLAYER, UI = *0..4
end

# Main
class GameWindow < Gosu::Window
  attr_accessor :score, :survived_waves

  def initialize
    super 640, 480
    self.caption = "Redan Adventures"
    @player = Player.new(self)
    @enemies = []
    @projectiles = []
    @enemy_spawn_timer = 0
    @paused = false
    @font = Gosu::Font.new(20)
    @state = :title
    @score = 480
    @survived_waves = 0
    @boss = nil
    @boss_spawn_threshold = 500
    @selected_option = :new_game
    @explosions = []
    @explosion_sound = Gosu::Sample.new("assets/sounds/effects/explosion.mp3")
    @background_music = Gosu::Song.new("assets/sounds/midis/title.mp3")
    @background_music.play(true)
  end

  def update
    return if paused? || game_over?

    handle_player_movement
    handle_projectile_movement

    if @player.hp <= 0
      @state = :game_over
    end

    spawn_enemies_or_boss

    handle_enemies
    handle_collisions
    handle_explosions
  end

  def handle_player_movement
    @player.move_left if Gosu.button_down?(Gosu::KB_LEFT) || Gosu.button_down?(Gosu::GP_LEFT)
    @player.move_right if Gosu.button_down?(Gosu::KB_RIGHT) || Gosu.button_down?(Gosu::GP_RIGHT)
    @player.move_up if Gosu.button_down?(Gosu::KB_UP) || Gosu.button_down?(Gosu::GP_UP)
    @player.move_down if Gosu.button_down?(Gosu::KB_DOWN) || Gosu.button_down?(Gosu::GP_DOWN)
  end

  def handle_enemies
    @enemies.each(&:move_down)
    @enemies.reject! { |enemy| enemy.y > self.height } 
  end

  def handle_projectile_movement
    @projectiles.each(&:move)
    @projectiles.reject! { |projectile| projectile.y < 0 }
  end

  def handle_explosions
    @explosions.each(&:update)
    @explosions.reject!(&:done?)
  end

  def handle_collisions
    @projectiles.dup.each do |projectile|
      @enemies.dup.each do |enemy|
        if check_collision?(projectile, enemy)
          create_explosion_at(enemy.x, enemy.y) 
          @projectiles.delete(projectile)
          @enemies.delete(enemy)
          @score += 10
          @explosion_sound.play
        end
      end

      if @boss && check_collision?(projectile, @boss)
        create_explosion_at(projectile.x, projectile.y) 
        @projectiles.delete(projectile)
        @boss.take_damage(10)
        @explosion_sound.play
      end
    end
    
    @enemies.dup.each do |enemy|
      if check_collision?(@player, enemy)
        @player.take_damage(10)
        @enemies.delete(enemy)
        create_explosion_at(enemy.x, enemy.y) 
        @explosion_sound.play
      end
    end
  end

  def draw
    case @state
    when :title
      draw_title_screen
    when :playing
      draw_playing_screen
    when :game_over
      draw_game_over_screen
    end
  end

  def draw_playing_screen
    @explosions.each(&:draw)
  end

  def create_explosion_at(x, y)
    @explosions.push(Explosion.new(self, x, y))
  end

  def draw_playing_screen
    if @paused
      draw_paused_screen
    else
      @player.draw
      @enemies.each(&:draw)
      @projectiles.each(&:draw)
      @explosions.each(&:draw)
      @font.draw_text("HP: #{@player.hp}", 10, self.height - 30, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
  
      if @boss
        @boss&.draw
        @boss.draw_projectiles
        draw_boss_hp
      end
  
      score_text = "Score: #{@score}"
      text_width = @font.text_width(score_text)
      @font.draw_text(score_text, self.width - text_width - 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)

      survived_waves_text = "Survived waves: #{@survived_waves}"
      text_width = @font.text_width(survived_waves_text)
      @font.draw_text(survived_waves_text, self.width - text_width - 10, 30, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end
  end

  def draw_title_screen
    new_game_color = @selected_option == :new_game ? Gosu::Color::YELLOW : Gosu::Color::WHITE
    quit_color = @selected_option == :quit ? Gosu::Color::YELLOW : Gosu::Color::WHITE
  
    @font.draw_text("Adventures of Redan", 200, 150, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    @font.draw_text("New Game", 280, 250, ZOrder::UI, 1.0, 1.0, new_game_color)
    @font.draw_text("Quit", 280, 300, ZOrder::UI, 1.0, 1.0, quit_color)

    indicator_x = 250
    indicator_y = @selected_option == :new_game ? 250 : 300
    @font.draw_text(">", indicator_x, indicator_y, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  end

  def start_new_game
    @state = :playing
  end

  def draw_game_over_screen
    message = "Game Over\nPress (R) to Restart or (Q) to Quit"
    @font.draw_text(message, 320, 240, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
  end

  def draw_boss_hp
    return unless @boss

    bar_width = 200
    bar_height = 20
    padding = 30
    hp_ratio = @boss.hp.to_f / @boss.initial_hp

    Gosu.draw_rect(padding, padding, bar_width, bar_height, Gosu::Color::GRAY, ZOrder::UI)
    Gosu.draw_rect(padding, padding, bar_width * hp_ratio, bar_height, Gosu::Color::RED, ZOrder::UI)
    @font.draw_text("Boss HP: #{@boss.hp}", padding, padding - 20, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
  end

  def check_boss_projectile_collisions
    @boss.projectiles.dup.each do |proj|
      if check_collision?(proj, @player)
        @player.take_damage(proj.damage)
        @boss.projectiles.delete(proj)
      end
    end
  end

  def button_down(id)
    case @state
    when :title
      case id
      when Gosu::KB_DOWN
        @selected_option = (@selected_option == :new_game) ? :quit : :new_game
      when Gosu::KB_UP
        @selected_option = (@selected_option == :quit) ? :new_game : :quit
      when Gosu::KB_RETURN, Gosu::KB_ENTER
        @selected_option == :new_game ? start_new_game : close
      when Gosu::KB_ESCAPE
        close
      end
    when :playing
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
    when :game_over
      if id == Gosu::KB_R
        restart_game
      elsif id == Gosu::KB_Q
        close
      end
    end
  end

  private

  def spawn_enemies_or_boss
    if @boss
      @boss.update
      check_boss_projectile_collisions
  
      if @boss.defeated
        reset_for_normal_enemy_spawn
      end
    else
      @enemy_spawn_timer -= 1

      if @score >= @boss_spawn_threshold && @boss.nil?
        spawn_boss
      elsif @enemy_spawn_timer <= 0
        spawn_enemy
      end
    end 
  end
  
  def reset_for_normal_enemy_spawn
    @boss = nil
    @boss_spawn_threshold = ((@score / 500) + 1) * 500
    @enemy_spawn_timer = rand(60..120)
  end

  def spawn_boss
    @boss = Boss.new(self)
    @enemy_spawn_timer = Float::INFINITY
  end

  def spawn_enemy
    @enemies.push(Enemy.new(self))
    @enemy_spawn_timer = rand(60..120)
  end

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