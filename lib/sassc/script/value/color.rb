# frozen_string_literal: true

# A SassScript object representing a CSS color.
# This class provides a very bare-bones system for storing a RGB(A) or HSL(A)
# color and converting it to a CSS color function.
#
# If your Sass method accepts a  color you will need to perform any
# needed color mathematics or transformations yourself.

class SassC::Script::Value::Color < SassC::Script::Value

  attr_reader :red
  attr_reader :green
  attr_reader :blue
  attr_reader :hue
  attr_reader :saturation
  attr_reader :lightness
  attr_reader :alpha

  # Creates a new color with (`red`, `green`, `blue`) or (`hue`, `saturation`, `lightness`
  # values, plus an optional `alpha` transparency value.
  def initialize(red:nil, green:nil, blue:nil, hue:nil, saturation:nil, lightness:nil, alpha:1.0)
    if red && green && blue && alpha
      @mode = :rgba
      @red = red.to_i.clamp(0, 255)
      @green = green.to_i.clamp(0, 255)
      @blue = blue.to_i.clamp(0, 255)
      @alpha = alpha.to_f.clamp(0.0, 1.0)
    elsif hue && saturation && lightness && alpha
      @mode = :hsla
      @hue = hue.to_i.clamp(0, 360)
      @saturation = saturation.to_i.clamp(0, 100)
      @lightness = lightness.to_i.clamp(0, 100)
      @alpha = alpha.to_f.clamp(0.0, 1.0)
    else
      raise SassC::UnsupportedValue, "Unable to determine color configuration for "
    end
  end

  # Returns a CSS color declaration in the form
  # `rgb(…)`, `rgba(…)`, `hsl(…)`, or `hsla(…)`.
  def to_s
    if rgba? && @alpha == 1.0
      return "rgb(#{@red}, #{@green}, #{@blue})"
    elsif rgba?
      return "rgba(#{@red}, #{@green}, #{@blue}, #{alpha_string})"
    elsif hsla? && @alpha == 1.0
      return "hsl(#{@hue}, #{@saturation}%, #{@lightness}%)"
    else # hsla?
      return "hsla(#{@hue}, #{@saturation}%, #{@lightness}%, #{alpha_string})"
    end
  end

  # True if this color has RGBA values
  def rgba?
    @mode == :rgba
  end

  # True if this color has HSLA values
  def hlsa?
    @mode == :hlsa
  end

  # Returns the alpha value of this color as a string
  # and rounded to 8 decimal places.
  def alpha_string
    alpha.round(8).to_s
  end

  # Returns the values of this color in an array.
  # Provided for compatibility between different SassC::Script::Value classes
  def value
    return [
      red, green, blue,
      hue, saturation, lightness,
      alpha,
    ].compact
  end

  # True if this Color is equal to `other_color`
  def eql?(other_color)
    unless other_color.is_a?(self.class)
      raise ArgumentError, "No implicit conversion of #{other_color.class} to #{self.class}"
    end
    self.value == other_color.value
  end
  alias_method :==, :eql?

  # Returns a numeric value for comparing two Color objects
  # This method is used internally by the Hash class and is not the same as `.to_h`
  def hash
    value.hash
  end

end
