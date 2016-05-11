class Dice
  def self.roll(qtt)
    Array.new(qtt) { Random.rand(1..6) } if qtt.is_a?(Integer) && qtt > 0
  end
end
