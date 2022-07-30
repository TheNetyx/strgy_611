class CreateRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :rounds do |t|
      t.integer :round
      t.boolean :t1
      t.boolean :t2
      t.boolean :t3
      t.boolean :t4
      t.boolean :t5
      t.boolean :t6
      t.boolean :t7
      t.boolean :t8

      t.timestamps
    end
  end
end
