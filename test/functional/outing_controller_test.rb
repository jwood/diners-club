require File.dirname(__FILE__) + '/../test_helper'
require 'outing_controller'
require 'app_config'

# Re-raise errors caught by the controller.
class OutingController; def rescue_action(e) raise e end; end

class OutingControllerTest < Test::Unit::TestCase
  fixtures :outings, :diners

  def setup
    @controller = OutingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    
    assert_equal(2, assigns(:upcoming_outings).size)
    assert(assigns(:upcoming_outings).include?(outings(:bobs_beef_shack)))
    assert(assigns(:upcoming_outings).include?(outings(:joes_italian)))

    assert_equal(1, assigns(:past_outings).size)
    assert(assigns(:past_outings).include?(outings(:some_past_outing)))
    
    assert_equal(1, assigns(:suggested_outings).size)
    assert(assigns(:suggested_outings).include?(outings(:some_suggested_outing)))
  end

  def test_show
    for outing in [outings(:bobs_beef_shack), outings(:joes_italian)]
      get :show, :id => outing
      assert_response :success
      assert_template 'show'

      assert_not_nil assigns(:outing)
      assert assigns(:outing).valid?

      assert_not_nil assigns(:diners)
      assert_equal(2, assigns(:diners).size)
      assert assigns(:diners).include?(diners(:john))
      assert assigns(:diners).include?(diners(:beth))
    end
  end
  
  def test_get_map_to_restaurant
    get :get_map_to_restaurant, :id => outings(:bobs_beef_shack)
    assert_redirected_to "http://maps.google.com/maps?q=333+South+Ave.,Chicago,IL+60606"    
  end
  
  def test_get_directions_to_restaurant
    outing = outings(:bobs_beef_shack)
    diner_name = diners(:john).comma_seperated_display_name
    get :get_directions_to_restaurant, { :id => outing, :diner_name => diner_name }
    assert_redirected_to "http://maps.google.com/maps?daddr=333+South+Ave.,Chicago,IL+60606&saddr=123+Main+St.,Chicago,IL+60606"        
  end
  
  def test_get_map_to_afterparty
    get :get_map_to_afterparty, :id => outings(:bobs_beef_shack)
    assert_redirected_to "http://maps.google.com/maps?q=456+North+St.,Chicago,IL+60606"    
  end
  
  def test_get_directions_to_afterparty
    get :get_directions_to_afterparty, :id => outings(:bobs_beef_shack)
    assert_redirected_to "http://maps.google.com/maps?daddr=456+North+St.,Chicago,IL+60606&saddr=333+South+Ave.,Chicago,IL+60606"        
  end
  
  def test_send_new_outing_email
    post :send_new_outing_email, :id => outings(:bobs_beef_shack)
    assert_redirected_to :action => 'show'
  end
  
  def test_edit_get_form_for_new_outing
    get :edit
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:outing)
    assert_equal(3, assigns(:diners).size)
  end

  def test_edit_get_form_for_existing_outing
    for outing in [outings(:bobs_beef_shack), outings(:joes_italian)]
      get :edit, :id => outing.id
      assert_response :success
      assert_template 'edit'

      assert_not_nil assigns(:outing)
      assert assigns(:outing).valid?
      assert_equal(outing, assigns(:outing))
      assert_equal(3, assigns(:diners).size)
    end
  end

  def test_edit_post_update_for_existing_outing
    outing = outings(:bobs_beef_shack)
    outing.restaurant_city = 'New York'
    post :edit, { :id => outing.id, :outing => outing.attributes }
    assert_redirected_to :action => 'show'

    get :edit, :id => outing.id
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:outing)
    assert assigns(:outing).valid?
    assert_equal('New York', assigns(:outing).restaurant_city)
  end

  def test_feedback
    get :feedback
    assert_response :success
    assert_template 'feedback'
    assert_equal(AppConfig.instance.admin_email, assigns(:admin_email))
  end
  
end
