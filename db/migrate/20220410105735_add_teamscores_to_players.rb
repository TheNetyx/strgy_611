class AddTeamscoresToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :rounds, :t1s, :integer
    add_column :rounds, :t2s, :integer
    add_column :rounds, :t3s, :integer
    add_column :rounds, :t4s, :integer
    add_column :rounds, :t5s, :integer
    add_column :rounds, :t6s, :integer
    add_column :rounds, :t7s, :integer
    add_column :rounds, :t8s, :integer
  end
end
