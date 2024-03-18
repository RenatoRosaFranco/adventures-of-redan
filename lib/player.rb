# frozen_string_literal: true

class Player < Object
  attr_reader :x, :y
  attr_accessor :speed, :hp

  def initialize(window)
    @window = window
    @image = Gosu::Image.new("assets/sprites/player.png")
    @x = @window.width / 2 - @image.width / 2
    @y = @window.height - @image.height - 100
    @speed = 4
    @boosted_speed = 8
    @hp = 100
  end

  def take_damage(damage_amount)
    @hp -= damage_amount
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
    base_speed = boost? ? @boosted_speed : @speed
    @x = [@x - base_speed, 0].max
  end

  def move_right
    base_speed = boost? ? @boosted_speed : @speed
    @x = [@x + base_speed, @window.width - @image.width].min
  end

  def move_up
    base_speed = boost? ? @boosted_speed : @speed
    @y = [@y - base_speed, 0].max
  end

  def move_down
    base_speed = boost? ? @boosted_speed : @speed
    @y = [@y + base_speed, @window.height - @image.height].min
  end

  def boost?
    @window.button_down?(Gosu::KB_LEFT_SHIFT) || @window.button_down?(Gosu::KB_RIGHT_SHIFT)
  end
end