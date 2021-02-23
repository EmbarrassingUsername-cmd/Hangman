require 'yaml'
# loads dictionary and plays game
class Game
  attr_reader :filled_blank, :failed_attempts_left
  attr_accessor :disable_save

  @@dictionary = File.read('dictionary.txt').split("\n")

  def initialize
    p @secret_word = load_word
    p @filled_blank = Array.new(@secret_word.length, '_')
    p @used_letters = []
    @failed_attempts_left = 8
    @disable_save = false
  end

  def play_round(letter)
    result_array = check_letters(letter)
    result_array.each { |index| @filled_blank[index] = letter }
    puts "#{@failed_attempts_left} failed attempts remaining"
    puts @filled_blank.join(' ')
    @used_letters << letter
    puts @used_letters.sort.join(' ')
  end

  def check_letters(letter)
    result = []
    if @secret_word.include?(letter)
      @secret_word.each_char.with_index do |char, index|
        result << index if char == letter
      end
    else @failed_attempts_left -= 1
    end
    result
  end

  def load_word
    output = @@dictionary.sample
    output = @@dictionary.sample until output.length.between?(5, 12)
    output.downcase
  end

  def confirm_letter(letter)
    while @used_letters.include?(letter) || !letter.match(/[a-z]/) || letter.length > 1
      puts 'Please enter a valid unused letter'
      letter = gets.chomp.downcase
    end
    letter
  end

  def loaded_game_stats
    puts "#{@failed_attempts_left} failed attempts remaining"
    puts @filled_blank.join(' ')
    puts @used_letters.sort.join(' ')
  end
end

def start_game
  game = Game.new
  play_game(game)
end

def play_again
  puts 'Want to play again? Y/N'
  answer = gets.chomp.downcase
  until answer == 'n'
    play_game if answer == 'y'
    puts 'Want to play again? Y/N'
    answer = gets.chomp.downcase
  end
end

def confirm_save(game)
  puts 'Save and quit? Y/N. Type disable to turn off saving' unless game.disable_save == true
  answer = ''
  answer = gets.chomp.downcase until (%w[y n disable].include? answer) || game.disable_save == true
  save_game(game) if answer == 'y'
  game.disable_save = true if answer == 'disable'
end

def save_game(game)
  save = YAML.dump(game)
  Dir.mkdir('saves') unless Dir.exist?('saves')
  puts 'Enter name for save'
  name = gets.chomp.downcase
  File.open("saves/#{name}.yaml", 'w') { |file| file.puts save }
  exit
end

def load_game
  puts 'Enter save name'
  name = gets.chomp.downcase
  begin
    loaded_game = File.read("saves/#{name}.yaml")
    game = YAML.safe_load(loaded_game, permitted_classes: [Game])
    game.loaded_game_stats
    play_game(game)
  rescue StandardError => e
    p e
    puts 'File not found starting new game'
    start_game
  end
end

def play_game(game)
  until game.failed_attempts_left.zero?
    puts 'Enter '
    game.play_round(game.confirm_letter(gets.chomp.downcase))
    break unless game.filled_blank.include?('_')

    confirm_save(game)
  end
  play_again
end

def save_or_load
  puts 'Press 1 to play, press 2 to load'
  response = gets.chomp.downcase
  response = gets.chomp.downcase until %w[1 2].include?(response)
  start_game if response == '1'
  load_game if response == '2'
end

save_or_load
