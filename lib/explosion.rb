# frozen_string_literal: true

class Explosion < Object
  attr_reader :done

  def initialize(window, x, y)
    @window = window
    @x  = x
    @y = y
    frame_width = 60
    frame_height = 60
    @frames = Gosu::Image.load_tiles(@window, "assets/sprites/explosion.png", frame_width, frame_height, false)
    @current_frame = 0

    @current_frame = 0
    @done = false
  end

  def update
    @current_frame += 1
    @done = true if @current_frame >= @frames.size
  end

  def draw
    if !@done && @current_frame < @frames.size
      frame = @frames[@current_frame]
      frame.draw(@x - frame.width / 2.0, @y - frame.height / 2.0, ZOrder::UI)
    end
  end

  def done?
    @done
  end
end