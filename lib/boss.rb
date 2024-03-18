# frozen_string_literal: true

require_relative 'enemy'

class Boss < Enemy
  attr_reader :hp, :initial_hp
  attr_accessor :defeated, :score

  def initialize(window)
    super(window, window.width / 2, 0, "assets/sprites/enemy.png")
    @window = window
    @hp = 300
    @initial_hp = hp
    @direction = :right
    @vertical_speed = 1
    @horizontal_speed = 2
    @move_down_every = 100
    @move_counter = 0
    @defeated = false
  end

  def update
    if @direction == :right
      if @x + @horizontal_speed + @image.width > @window.width
        @x = @window.width - @image.width
        @direction = :left
      else
        @x += @horizontal_speed
      end
    elsif @direction == :left
      if @x - @horizontal_speed < 0
        @x = 0
        @direction = :right
      else
        @x -= @horizontal_speed
      end
    end

    @move_counter += 1
    if @move_counter >= @move_down_every
      @y += @vertical_speed
      @move_counter = 0
    end
  end

  def draw
    super
  end

  def take_damage(amount)
    @hp -= amount
    if @hp <= 0
      handle_defeat
    end
  end

  private

  def handle_defeat
    @window.score += 500
    @defeated = true
  end
end