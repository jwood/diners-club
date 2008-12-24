class DinersOutings < ActiveRecord::Migration
  def self.up
    create_table :diners_outings, :id => false do |t|
      t.column :outing_id, :integer
      t.column :diner_id, :integer
    end

    execute "alter table diners_outings add constraint fk_outing foreign key (outing_id) references outings(id)"
    execute "alter table diners_outings add constraint fk_diner foreign key (diner_id) references diners(id)"
  end

  def self.down
    drop_table :diners_outings
  end
end
