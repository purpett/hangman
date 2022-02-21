require 'json'

def get_word
  lines = File.readlines('dictionary.txt').map { |word| word.strip }
  good_words = lines.select do |word|
    word.length <= 12 && word.length >= 5
  end
  good_words.sample
end

def hide_word(secret_word)
  secret_word.map do
    "_"
  end
end

def take_guess(character)
  if $secret_word.include?(character)
    $secret_word.each_with_index do |ch, i|
      if ch == character 
        $hidden_word[i] = ch
      end
    end
    true
  else 
    $wrong_guesses << character
    false
  end
end

def begin_game(selection)
  if selection == "1"
    $wrong_guesses = []
    $all_guesses = []
    $secret_word = get_word().chars 
    $hidden_word = hide_word($secret_word)
  elsif selection == "2"
    puts "Please type name of saved game:"
    saved_game = gets.chomp
    if File.exists?("#{saved_game}.json")
      loaded_data = load_file(saved_game)
      $secret_word = loaded_data["secret_word"]
      $all_guesses = loaded_data["all_guesses"]
      $wrong_guesses = loaded_data["wrong_guesses"]
      $hidden_word = loaded_data["hidden_word"]
      puts "You have already guessed: #{$wrong_guesses.join(" ")}"
      puts "Wrong guess(es) remaining: #{8 - $wrong_guesses.length}."
    end
  else 
    puts "Invalid selection, try again:"
  end
end

def load_file(name)
  file = File.read("#{name}.json")
  JSON.parse(file)
end

puts "Hangman!"
puts "Would you like to:"
puts "1 - Play a game"
puts "2 - Load a game"

selection = gets.chomp 
begin_game(selection)

puts $hidden_word.join(" ")
puts "Your turn to guess one letter in the secret word."
puts "You can also type 'save' or 'exit' to leave the game."

until $wrong_guesses.length == 8 
  case character = gets.chomp.downcase
  when "save"
    puts "Enter name for saved game:"
    filename = gets.chomp
    data = {
      secret_word: $secret_word,
      all_guesses: $all_guesses,
      wrong_guesses: $wrong_guesses,
      hidden_word: $hidden_word
    }

    File.write("#{filename}.json", data.to_json)
    puts "Your game has been saved."
    exit
  when "exit"
    exit
  when /^[a-z]$/
    if $all_guesses.include?(character)
      puts "Try again! You have already guessed this letter."
    else
      $all_guesses << character
      if take_guess(character)
        if $hidden_word == $secret_word
          puts "CONGRATULATIONS! You have guessed the word!"
          puts $hidden_word.join
          exit
        else 
          puts "Good guess!"
        end
      else
        puts "Wrong guess!"
      end
      puts $hidden_word.join(" ")
    end
    puts "You have already guessed: #{$wrong_guesses.join(" ")}"
    puts "Wrong guess(es) remaining: #{8 - $wrong_guesses.length}."
  else
    puts "Invalid selection, please try again"
  end  
  puts "Your turn to guess one letter in the secret word."
  puts "You can also type 'save' or 'exit' to leave the game."
end

puts "OH NO! Too bad, you haven't guessed the word."