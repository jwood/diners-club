class CreateDiners < ActiveRecord::Migration
  def self.up
    create_table :diners do |t|
      t.column :first_name, :string, :null => false
      t.column :last_name, :string, :null => false
      t.column :email, :string
      t.column :address_line_1, :string
      t.column :address_line_2, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string
      t.column :food_preferences, :text
    end
  end

  def self.down
    drop_table :diners
  end
end
