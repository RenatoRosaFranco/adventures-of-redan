# frozen_string_literal: true

class Enemy < Object
  attr_reader :x, :y

  def initialize(window)
    @image = Gosu::Image.new("assets/sprites/enemy.png")
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