class GridConf
=begin
  private
  @@grid_gen = [
    0,0,2,2,0,2,2,0,0,
    0,0,2,1,1,1,2,0,0,
    0,2,1,1,1,1,1,2,0,
    2,2,1,1,1,1,1,2,2,
    0,0,1,1,1,1,1,0,0,
    0,0,2,2,1,2,2,0,0,
    0,0,2,0,0,0,2,0,0
  ]
  @@grid_gen_orig = @@grid_gen.dup

  (0..(@@grid_gen.length - 1)).each do |i|
    case @@grid_gen[i]
    when 0
      @@grid_gen[i] = "hexanone"
    when 1
      @@grid_gen[i] = "hexagon sel"
    when
      @@grid_gen[i] = "hexagon base"
    end
  end

  public
  GRID_CONF_ID = @@grid_gen_orig
  GRID_CONF_NAME = @@grid_gen
=end
  GRID_CONF = [
    1, 0, 0, 0, 2,  0, 0, 0, 3,
    0, 0, 0, 0, 0,  0, 0, 0, 0,
    0, 0, 0, 0, 0,  0, 0, 0, 0,
    0, 0, 0, 0, 0,  0, 0, 0, 0,
    4, 0, 0, 0, 10, 0, 0, 0, 5,
    0, 0, 0, 0, 0,  0, 0, 0, 0,
    0, 0, 0, 0, 0,  0, 0, 0, 0,
    0, 0, 0, 0, 0,  0, 0, 0, 0,
    6, 0, 0, 0, 7,  0, 0, 0, 8,
  ]

  GRID_NAME = [
    "",
    "team1",  # bases
    "team2",
    "team3",
    "team4",
    "team5",
    "team6",
    "team7",
    "team8",
    "checkpoint",
    "super-checkpoint"
  ]

  GRIDSIZE = 9
  private
  valid_spaces = []
  team_bases = [nil]
  checkpoints = []
  super_checkpoints = []
  i = 0
  (1..9).each do |y|
    (1..9).each do |x|
      valid_spaces.push({x: x, y: y})

      team_bases[GRID_CONF[i]] = {x: x, y:y} if GRID_CONF[i] >= 1 && GRID_CONF[i] <= 8

      checkpoints.push({x: x, y: y}) if GRID_CONF[i] == 9
      super_checkpoints.push({x: x, y: y}) if GRID_CONF[i] == 10

      i += 1
    end
  end
  public
  VALID_SPACES = valid_spaces
  TEAM_BASES = team_bases
  CHECKPOINTS = checkpoints
  SUPER_CHECKPOINTS = super_checkpoints
  ALL_CP = TEAM_BASES + CHECKPOINTS + SUPER_CHECKPOINTS

  CP_POINTS = 2
  SUPER_CP_POINTS = 5
  ENEMY_IN_BASE_PENALTY = 5
end

class TheGrid
  def self.valid_moves player
    moves = [
      {x: player.xpos, y: player.ypos},
      {x: player.xpos, y: player.ypos + 1},
      {x: player.xpos, y: player.ypos + 2},
      {x: player.xpos, y: player.ypos - 1},
      {x: player.xpos, y: player.ypos - 2},

      {x: player.xpos - 1, y: player.ypos},
      {x: player.xpos - 1, y: player.ypos + 1},
      {x: player.xpos - 1, y: player.ypos - 1},


      {x: player.xpos + 1, y: player.ypos},
      {x: player.xpos + 1, y: player.ypos + 1},
      {x: player.xpos + 1, y: player.ypos - 1},

      {x: player.xpos + 2, y: player.ypos},
      {x: player.xpos + 2, y: player.ypos + 1},
      {x: player.xpos + 2, y: player.ypos - 1},

      {x: player.xpos - 2, y: player.ypos},
      {x: player.xpos - 2, y: player.ypos + 1},
      {x: player.xpos - 2, y: player.ypos - 1},
    ];

    if (player.xpos % 2) == 1
      moves.push({x: player.xpos - 1, y: player.ypos - 2})
      moves.push({x: player.xpos + 1, y: player.ypos - 2})
    else
      moves.push({x: player.xpos - 1, y: player.ypos + 2})
      moves.push({x: player.xpos + 1, y: player.ypos + 2})
    end
    moves.each do |m|
      moves.delete m unless GridConf::VALID_SPACES.include? m
    end
    moves
  end

  def self.is_valid_space? coords
    i = 0
    (1..7).each do |y|
      (1..9).each do |x|
        if (x == coords[:x] && y == coords[:y])
          return GridConf::GRID_CONF[i] != 0
        end
        i += 1
      end
    end
    false
  end
end
