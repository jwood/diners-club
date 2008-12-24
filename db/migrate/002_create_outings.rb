class CreateOutings < ActiveRecord::Migration
  def self.up
    create_table :outings do |t|
      t.column :reservation_time, :datetime
      t.column :restaurant_name, :string
      t.column :restaurant_address_line_1, :string
      t.column :restaurant_address_line_2, :string
      t.column :restaurant_city, :string
      t.column :restaurant_state, :string
      t.column :restaurant_zip, :string
      t.column :restaurant_phone, :string
      t.column :restaurant_description, :text
      t.column :restaurant_website, :string
      t.column :diner_id, :integer
    end

    execute "alter table outings add constraint fk_sponsor foreign key (diner_id) references diners(id)"
  end

  def self.down
    drop_table :outings
  end
end
