require 'app_config'

class OutingMailer < ActionMailer::Base

  #-----------------------------------------------------------------------------
  # Notification of a newly scheduled outing
  #-----------------------------------------------------------------------------
  def new_outing(outing, diners)
    @subject        = 'A new Diners Club outing has been scheduled'
    @body['outing'] = outing
    @body['host']   = get_hostname
    @recipients     = diners.collect {|d| d.email unless d.email.blank? }.compact.join(",")
    @from           = get_from_address
    @sent_on        = Time.now
  end

  #-----------------------------------------------------------------------------
  # Notification of a modified outing
  #-----------------------------------------------------------------------------
  def modified_outing(outing, diff)
    @subject        = 'Your sponsored Diners Club outing has been modified'
    @body['outing'] = outing
    @body['diff']   = diff
    @body['host']   = get_hostname
    @recipients     = outing.diner.email
    @from           = get_from_address
    @sent_on        = Time.now
  end

  #-----------------------------------------------------------------------------
  # Reminder email to the participants of an upcoming outing
  #-----------------------------------------------------------------------------
  def outing_reminder(outing)
    @subject        = 'Reminder of upcoming Diners Club outing'
    @body['outing'] = outing
    @body['host']   = get_hostname
    @recipients     = outing.diners.collect {|d| d.email unless d.email.blank? }.compact.join(", ")
    @from           = get_from_address
    @sent_on        = Time.now
  end

  #-----------------------------------------------------------------------------
  # Reminder email to a diner of the sponsored outings they need to sign up for
  #-----------------------------------------------------------------------------
  def outing_signup_reminder(diner, outings)
    @subject         = 'Reminder to sign up for scheduled Diners Club outings'
    @body['outings'] = outings
    @body['diner']   = diner
    @body['host']    = get_hostname
    @recipients      = diner.email
    @from            = get_from_address
    @sent_on         = Time.now
  end

  ##############################################################################
  private
  ##############################################################################

  #-----------------------------------------------------------------------------
  # Get the host name for this app
  #-----------------------------------------------------------------------------
  def get_hostname
    AppConfig.instance.hostname
  end
  
  #-----------------------------------------------------------------------------
  # Get the "from" email address
  #-----------------------------------------------------------------------------
  def get_from_address
    AppConfig.instance.admin_email
  end
  
end
