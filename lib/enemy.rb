# frozen_string_literal: true

class Enemy < Object
  attr_reader :x, :y

  def initialize(window, x = nil, y = nil, image_path = nil)
    image = !image_path.nil? ? image_path : "assets/sprites/enemy.png"

    @image = Gosu::Image.new(image)
    @x = x || rand(window.width - @image.width)
    @y = y || -@image.height
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