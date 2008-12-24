require 'app_config'

class OutingController < ApplicationController

  #----------------------------------------------------------------------------#
  # Get a list of the outings
  #----------------------------------------------------------------------------#
  def index
    @upcoming_outings = Outing.find_upcoming_outings
    @past_outings = Outing.find_past_outings
    @suggested_outings = Outing.find_suggested_outings
  end
  
  #----------------------------------------------------------------------------#
  # Create a new outing or edit an existing one
  #----------------------------------------------------------------------------#
  def edit
    @diners = Diner.find_all_in_order
    
    is_new_outing = false
    if params[:id] && Outing.find_by_id(params[:id])
      @outing = Outing.find_by_id(params[:id])
    else
      @outing = Outing.new
      is_new_outing = true
    end
    
    if request.post?
      old_outing = @outing.clone
      old_in_diners = @outing.diners.clone
      old_out_diners = @outing.declined_diners.clone
      old_unresponsive_diners = @outing.unresponsive_diners.clone
      old_afterparty_location = @outing.afterparty_location
      
      @outing.attributes = params[:outing]
      @outing.diners = get_attendees(params)
      @outing.declined_diners = get_declined_diners(params)
      @outing.reservation_time = get_reservation_time(params)
      @outing = populate_afterparty_info(@outing, params)
      
      if @outing.save
        if !@outing.diner.blank? && @outing.diner.send_email_on_outing_change && !is_new_outing
          diff = Outing.diff(@outing, old_outing, old_in_diners, old_out_diners,
            old_unresponsive_diners, old_afterparty_location)
          OutingMailer.deliver_modified_outing(@outing, diff) unless diff.blank?
        end
        redirect_to :action => 'show', :id => @outing
      else
        logger.error("Edit outing failed: #{@outing.errors.full_messages}")
        render :action => 'edit'
      end
    end
  end

  #----------------------------------------------------------------------------#
  # Show an outing's details
  #----------------------------------------------------------------------------#
  def show
    @outing = Outing.find(params[:id])
    
    # This is used for getting directions, so only select the Diners that have
    # addresses.
    @diners = Diner.find_all_in_order_with_address
  end

  #----------------------------------------------------------------------------#
  # Get a map of the restaurant's location
  #----------------------------------------------------------------------------#
  def get_map_to_restaurant
    outing = Outing.find(params[:id])
    redirect_to generate_map_link(outing.restaurant_address_line_1, 
      outing.restaurant_city, outing.restaurant_state, outing.restaurant_zip)
  end
  
  #----------------------------------------------------------------------------#
  # Get directions to an outing from a Diner's address
  # 
  # Note: Will not work if 2 diners have the same first and last name, but
  # different addresses.
  #----------------------------------------------------------------------------#
  def get_directions_to_restaurant
    outing = Outing.find(params[:id])
    diner = Diner.find_by_first_and_last_name(params[:diner_name])
    generate_directions_link(diner.address_line_1, diner.city, diner.state, diner.zip,
      outing.restaurant_address_line_1, outing.restaurant_city, outing.restaurant_state,
      outing.restaurant_zip)
  end
  
  #----------------------------------------------------------------------------#
  # Get a map of the afterparty's location
  #----------------------------------------------------------------------------#
  def get_map_to_afterparty
    outing = Outing.find(params[:id])
    location = outing.afterparty_location
    redirect_to generate_map_link(location[:address], location[:city],
      location[:state], location[:zip])
  end
  
  #----------------------------------------------------------------------------#
  # Get directions from the restaurant to the afterparty
  #----------------------------------------------------------------------------#
  def get_directions_to_afterparty
    outing = Outing.find(params[:id])
    location = outing.afterparty_location
    generate_directions_link(outing.restaurant_address_line_1, outing.restaurant_city,
      outing.restaurant_state, outing.restaurant_zip, location[:address], 
      location[:city], location[:state], location[:zip])
  end

  #----------------------------------------------------------------------------#
  # Send the "new outing" email to the list of diners to announce the outing
  # 
  # Using "post" to prevent things like Google's Web Accelerator from following
  # the "Send outing announcement email" link and triggering the email.
  #----------------------------------------------------------------------------#
  def send_new_outing_email
    outing = Outing.find(params[:id])
    if request.post? && outing.reservation_time >= Time.now
      diners = Diner.find(:all, :conditions => 'email != ""')
      OutingMailer.deliver_new_outing(outing, diners)
      flash[:notice] = 'Email sent successfully!'
    end
    redirect_to :action => 'show', :id => outing
  end
  
  #----------------------------------------------------------------------------#
  # Display the application feedback page
  #----------------------------------------------------------------------------#
  def feedback
    @admin_email = AppConfig.instance.admin_email 
  end
  
  ##############################################################################
  private
  ##############################################################################

  #----------------------------------------------------------------------------#
  # Get the reservation date/time of the outing
  #----------------------------------------------------------------------------#
  def get_reservation_time(params)
    year, month, hour, minute = 0

    for param in params
      if param.first == 'date'
        for date_param in param.last
          year = date_param.last if date_param.first == 'year'
          month = date_param.last if date_param.first == 'month'
          hour = date_param.last if date_param.first == 'hour'
          minute = date_param.last if date_param.first == 'minute'
        end
      end
    end

    # Get the second Saturday of the month
    time = Time.local(year, month, 1, hour, minute, 0)
    time = time.tomorrow while time.wday != 6
    time = time.advance(:days => 7)
    time
  end  
    
  #----------------------------------------------------------------------------#
  # Get the list of diners that are attending an outing
  #----------------------------------------------------------------------------#
  def get_attendees(params)
    get_diners(params, 'attending_')
  end

  #----------------------------------------------------------------------------#
  # Get the list of diners that have declined this outing
  #----------------------------------------------------------------------------#
  def get_declined_diners(params)
    get_diners(params, 'declined_')
  end
  
  #----------------------------------------------------------------------------#
  # Get the list of diners for the specified parameter prefix
  #----------------------------------------------------------------------------#
  def get_diners(params, param_prefix)
    diners = []
    for param in params
      if param.first =~ Regexp.new(param_prefix)
        diners << Diner.find_by_id(param.first.gsub(param_prefix, '').to_i)
      end
    end
    diners
  end
  
  #----------------------------------------------------------------------------#
  # Populate the afterparty address information
  #----------------------------------------------------------------------------#
  def populate_afterparty_info(outing, params)
    if (params['afterparty'] == 'diners_house')
      outing.afterparty_bar_name = ''
      outing.afterparty_address_line_1 = ''
      outing.afterparty_address_line_2 = ''
      outing.afterparty_city = ''
      outing.afterparty_state = ''
      outing.afterparty_zip = ''
      diner = Diner.find_by_first_and_last_name(params['afterparty_sponsor_name'])
      outing.afterparty_sponsor = diner

    elsif (params['afterparty'] == 'bar')
      # No need to "copy" in bar address since they are part of outing's params
      outing.afterparty_sponsor = nil
      
    elsif (params['afterparty'] == 'none')
      outing.afterparty_bar_name = ''
      outing.afterparty_address_line_1 = ''
      outing.afterparty_address_line_2 = ''
      outing.afterparty_city = ''
      outing.afterparty_state = ''
      outing.afterparty_zip = ''
      outing.afterparty_sponsor = nil
    end

    outing
  end
  
  #-----------------------------------------------------------------------------
  # Generate a map link to the specified location
  #-----------------------------------------------------------------------------
  def generate_map_link(address, city, state, zip)
    query = address + ',' + city + ',' + state + ' ' + zip
    query.gsub!(' ', '+')
    'http://maps.google.com/maps?q=' + query
  end

  #-----------------------------------------------------------------------------
  # Generate directions from the source to the destination
  #-----------------------------------------------------------------------------
  def generate_directions_link(s_address, s_city, s_state, s_zip,
      d_address, d_city, d_state, d_zip)
    query = 'daddr=' + d_address + ',' + d_city + ',' + d_state + ' ' + d_zip
    query += '&saddr=' + s_address + ',' + s_city + ',' + s_state + ' ' + s_zip
    query.gsub!(' ', '+')
    redirect_to 'http://maps.google.com/maps?' + query
  end  

end
