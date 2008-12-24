require File.dirname(__FILE__) + '/../test_helper'

class OutingMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  fixtures :diners
  fixtures :outings

  def test_new_outing
    outing = Outing.find_by_id(1)
    response = OutingMailer.create_new_outing(outing, Diner.find(:all))
    assert_equal('john_wood@yahoo.com', response.to[0])
    assert_equal('beth_wood@yahoo.com', response.to[1])
    assert_equal('A new Diners Club outing has been scheduled', response.subject)
    assert_match(/Sponsor: John Wood/, response.body)
    assert_match(/Date\/Time: May 01, 2020 12:00PM /, response.body)
    assert_match(/Restaurant Name: Bob's Beef Shack /, response.body)
    assert_match(/Restaurant Location: Chicago, IL/, response.body)
    assert_match(/Restaurant Description: Beef, and lots of it/, response.body)
  end

  def test_modified_outing
    outing = Outing.find_by_id(1)
    diff_text =<<END
Restaurant Name: Changed Diner
Restaurant Website: www.google.com
Restaurant Description: Changed description

Restaurant Address:
543 South St.
Chicago, IL 60606

Diners In:
John Wood
END
    
    response = OutingMailer.create_modified_outing(outing, diff_text)
    assert_equal('john_wood@yahoo.com', response.to[0])
    assert_equal('Your sponsored Diners Club outing has been modified', response.subject)
    assert_match(/The Diners Club outing you are sponsoring to Bob's Beef Shack has been modified./, response.body)
    assert_match(/Restaurant Name: Changed Diner/, response.body)
    assert_match(/Restaurant Website: www.google.com/, response.body)
    assert_match(/Restaurant Description: Changed description/, response.body)
    assert_match(/Restaurant Address:/, response.body)
    assert_match(/543 South St./, response.body)
    assert_match(/Chicago, IL 60606/, response.body)
    assert_match(/Diners In:/, response.body)
    assert_match(/John Wood/, response.body)
  end

  def test_outing_reminder
    outing = Outing.find_by_id(1)
    outing.diners << diners(:john)
    outing.diners << diners(:beth)
    outing.diners << diners(:bob)

    response = OutingMailer.create_outing_reminder(outing)
    assert_equal('john_wood@yahoo.com', response.to[0])
    assert_equal('beth_wood@yahoo.com', response.to[1])
    assert_equal('bob_smith@yahoo.com', response.to[2])
    assert_equal('Reminder of upcoming Diners Club outing', response.subject)
    assert_match(/upcoming Diners Club outing to Bob's Beef Shack on May 01, 2020 12:00PM/, response.body)
    assert_match(/Bob's Beef Shack is located at/, response.body)
    assert_match(/333 South Ave./, response.body)
    assert_match(/Unit 100/, response.body)
    assert_match(/Chicago, IL 60606/, response.body)
    assert_match(/The afterparty will be at O'Mallys in Chicago, IL/, response.body)
  end

  def test_outing_signup_reminder
    outings = []
    outings << Outing.find_by_id(1)
    outings << Outing.find_by_id(2)

    response = OutingMailer.create_outing_signup_reminder(Diner.find_by_id(1), outings)
    assert_equal('john_wood@yahoo.com', response.to[0])
    assert_match(/Hi John/, response.body)
    assert_match(/You have not responded to the following scheduled Diners Club outings/, response.body)
    assert_match(/Bob's Beef Shack on May 01, 2020 12:00PM/, response.body)
    assert_match(/Joe's Italian on June 01, 2020 12:00PM/, response.body)
  end

end
