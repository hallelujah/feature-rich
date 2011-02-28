class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.text :features
      t.string :featured_type
      t.string :featured_id
    end
  end

  def self.down
    drop_table :features
  end
end
