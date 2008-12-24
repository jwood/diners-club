class AddAfterpartyLocation < ActiveRecord::Migration
  def self.up
    add_column 'outings', 'afterparty_bar_name', :string
    add_column 'outings', 'afterparty_address_line_1', :string
    add_column 'outings', 'afterparty_address_line_2', :string
    add_column 'outings', 'afterparty_city', :string
    add_column 'outings', 'afterparty_state', :string
    add_column 'outings', 'afterparty_zip', :string
    add_column 'outings', 'afterparty_sponsor_id', :integer
    
    execute "alter table outings add constraint fk_afterparty_sponsor_id foreign key (afterparty_sponsor_id) references diners(id)"
  end

  def self.down
    execute "alter table outings drop foreign key fk_afterparty_sponsor_id"

    remove_column 'outings', 'afterparty_bar_name'
    remove_column 'outings', 'afterparty_address_line_1'
    remove_column 'outings', 'afterparty_address_line_2'
    remove_column 'outings', 'afterparty_city'
    remove_column 'outings', 'afterparty_state'
    remove_column 'outings', 'afterparty_zip'
    remove_column 'outings', 'afterparty_sponsor_id'
  end
end
