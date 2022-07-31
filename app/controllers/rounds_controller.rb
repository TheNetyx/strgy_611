class RoundsController < ApplicationController
  before_action :auth_admin, only: [:start, :advance, :check_sub_all]
  before_action :auth_teamid, only: [:get_score, :check_sub]


  def get_round
    render json: {data: Round.first[:round]}
  end
=begin
  def get_score
    render json: {data: Round.first["t#{params[:teamid]}s".to_sym]}
  end

  def get_score_all
    render json: {data: [
      Round.first[:t1s],
      Round.first[:t2s],
      Round.first[:t3s],
      Round.first[:t4s],
      Round.first[:t5s],
      Round.first[:t6s]
    ]}
  end
=end
  def check_sub
    render json: {data: Round.first["t#{params[:teamid]}".to_sym]}
  end

  def check_sub_all
    @round = Round.first
    @data = [ # using (1..6).each and to_sym causes runtime errors for some reason
      @round.t1,
      @round.t2,
      @round.t3,
      @round.t4,
      @round.t5,
      @round.t6,
      @round.t7,
      @round.t8
    ]

    render json: {data: @data}
  end

  def start
    Round.all.each do |r|
      r.destroy
    end
    @game = Round.new
    @game.round = 1

    (1..PlayerConf::NUM_TEAMS).each do |i|
      @game.send("t#{i}=", false)
      @game.send("t#{i}s=", 0)
    end

    @game.state = RoundsConf::STATE_ACCEPT_MOVES
    @game.save

    # set up items
    Item.all.each do |item|
      item.delete
    end
    ItemConf::ITEMS.each do |item|
      new_item = Item.new
      new_item.identifier = item[:identifier]
      new_item.name = item[:name]
      new_item.fields = item[:fields]
      (1..PlayerConf::NUM_TEAMS).each do |i|
        new_item.send("t#{i}=", 0)
      end
      new_item.save
    end

    redirect_back_or_to root_path
  end

  def advance
    @game = Round.all.first

    if @game[:state] == RoundsConf::STATE_CONFLICTING
      # conflict state -> move state

      @game.state = RoundsConf::STATE_ACCEPT_MOVES
      # check for remaining conflicts - do not allow admin overriding
      # this probably isnt a very efficient way of doing things.

# items caused errors, so it's temporarily
=begin
      # items take effect here.
      # known bug: respawn messages get deleted. i'm not gonna fix this, it's not
      # game breaking and i can't be bothered to deal with it.
      ItemLog.destroy_all
      # creating a model isn't the most elegant solution, but it is a solution
      ItemRequest.all.each do |req|
        self.class.process req[:team], req[:item], req[:targetcell], req[:targetplayer]
        req.save
      end
      ItemRequest.destroy_all
=end
      @locations = []
      Player.where("alive = true").each do |p|
        @locations.push({x: p.xpos, y: p.ypos})
      end
      if @locations.detect{ |e| @locations.count(e) > 1 } && ! all_same_team(@locations)
        flash[:notice] = ["unresolved conflicts"]
        redirect_back_or_to root_path and return
      end
      # calculate scores
      @scores = []
      (1..PlayerConf::NUM_TEAMS).each do
        @scores.push 0
      end
      GridConf::CHECKPOINTS.each do |cp|
        collection = Player.where("xpos = ? AND ypos = ? AND alive = true", cp[:x], cp[:y])
        if collection.count <= 0
          break
        elsif collection.count == 1
          @scores[collection.first.team - 1] += GridConf::CP_POINTS
        else
          @scores[collection.first.team - 1] += (GridConf::CP_POINTS * 1.5).to_i
        end
      end

      GridConf::SUPER_CHECKPOINTS.each do |cp|
        collection = Player.where("xpos = ? AND ypos = ? AND alive = true", cp[:x], cp[:y])
        if collection.count <= 0
          break
        elsif collection.count == 1
          @scores[collection.first.team - 1] += GridConf::SUPER_CP_POINTS
        else
          @scores[collection.first.team - 1] += (GridConf::SUPER_CP_POINTS * 1.5).to_i
        end
      end

      GridConf::TEAM_BASES.each do |cp|
        collection = Player.where("xpos = ? AND ypos = ? AND alive = true", cp[:x], cp[:y])
        if collection.count > 0
          @scores[GridConf::TEAM_BASES.find_index cp] -= GridConf::ENEMY_IN_BASE_PENALTY
        end
        break
      end

      # this is probably not the best way to do this, but somehow
      # doing clever shit causes 'cannot coerce nil to float' errors
      # so im doing it the retarded way
      (1..PlayerConf::NUM_TEAMS).each do |i|
        @game.send("t#{i}s=", @game.send("t#{i}s") + @scores[i - 1])
        @game.send("t#{i}=", false)
      end
      @game.round += 1

      # revive dead people
      Player.where("respawn_round = ?", @game.round).each do |p|
        p.alive = true
        p.xpos = GridConf::TEAM_BASES[p.team - 1][:x]
        p.ypos = GridConf::TEAM_BASES[p.team - 1][:y]
        p.save
      end
    else
      # move state -> conflict state

      @game.state = RoundsConf::STATE_CONFLICTING
      (1..PlayerConf::NUM_TEAMS).each do |i|
        @game.send("t#{i}=", true)
      end
    end
    @game.save
    redirect_back_or_to root_path
  end

  private
  def all_same_team arr
    if arr.length == 0
      return true
    end
    team = arr[0][:team]
    arr.each do |item|
      if item[:team] != team
        return false
      end
    end
    true
  end

  # processes usage of items
  def self.process t, i, c, p
    case i

    # bomb
    when 0
      kills = 0
      coords = c.split "-"
      players = Player.where("xpos = ?", coords[1].to_i).where("ypos = ?", coords[2].to_i)
      players.each do |p|
        p.alive = false
        p.respawn_round = Round.first[:round] + 2
        kills += 1 if p.save
      end
      add_item_log "team #{t} (#{TeamConf::NAMES[t]}) bombed #{c}, killing #{kills}"

    # locator
    when 1
      coords = c.split "-"
      count = Player.where("xpos = ?", coords[1].to_i).where("ypos = ?", coords[2].to_i).count
      add_item_log "team #{t}  (#{TeamConf::NAMES[t]}) revealed #{count} enemies on square #{c}"

    # instant respawn is number 2, skip

    # minus points card
    when 3
      coords = c.split "-"
      team = GridConf::TEAM_BASES.index({x: coords[1].to_i, y: coords[2].to_i}) + 1
      round = Round.first
      round["t#{team}s".to_sym] -= 10
      round.save
      add_item_log "team #{t} (#{TeamConf::NAMES[t]}) used minus points card on team #{team} (#{TeamConf::NAMES[team]}) "

    # teleporter
    when 4
      coords = c.split "-"
      player = Player.find p
      player.xpos = coords[1].to_i
      player.ypos = coords[2].to_i
      player.save
      add_item_log "team #{t} (#{TeamConf::NAMES[t]}) teleported #{player[:name]} to #{c}"
    else
      add_item_log "ERR: team #{t} (#{TeamConf::NAMES[t]}) used an invalid item"
    end
  end
end
