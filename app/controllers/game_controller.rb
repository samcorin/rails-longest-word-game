require 'open-uri'
require 'json'
require 'date'

class GameController < ApplicationController
  API_KEY = '59da5eda-0869-4522-ab0a-02b8d21ac30e'

  def game
    # CHOOSE SIZE

    # @input_size = params[:size].to_i
    # @grid = generate_grid(@input_size)
    @grid = generate_grid(13)
    @start_time = Time.now

  end

  def score
    @failed_attempt = ["No points for you.", "Try again.", "What was that?", "Are you feeling ok?", "This isn't getting any better", "You're making us all look bad."].sample
    @attempt = params[:attempt]
    @end_time = Time.now
    # @end_time = params[:end_time]
    @grid = params[:grid]
    @start_time = params[:start_time]

    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  # **************************************************************************** #

  def generate_grid(grid_size)
    (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
  end

  def in_grid?(grid, attempt)
    grid = grid.join.downcase.split("")
    attempt = attempt.split("")

    attempt.all? { |e| grid.include?(e) }
  end

  def compute_score(word, time)
    (word.length * 12) - (time * 3)
  end

  def run_game(attempt, grid, start_time, end_time)
    arr = JSON.parse(grid)

    return { score: 0, message: "Not even possible" } unless in_grid?(arr, attempt)
    return { score: 0, message: "That ain't English" } unless word_exists?(attempt.downcase)

    @time = time_elapsed(start_time, end_time)
    @score = compute_score(attempt, @time)
    if attempt.length <= 3
      @message = ["At least you tried.", "Could've been worse.", "Next!", "Congrats!"].sample
    elsif attempt.length <= 5
      @message = "Pretty good..."
    else
      @message = "Wow..."
    end

    return { time: @time, translation: translator(attempt), score: @score, message: @message }
  end

  def time_elapsed(start_time, end_time)
    return end_time.to_i - start_time.to_i
  end

  def word_exists?(word)
    words = File.read('/usr/share/dict/words').downcase.split("\n")
    words.include?(word.downcase)
  end

  def translator(word)
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{API_KEY}&input=#{word}"
    word_serialized = open(url).read
    result = JSON.parse(word_serialized)
    result["outputs"][0]["output"]
  end
end
