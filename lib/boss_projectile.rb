# frozen_string_literal: true

require_relative 'projectile'

class BossProjectile < Projectile
  attr_reader :damage

  def initialize(window, x, y)
    super(window, x, y, "assets/sprites/boss_projectile.png")
    @damage = 25
    @window = window
    @speed = -5
  end

  def move
    @y -= @speed
  end

  def out_of_bounds?
    @y > @window.height || @y < 0
  end
end
