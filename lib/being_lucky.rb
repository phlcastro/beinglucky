require_relative 'dice'

class BeingLucky
  def self.calculate_roll_points(roll)
    validate_roll!(roll)

    total = 0

    total, remaining_roll = three_of_a_kind(roll)

    remaining_roll.delete_if do |dice|
      case dice
      when 1
        total += 100
        true
      when 5
        total += 50
        true
      else
        false
      end
    end

    [total, remaining_roll]
  end

  def self.validate_roll!(roll)
    raise 'roll parameter must be an Array' unless roll.is_a?(Array)
    raise 'roll Array can\'t be empty' if roll.empty?
    raise 'roll Array size must be between 1 and 5' if roll.length > 5
    roll.each { |n| raise 'invalid roll value' unless n.is_a?(Integer) && (1..6) === n }
  end
  private_class_method :validate_roll!

  def self.three_of_a_kind(roll)
    result_point = 0
    result_roll  = roll.clone

    dice_face = roll.select { |row| roll.count(row) > 2 }.uniq
    unless dice_face.empty?
      result_point = case dice_face.first
                     when 1 then 1000
                     when 6 then 600
                     when 5 then 500
                     when 4 then 400
                     when 3 then 300
                     when 2 then 200
                     end

      3.times { result_roll.delete_at(result_roll.index(dice_face.first)) }
    end

    [result_point, result_roll]
  end
  private_class_method :three_of_a_kind
end
