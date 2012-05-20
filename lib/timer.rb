class Timer
  def initialize
    @time = Time.now
  end

  def elapsed
    (Time.now - @time) * 1000.0
  end
end