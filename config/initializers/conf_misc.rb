class PlayerConf
  NUM_TEAMS = 8
end

class RoundsConf
  STATE_ACCEPT_MOVES = 0
  STATE_CONFLICTING = 1
end

class ItemConf
  module FieldsConstants
    CELL = 0b00001 # cell; incompatabile with TEAM and NOCP
    TEAM = 0b00010 # choose team by picking base
    NOCP = 0b00100 # cannot choose cp (for teleporter)
    ALIV = 0b01000 # alive player
    DEAD = 0b10000 # dead player
  end
  ITEMS = [
    {identifier: 0, name: "bomb", fields: FieldsConstants::CELL},
    {identifier: 1, name: "locator", fields: FieldsConstants::CELL},
    {identifier: 2, name: "instant respawn", fields: FieldsConstants::DEAD},
    {identifier: 3, name: "minus points card", fields: FieldsConstants::TEAM},
    {identifier: 4, name: "teleporter", fields: FieldsConstants::ALIV | FieldsConstants::NOCP}
  ]
end

# yes, team names are hard coded in because i'm lazy
class TeamConf
  NAMES = [
    nil, # a r r a y   i n d i c e s   s t a r t   a t   1
    "T1",
    "T2",
    "T3",
    "T4",
    "T5",
    "T6",
    "T7",
    "T8",
  ]
end
