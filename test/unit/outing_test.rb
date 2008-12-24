require File.dirname(__FILE__) + '/../test_helper'

class OutingTest < Test::Unit::TestCase
  fixtures :outings, :diners

  def setup
    @outing = Outing.new(:reservation_time => DateTime.new(2020, 06, 01, 17, 00),
                         :restaurant_name => 'Blah Diner',
                         :restaurant_address_line_1 => '333 South Ave.',
                         :restaurant_city => 'Chicago',
                         :restaurant_state => 'IL',
                         :restaurant_zip => '60606',
                         :restaurant_description => 'Test with bad URL',
                         :restaurant_website => 'http://johnpwood.net')
  end
  
  def test_afterparty_location_at_bar
    outing = Outing.find(1)
    location = outing.afterparty_location
    assert_equal location[:address], '456 North St.'
    assert_equal location[:city], 'Chicago'
    assert_equal location[:state], 'IL'
    assert_equal location[:zip], '60606'
  end

  def test_afterparty_location_at_diners_home
    outing = Outing.find(2)
    location = outing.afterparty_location
    assert_equal location[:address], '123 Main St.'
    assert_equal location[:city], 'Chicago'
    assert_equal location[:state], 'IL'
    assert_equal location[:zip], '60606'
  end

  def test_unresponsive_diners
    outing = Outing.find(1)
    unresponsive = outing.unresponsive_diners
    assert_equal unresponsive.size, 3
  end

  def test_save
    @outing.save
    saved_outing = Outing.find_by_restaurant_name('Blah Diner')
    assert_equal 'johnpwood.net', saved_outing.restaurant_website
  end
  
  def test_create_second_outing_for_a_given_month
    assert @outing.valid?
    @outing.diner = diners(:john)
    assert !@outing.valid?
  end
  
  def test_diners_cannot_be_in_and_out_at_the_same_time
    @outing.diners << diners(:john)
    assert @outing.valid?
    @outing.declined_diners << diners(:john)
    assert !@outing.valid?
  end
  
  def test_restaurant_address
    assert_equal "333 South Ave.\nChicago, IL 60606", @outing.restaurant_address
  end
  
  def test_afterparty_address
    outing = outings(:bobs_beef_shack)
    assert_equal "456 North St.\nChicago, IL 60606", outing.afterparty_address
  end
  
  def test_diff
    outing = @outing.clone
    outing.restaurant_name = 'Changed Diner'
    outing.reservation_time = DateTime.new(2020, 9, 01, 17, 00)
    outing.restaurant_phone = '123-456-7890'
    outing.restaurant_website = 'www.google.com'
    outing.restaurant_description = 'Changed description'
    outing.restaurant_address_line_1 = '543 South St.'
    outing.afterparty_sponsor = diners(:john)
    outing.diners << diners(:john)
    outing.declined_diners << diners(:beth)
    outing.unresponsive_diners << diners(:bob)

    old_in_diners = old_out_diners = old_unresponsive_diners = []
    
    diff_text= Outing.diff(outing, @outing, old_in_diners, old_out_diners,
      old_unresponsive_diners, @outing.afterparty_location)

    expected_diff_text =<<END
Restaurant Name: Changed Diner
Reservation Time: 2020-09-01T17:00:00+00:00
Restaurant Phone: 123-456-7890
Restaurant Website: www.google.com
Restaurant Description: Changed description

Restaurant Address:
543 South St.
Chicago, IL 60606

Afterparty Address:
123 Main St.
Chicago, IL 60606

Diners In:
John Wood

Diners Out:
Beth Wood

Unresponsive Diners:
Bob Smith
END

    assert_equal expected_diff_text.strip, diff_text.strip
  end
  
  def test_find_upcoming_outings
    outings = Outing.find_upcoming_outings
    assert_equal(2, outings.size)
    assert(outings.include?(outings(:bobs_beef_shack)))
    assert(outings.include?(outings(:joes_italian)))
  end
  
  def test_find_past_outings
    outings = Outing.find_past_outings
    assert_equal(1, outings.size)
    assert(outings.include?(outings(:some_past_outing)))
  end
  
  def test_find_suggested_outings
    outings = Outing.find_suggested_outings
    assert_equal(1, outings.size)
    assert(outings.include?(outings(:some_suggested_outing)))
  end
  
end
