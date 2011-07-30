class Diner < ActiveRecord::Base

  has_and_belongs_to_many :outings
  has_and_belongs_to_many :declined_outings, :class_name => "Outing", :join_table => 'declined_outings'
  validates_presence_of :first_name, :last_name
  
  def display_name
    "#{first_name} #{last_name}"
  end
  
  def comma_seperated_display_name
    "#{last_name}, #{first_name}"
  end
  
  def Diner.find_all_in_order(conditions = "")
    if (conditions.empty?)
      Diner.find(:all, :order => 'last_name ASC, first_name ASC')
    else
      Diner.find(:all, :order => 'last_name ASC, first_name ASC', :conditions => conditions)
    end
  end
  
  def Diner.find_all_in_order_with_address
    Diner.find_all_in_order("address_line_1 != ''")    
  end
  
  def Diner.find_by_first_and_last_name(name)
    last_name, first_name = name.split(', ')
    Diner.find(:first, :conditions => ['last_name = ? and first_name = ?', 
        last_name, first_name] )
  end

  def Diner.find_by_address(address_line_1, address_line_2, city, state, zip)
    Diner.find(:first, :conditions => ['address_line_1 = ? and address_line_2 = ? and city = ? and state = ? and zip = ?',
        address_line_1, address_line_2, city, state, zip] )
  end

end
