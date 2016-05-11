require 'dice'

describe Dice do
  describe '::roll' do
    context 'when receives a valid parameter' do
      it 'returns an array object' do
        expect(Dice.roll(5)).to be_a Array
      end

      it 'returns an array of specified size' do
        expect(Dice.roll(5).length).to eq(5)
      end
    end

    context 'when receives an invalid parameter' do
      it 'returns nil for strings' do
        expect(Dice.roll('5')).to be_nil
      end

      it 'returns nil for values equal zero' do
        expect(Dice.roll(0)).to be_nil
      end

      it 'returns nil for values less than zero' do
        expect(Dice.roll(-1)).to be_nil
      end
    end
  end
end
