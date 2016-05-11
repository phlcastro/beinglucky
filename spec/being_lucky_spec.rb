require 'being_lucky'

describe BeingLucky do
  let(:first_valid_roll) { [1, 1, 1, 2, 3] }
  let(:second_valid_roll) { [1, 1, 1, 1, 3] }
  let(:third_valid_roll) { [1, 1, 2, 3, 5] }

  describe '::calculate_roll_points' do
    context 'when receives a valid parameter' do
      it 'returns 1000 as total points and [2,3] as remaining dices for [1,1,1,2,3]' do
        total, remaining_roll = BeingLucky.calculate_roll_points(first_valid_roll)
        expect(total).to eq(1000)
        expect(remaining_roll).to eq([2, 3])
      end

      it 'returns 1000 as total points and [2,3] as remaining dices for [1,1,1,1,3]' do
        total, remaining_roll = BeingLucky.calculate_roll_points(second_valid_roll)
        expect(total).to eq(1100)
        expect(remaining_roll).to eq([3])
      end

      it 'returns 1000 as total points and [2,3] as remaining dices for [1,1,2,3,5]' do
        total, remaining_roll = BeingLucky.calculate_roll_points(third_valid_roll)
        expect(total).to eq(250)
        expect(remaining_roll).to eq([2, 3])
      end
    end

    context 'when receives an invalid parameter' do
      it 'returns an error for parameter not being an Array' do
        expect { BeingLucky.calculate_roll_points('1,2,3') }.to raise_error('roll parameter must be an Array')
      end

      it 'returns an error for parameter being an empty Array' do
        expect { BeingLucky.calculate_roll_points([]) }.to raise_error('roll Array can\'t be empty')
      end

      it 'returns an error for parameter having an Array length bigger than 5' do
        expect { BeingLucky.calculate_roll_points([1, 2, 3, 4, 5, 1]) }.to raise_error('roll Array size must be between 1 and 5')
      end

      it 'returns an error for parameter having an Array with invalid value' do
        expect { BeingLucky.calculate_roll_points([1, 2, 3, 4, '5']) }.to raise_error('invalid roll value')
      end
    end
  end
end
