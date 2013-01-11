class String
  def foo
    "\n\t"+("-"*65)+"\n\t\t\t\t"+self+"\n\t"+"-"*65 + "\n"
  end
end

class DiceSet
  
  def self.roll(number) 
    values = []
    number.times{ values<<rand(1..6) }
    values
  end

  def self.score(dice,number) 
    
    score, sub, score_hash=0, 0, {}
    
    dice.sort.uniq.each do |num|
      score_hash[num] = dice.sort.count{|elem|elem == num }
      if score_hash[num] 
        score += score_hash[num] >=3 ? Proc.new {sub += 3;  score_hash[num]-=3 if num==1; num==1 ? 1000 : num*100 }.call : 0
        score += score_hash[num] < 3 && (num == 5 || num == 1) ? Proc.new{ sub+=score_hash[num]; num==1 ? score_hash[num]*100 : score_hash[num]*50 }.call : 0
      end
    end
    number-=sub
    number = (number==0 ? 5 : number)
    
    puts "Your dice #{dice.join("|")} Result: #{score}\n"
    [number, score]
    
  end
end

class Player
  attr_reader :general_points,:name
  
  def initialize(name)
    @skip = 0
    @general_points = 0
    @name = name
  end
  
  def my_turn *args
    @quantity_of_dice = 5
    roll_points = 0
    @skip -= 1 if @skip > 0
    
    begin
      if @skip == 0 || args[0] == :final
        @quantity_of_dice, points = make_roll
        roll_points += points
        puts "You have scored in this turn #{roll_points} and your accumulated points are #{@general_points}"
        @skip = (points == 0) ? 2 : 0
        

        if @skip == 2
          puts "It's pitty... You lost your roll with no points"
          roll_points = 0 
          break
        end
        puts "Say 'Stop', if you feel that you will loose next roll"
        break if /stop/ =~ $stdin.gets.downcase
      else
        puts "You skip your turn"
        break 
      end
    end until points == 0 

    @general_points += roll_points if (roll_points>=300 || @general_points>0)
  
  end

  def make_roll
    DiceSet.score(DiceSet.roll(@quantity_of_dice), @quantity_of_dice)
  end

end

class Game

  def initialize *players
    @@players = players
    cycle until @@players.select{|player|player.general_points >= 3000 }.size > 0
    puts "The final round!!!".foo
    cycle :final
    win_info = players.sort_by{|player| player.general_points }
    puts "#{win_info[-1].name} with score #{win_info[-1].general_points} is a winner!!!".foo
  end

  def cycle *args
    @@players.each do |player|
      puts "#{player.name}'s turn now!!!".foo
      player.my_turn args[0]
    end
  end
end


Game.new(Player.new("Victor"), Player.new("Mihail"), Player.new("Tatyana"))

# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.
