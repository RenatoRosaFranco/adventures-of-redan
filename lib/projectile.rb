# frozen_string_literal: true

class Projectile < Object
  attr_reader :x, :y

  def initialize(window, start_x, start_y)
    @image = Gosu::Image.new('assets/sprites/projectile.png')
    @x = start_x
    @y = start_y
    @speed = -10
  end

  def move
    @y += @speed
  end

  def width
    @image.width
  end

  def height
    @image.height
  end

  def draw
    @image.draw(@x, @y, 1)
  end
end