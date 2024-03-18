# frozen_string_literal: true

class Player < Object
  attr_reader :x, :y
  attr_accessor :speed, :hp

  def initialize(window)
    @window = window
    @image = Gosu::Image.new("assets/sprites/player.png")
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