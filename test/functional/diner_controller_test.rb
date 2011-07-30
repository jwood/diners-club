require File.dirname(__FILE__) + '/../test_helper'
require 'diner_controller'

class DinerControllerTest < ActionController::TestCase
  fixtures :diners

  def setup
    @john_id = diners(:john).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'

    assert_equal(3, assigns(:diners).size)
    assert(assigns(:diners).include?(diners(:john)))
    assert(assigns(:diners).include?(diners(:beth)))
    assert(assigns(:diners).include?(diners(:bob)))
  end

  def test_show
    get :show, :id => @john_id
    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:diner)
    assert assigns(:diner).valid?
    assert_equal(diners(:john), assigns(:diner))
  end

  def test_edit_get_form_for_new_diner
    get :edit
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:diner)
  end

  def test_edit_get_form_for_existing_diner
    get :edit, :id => @john_id
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:diner)
    assert assigns(:diner).valid?
    assert_equal(diners(:john), assigns(:diner))
  end

  def test_edit_post_update_for_existing_diner
    diner = diners(:john)
    diner.city = 'New York'
    post :edit, { :id => diner.id, :diner => diner.attributes }
    assert_redirected_to :action => 'show', :id => diner
    
    get :edit, :id => @john_id
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:diner)
    assert assigns(:diner).valid?
    assert_equal('New York', assigns(:diner).city)
  end

end
