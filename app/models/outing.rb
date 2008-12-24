class Outing < ActiveRecord::Base

  has_and_belongs_to_many :diners
  has_and_belongs_to_many :declined_diners, :class_name => 'Diner', :join_table => 'declined_outings'
  belongs_to :diner
  belongs_to :afterparty_sponsor, :class_name => 'Diner', :foreign_key => 'afterparty_sponsor_id'
  
  validates_presence_of :reservation_time, :restaurant_name,
    :restaurant_address_line_1, :restaurant_city, :restaurant_state, :restaurant_zip,
    :restaurant_description

  #-----------------------------------------------------------------------------
  # Get the location of the afterparty, or nil if there is no afterparty
  #-----------------------------------------------------------------------------
  def afterparty_location
    location = nil
    
    if (!self.afterparty_sponsor.blank? || !self.afterparty_bar_name.blank?)
      location = {}
      if (!self.afterparty_sponsor.blank?)
        location.update(:address => self.afterparty_sponsor.address_line_1)
        location.update(:city => self.afterparty_sponsor.city)
        location.update(:state => self.afterparty_sponsor.state)
        location.update(:zip => self.afterparty_sponsor.zip)
      elsif (!self.afterparty_bar_name.blank?)
        location.update(:address => self.afterparty_address_line_1)
        location.update(:city => self.afterparty_city)
        location.update(:state => self.afterparty_state)
        location.update(:zip => self.afterparty_zip)
      end
    end
    
    location
  end
  
  #-----------------------------------------------------------------------------
  # Get the list of diners who have not responded to this outing
  #-----------------------------------------------------------------------------
  def unresponsive_diners
    unres_diners = Diner.find(:all)
    diners.each { |diner| unres_diners.delete(diner) } unless diners.blank?
    declined_diners.each { |diner| unres_diners.delete(diner) } unless declined_diners.blank?
    unres_diners
  end
  
  #-----------------------------------------------------------------------------
  # Override the default save method, stripping "http://" from the website
  # if it is included.  Then, call the default save method.
  #-----------------------------------------------------------------------------
  def save
    self.restaurant_website.gsub!('http://', '') unless self.restaurant_website.nil?

    # Hack to make the 11/2008 outing the 3rd Saturday of the month
    if !self.reservation_time.nil? && self.reservation_time.month == 11 && self.reservation_time.year == 2008
      self.reservation_time = self.reservation_time.advance(:days => 7)
    end 

    super
  end

  #-----------------------------------------------------------------------------
  # Perform additional validations before saving
  #-----------------------------------------------------------------------------
  def validate
    # Make sure that we only allow one sponsored outing per month
    unless diner.nil?
      outing = Outing.find(:first,
        :conditions => ['reservation_time > ? and reservation_time < ?', 
          reservation_time.at_midnight, reservation_time.tomorrow.at_midnight])
      
      if !outing.nil? && outing.id != id
        errors.add_to_base('Sponsored outing already scheduled for this month')
      end
    end
    
    # Make sure diners don't appear in both the attending and declined lists
    unless diners.blank?
      diners.each do |diner|
        if declined_diners.include?(diner)
          errors.add_to_base("#{diner.first_name} #{diner.last_name} can't be IN and OUT at the same time")
        end
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Returns the full address of the restaurant
  #-----------------------------------------------------------------------------
  def restaurant_address
    get_pretty_address(restaurant_address_line_1, restaurant_address_line_2, 
        restaurant_city, restaurant_state, restaurant_zip)
  end

  #-----------------------------------------------------------------------------
  # Returns the full address of the afterparty
  #-----------------------------------------------------------------------------
  def afterparty_address
    location = afterparty_location || {}
    get_pretty_address(location[:address], nil, location[:city], 
        location[:state], location[:zip])
  end

  #-----------------------------------------------------------------------------
  # Returns a string explaining what is different between the two Outings
  #-----------------------------------------------------------------------------
  def Outing.diff(new_outing, old_outing, old_in_diners, old_out_diners, 
      old_unresponsive_diners, old_afterparty_location)

    diff_text = ""

    if old_outing.restaurant_name != new_outing.restaurant_name
      diff_text << "Restaurant Name: #{new_outing.restaurant_name}\n"
    end

    if old_outing.reservation_time != new_outing.reservation_time
      diff_text << "Reservation Time: #{new_outing.reservation_time}\n"
    end
    
    if old_outing.restaurant_phone != new_outing.restaurant_phone
      diff_text << "Restaurant Phone: #{new_outing.restaurant_phone}\n"
    end

    if old_outing.restaurant_website != new_outing.restaurant_website
      diff_text << "Restaurant Website: #{new_outing.restaurant_website}\n"
    end

    if old_outing.restaurant_description != new_outing.restaurant_description
      diff_text << "Restaurant Description: #{new_outing.restaurant_description}\n\n"
    end

    if old_outing.restaurant_address != new_outing.restaurant_address
      diff_text << "Restaurant Address:\n#{new_outing.restaurant_address}\n\n"
    end

    if old_afterparty_location != new_outing.afterparty_location
      diff_text << "Afterparty Address:\n#{new_outing.afterparty_address}\n\n"
    end

    diner_names = diff_diner_list(old_in_diners, new_outing.diners)
    diff_text << "Diners In:\n#{diner_names}\n" unless diner_names.blank?
    
    diner_names = diff_diner_list(old_out_diners, new_outing.declined_diners)
    diff_text << "Diners Out:\n#{diner_names}\n" unless diner_names.blank?
    
    diner_names = diff_diner_list(old_unresponsive_diners, new_outing.unresponsive_diners)
    diff_text << "Unresponsive Diners:\n#{diner_names}\n" unless diner_names.blank?
    
    diff_text
  end

  #-----------------------------------------------------------------------------
  # Find all outings that have not taken place yet
  #-----------------------------------------------------------------------------
  def Outing.find_upcoming_outings
    Outing.find(:all, 
      :conditions => ['reservation_time >= ? and diner_id is not null', Time.now],
      :order => 'reservation_time ASC')
  end
  
  #-----------------------------------------------------------------------------
  # Find all outings that have already taken place
  #-----------------------------------------------------------------------------
  def Outing.find_past_outings
    Outing.find(:all, 
      :conditions => ['reservation_time < ? and diner_id is not null', Time.now],
      :order => 'reservation_time DESC')
  end
  
  #-----------------------------------------------------------------------------
  # Find all outings that have been suggested (no sponsor)
  #-----------------------------------------------------------------------------
  def Outing.find_suggested_outings
    Outing.find(:all,
      :conditions => 'diner_id is null', 
      :order => 'reservation_time ASC')
  end
  
  ##############################################################################
  private
  ##############################################################################

  def Outing.diff_diner_list(old_list, new_list)
    diner_names = ""
    if old_list != new_list
      new_list.each do |diner| 
        diner_names << "#{diner.first_name} #{diner.last_name}\n" unless old_list.include?(diner)
      end
    end
    diner_names
  end
  
  #-----------------------------------------------------------------------------
  # Returns a pretty printable representation of an address
  #-----------------------------------------------------------------------------
  def get_pretty_address(line_1, line_2, city, state, zip)
    address = ""
    address << "#{line_1}\n" unless line_1.blank?
    address << "#{line_2}\n" unless line_2.blank?
    address << "#{city}, #{state} #{zip}" if (!city.blank? && !state.blank? && !zip.blank?)
    address
  end

end
