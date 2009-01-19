require 'net/smtp'
require 'app_config'

namespace "dinersclub" do  

  desc "Send the weekly diners club emails"
  task :send_weekly_emails => [:send_reminder_email, :send_signup_reminder_email]

  desc 'Send a reminder email to diners about an upcoming outing that they have elected to attend'
  task :send_reminder_email => :environment do 
    today = Time.now
    one_week_from_today = today.advance(:days => 7)
    outing = Outing.find(:first,
      :conditions => ['reservation_time > ? and reservation_time <= ? and diner_id is not null', 
        today, one_week_from_today])
    OutingMailer.deliver_outing_reminder(outing) unless outing.nil?
  end
  
  desc 'Send an email to a diner listing the outings that they have not responded to'
  task :send_signup_reminder_email => :environment do 
    diners = Diner.find(:all, :conditions => 'email != ""')
    outings = Outing.find(:all, 
      :conditions => ['reservation_time > ? and diner_id is not null', Time.now],
      :order => 'reservation_time ASC')
  
    for diner in diners
      missing_outings = []
      
      for outing in outings
        unless outing.unresponsive_diners.blank?
          missing_outings << outing if outing.unresponsive_diners.include?(diner)
        end
      end
      
      OutingMailer.deliver_outing_signup_reminder(diner, missing_outings) unless missing_outings.empty?
    end
  end

  desc 'Email a general message to the users of the tool'
  task :email_users => :environment do 
    message_file = "#{RAILS_ROOT}/config/dinersclub_message.txt"
    from_address = AppConfig.instance.admin_email
    subject = 'Diners Club'

    diners = Diner.find(:all, :conditions => 'email != ""')
    body = File.read(message_file)

    to_address = []
    diners.collect { |d| d.email unless d.email.blank? }.each { |e| to_address << e }

    message =  "From: #{from_address} <#{from_address}>\n"
    message << "To: #{to_address.join(', ')}\n"
    message << "Subject: #{subject}\n\n"
    message << body

    smtp_settings = AppConfig.instance.smtp_settings
    Net::SMTP.start(smtp_settings[:address],
                    smtp_settings[:port],
                    smtp_settings[:domain],
                    smtp_settings[:user_name],
                    smtp_settings[:password],
                    :login) do |smtp|
      smtp.send_message message, from_address, to_address
    end
  end

end
