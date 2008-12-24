class AddChangeEmailPreference < ActiveRecord::Migration
  def self.up
    add_column 'diners', 'send_email_on_outing_change', :boolean, :default => true
  end

  def self.down
    remove_column 'diners', 'send_email_on_outing_change'
  end
end
