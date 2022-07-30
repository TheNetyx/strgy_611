class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.integer :identifier
      t.string :name
      t.integer :t1
      t.integer :t2
      t.integer :t3
      t.integer :t4
      t.integer :t5
      t.integer :t6
      t.integer :t7
      t.integer :t8

      t.timestamps
    end
  end
end
