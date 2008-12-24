require File.dirname(__FILE__) + '/../test_helper'

class DinerTest < Test::Unit::TestCase
  fixtures :diners
  
  def setup
    @diner = Diner.find(1)
  end

  def test_display_name
    assert_equal 'John Wood', @diner.display_name
  end
  
  def test_comma_seperated_display_name
    assert_equal 'Wood, John', @diner.comma_seperated_display_name
  end
  
  def test_find_by_first_and_last_name
    diner = Diner.find_by_first_and_last_name('Wood, John')
    assert_equal diners(:john), diner
  end
  
  def test_find_by_address
    diner = Diner.find_by_address('123 Main St.', 'Apt 104', 'Chicago', 'IL', '60606')
    assert_equal diners(:john), diner
  end
  
  def test_find_all_in_order_with_address
    diners = Diner.find_all_in_order_with_address
    assert_equal 2, diners.size
    assert_equal diners(:beth), diners[0]
    assert_equal diners(:john), diners[1]
  end
  
  def test_find_all_in_order_with_no_conditions
    diners = Diner.find_all_in_order
    assert_equal 3, diners.size
    assert_equal diners(:bob), diners[0]
    assert_equal diners(:beth), diners[1]
    assert_equal diners(:john), diners[2]
  end

  def test_find_all_in_order_with_an_address
    diners = Diner.find_all_in_order("address_line_1 != ''")
    assert_equal 2, diners.size
    assert_equal diners(:beth), diners[0]
    assert_equal diners(:john), diners[1]
  end

end
