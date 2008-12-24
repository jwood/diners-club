class DeclinedOutings < ActiveRecord::Migration
  def self.up
    create_table :declined_outings, :id => false do |t|
      t.column :outing_id, :integer
      t.column :diner_id, :integer
    end

    execute "alter table declined_outings add constraint fk_declined_outing foreign key (outing_id) references outings(id)"
    execute "alter table declined_outings add constraint fk_declined_diner foreign key (diner_id) references diners(id)"
  end

  def self.down
    drop_table :declined_outings
  end
end
