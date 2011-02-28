class CreateSuperHeros < ActiveRecord::Migration

  def self.up
    create_table :super_heros do |t|
      t.string :name
    end
  end
  
  def self.down
    drop_table :super_heros
  end
end
