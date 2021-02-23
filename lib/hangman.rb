# frozen_string_literal: true

require 'yaml'
# loads dictionary and plays game
class Game
  attr_reader :filled_blank, :failed_attempts_left

  def initialize
    @secret_word = load_word
    @filled_blank = Array.new(@secret_word.length, '_')
    @used_letters = []
    @failed_attempts_left = 8
    puts @filled_blank.join(' ')
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
    @dictionary = File.read('dictionary.txt').split("\n")
    output = @dictionary.sample
    output = @dictionary.sample until output.length.between?(5, 12)
    output.downcase
  end

  def confirm_letter(letter, game)
    while @used_letters.include?(letter) || !letter.match(/[a-z]/) || letter.length > 1
      save_game(game) if letter == 'save'
      puts 'Please enter a valid unused letter'
      letter = gets.chomp.downcase
    end
    letter
  end

  def loaded_game_stats
    puts "#{@failed_attempts_left} failed attempts remaining"
    puts "Used letters: #{@used_letters.sort.join(' ')}"
    puts "Puzzle: #{@filled_blank.join(' ')}"
  end

  def result_message
    if failed_attempts_left.positive?
      puts "Congratulations. The word was #{@secret_word}. You had #{@failed_attempts_left} failed attempts left"
    else
      puts "Unlucky the word was #{@secret_word} better luck next time"
    end
  end
end

def play_again
  puts 'Want to play again? Y/N'
  answer = gets.chomp.downcase
  until answer == 'n'
    save_or_load if answer == 'y'
    puts 'Want to play again? Y/N'
    answer = gets.chomp.downcase
  end
  puts 'Thanks for playing!'
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
  begin
    loaded_game = File.read("saves/#{gets.chomp.downcase}.yaml")
    game = YAML.safe_load(loaded_game, permitted_classes: [Game])
    game.loaded_game_stats
    play_game(game)
  rescue StandardError
    puts 'File not found starting new game'
    start_game
  end
end

def play_game(game)
  until game.failed_attempts_left.zero?
    puts 'Enter letter to guess or enter save to save and quit'
    game.play_round(game.confirm_letter(gets.chomp.downcase, game))
    break unless game.filled_blank.include?('_')
  end
  game.result_message
  play_again
end

def start_game
  game = Game.new
  play_game(game)
end

def save_or_load
  puts 'Press 1 to play, press 2 to load'
  response = gets.chomp.downcase
  response = gets.chomp.downcase until %w[1 2].include?(response)
  start_game if response == '1'
  load_game if response == '2'
end

save_or_load
