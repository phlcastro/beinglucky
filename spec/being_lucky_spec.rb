require 'being_lucky'

describe BeingLucky do
  let(:valid_init_options) { { no_players: 3 } }
  let(:valid_game) { BeingLucky.new(valid_init_options) }

  describe '::calculate_roll_points' do
    context 'when receives a valid parameter' do
      it 'returns 1000 as total points and [2,3] as remaining dices for [1,1,1,2,3]' do
        total, remaining_roll = BeingLucky.calculate_roll_points([1, 1, 1, 2, 3])
        expect(total).to eq(1000)
        expect(remaining_roll).to eq([2, 3])
      end

      it 'returns 1000 as total points and [2,3] as remaining dices for [1,1,1,1,3]' do
        total, remaining_roll = BeingLucky.calculate_roll_points([1, 1, 1, 1, 3])
        expect(total).to eq(1100)
        expect(remaining_roll).to eq([3])
      end

      it 'returns 1000 as total points and [2,3] as remaining dices for [1,1,2,3,5]' do
        total, remaining_roll = BeingLucky.calculate_roll_points([1, 1, 2, 3, 5])
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

  describe '::new' do
    context 'when receives a valid parameter' do
      it 'returns a valid BeingLucky object' do
        expect(BeingLucky.new(valid_init_options)).to be_a BeingLucky
      end
    end

    context 'when receives an invalid parameter' do
      it 'returns an error for parameter not being a Hash' do
        expect { BeingLucky.new([3]) }.to raise_error('options is not a valid Hash object')
      end

      it 'returns an error for parameter having unknow option' do
        expect { BeingLucky.new(no_players: 3, invalid_option: 1) }.to raise_error('options has invalid entries')
      end

      it 'returns an error for invalid no_players option' do
        expect { BeingLucky.new(no_players: 0) }.to raise_error('no_players must be an integer between 2 and 9')
      end
    end
  end

  describe '#players' do
    context 'with a new BeingLucky object with no rounds played' do
      it 'returns the initial number of players' do
        expect(valid_game.players.length).to eq(valid_init_options[:no_players])
      end
    end
  end

  describe '#joined_game?' do
    context 'with a new BeingLucky object with no rounds played' do
      it 'returns that players has not joined game yet' do
        valid_init_options[:no_players].times do |i|
          expect(valid_game.joined_game?(i + 1)).to eq(false)
        end
      end

      it 'returns true if a player successfully joined the game' do
        allow(Dice).to receive(:roll).with(5).and_return([1, 1, 1, 3, 4])
        result = valid_game.join_game(1)
        expect(result).to eq([true, [1, 1, 1, 3, 4], 1000])
      end

      it 'returns false if a player didnt join the game' do
        allow(Dice).to receive(:roll).with(5).and_return([1, 5, 1, 3, 4])
        result = valid_game.join_game(1)
        expect(result).to eq([false, [1, 5, 1, 3, 4], 250])
      end

      it 'returns an error when player not found' do
        expect { valid_game.joined_game?(valid_init_options[:no_players] + 2) }.to raise_error('Player not found')
      end

      it 'returns an error for invalid player id' do
        expect { valid_game.joined_game?('1') }.to raise_error('Invalid player id')
      end

      it 'returns an error if player have already joined the game' do
        allow(Dice).to receive(:roll).with(5).and_return([1, 1, 1, 3, 4])
        valid_game.join_game(1)
        expect { valid_game.join_game(1) }.to raise_error('Player already joined the game')
      end
    end
  end

  describe '#player_next_roll' do
    context 'with a valid BeingLucky object' do
      context 'and with no rounds played' do
        it 'returns 5 for all players' do
          valid_init_options[:no_players].times do |i|
            expect(valid_game.player_next_roll(i + 1)).to eq(5)
          end
        end
      end

      it 'returns 2 after player joined game with [1,1,1,3,4] roll' do
        allow(Dice).to receive(:roll).with(5).and_return([1, 1, 1, 3, 4])
        valid_game.join_game(1)
        expect(valid_game.player_next_roll(1)).to eq(2)
      end

      it 'returns an error when player not found' do
        expect { valid_game.player_next_roll(valid_init_options[:no_players] + 2) }.to raise_error('Player not found')
      end

      it 'returns an error for invalid player id' do
        expect { valid_game.player_next_roll('1') }.to raise_error('Invalid player id')
      end
    end
  end

  describe '#player_current_points' do
    context 'with a valid BeingLucky object' do
      context 'and with no rounds played' do
        it 'returns 0 for all players' do
          valid_init_options[:no_players].times do |i|
            expect(valid_game.player_current_points(i + 1)).to eq(0)
          end
        end
      end

      it 'returns 1000 after player joined game with [1,1,1,3,4] roll' do
        allow(Dice).to receive(:roll).with(5).and_return([1, 1, 1, 3, 4])
        valid_game.join_game(1)
        expect(valid_game.player_current_points(1)).to eq(1000)
      end

      it 'returns an error when player not found' do
        expect { valid_game.player_current_points(valid_init_options[:no_players] + 2) }.to raise_error('Player not found')
      end

      it 'returns an error for invalid player id' do
        expect { valid_game.player_current_points('1') }.to raise_error('Invalid player id')
      end
    end
  end

  describe '#roll_dices' do
    context 'with a valid BeingLucky object' do
      it 'returns 100 with [1,4] roll' do
        allow(Dice).to receive(:roll).with(5).and_return([1, 1, 1, 3, 4])
        allow(Dice).to receive(:roll).with(2).and_return([1, 4])
        valid_game.join_game(1)
        expect(valid_game.roll_dices(1)).to eq([100, [1, 4]])
      end

      it 'updates correctly the player points if result > 0' do
        allow(Dice).to receive(:roll).with(5).and_return([1, 1, 1, 3, 4])
        allow(Dice).to receive(:roll).with(2).and_return([1, 4])
        valid_game.join_game(1)
        valid_game.roll_dices(1)
        expect(valid_game.player_current_points(1)).to eq(1100)
      end

      it 'updates correctly the player points if result = 0' do
        allow(Dice).to receive(:roll).with(5).and_return([1, 1, 1, 3, 4])
        allow(Dice).to receive(:roll).with(2).and_return([3, 4])
        valid_game.join_game(1)
        valid_game.roll_dices(1)
        expect(valid_game.player_current_points(1)).to eq(0)
      end

      it 'returns an error if player had not joined the game' do
        expect { valid_game.roll_dices(1) }.to raise_error('Player not joined the game')
      end
    end
  end
end
