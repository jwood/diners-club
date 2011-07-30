require 'app_config'

class OutingMailer < ActionMailer::Base

  def new_outing(outing, diners)
    @subject        = 'A new Diners Club outing has been scheduled'
    @body['outing'] = outing
    @body['host']   = get_hostname
    @recipients     = diners.collect {|d| d.email unless d.email.blank? }.compact.join(",")
    @from           = get_from_address
    @sent_on        = Time.now
  end

  def modified_outing(outing, diff)
    @subject        = 'Your sponsored Diners Club outing has been modified'
    @body['outing'] = outing
    @body['diff']   = diff
    @body['host']   = get_hostname
    @recipients     = outing.diner.email
    @from           = get_from_address
    @sent_on        = Time.now
  end

  def outing_reminder(outing)
    @subject        = 'Reminder of upcoming Diners Club outing'
    @body['outing'] = outing
    @body['host']   = get_hostname
    @recipients     = outing.diners.collect {|d| d.email unless d.email.blank? }.compact.join(", ")
    @from           = get_from_address
    @sent_on        = Time.now
  end

  def outing_signup_reminder(diner, outings)
    @subject         = 'Reminder to sign up for scheduled Diners Club outings'
    @body['outings'] = outings
    @body['diner']   = diner
    @body['host']    = get_hostname
    @recipients      = diner.email
    @from            = get_from_address
    @sent_on         = Time.now
  end

  private

  def get_hostname
    AppConfig.instance.hostname
  end
  
  def get_from_address
    AppConfig.instance.admin_email
  end
  
end
