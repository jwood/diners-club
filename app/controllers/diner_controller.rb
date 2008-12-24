class DinerController < ApplicationController

  #----------------------------------------------------------------------------#
  # Get a list of the diners
  #----------------------------------------------------------------------------#
  def index
    @diners = Diner.find_all_in_order
  end
  
  #----------------------------------------------------------------------------#
  # Create a new diner or edit an existing one
  #----------------------------------------------------------------------------#
  def edit
    @diner = params[:id] && Diner.find_by_id(params[:id]) || Diner.new
    if request.post?
      @diner.attributes = params[:diner]
      if @diner.save
        redirect_to :action => 'show', :id => @diner
      else
        logger.error("Edit diner failed: #{@diner.errors.full_messages}")
        render :action => 'edit'
      end
    end
  end

  #----------------------------------------------------------------------------#
  # Show an diner's details
  #----------------------------------------------------------------------------#
  def show
    @diner = Diner.find(params[:id])
  end

end
