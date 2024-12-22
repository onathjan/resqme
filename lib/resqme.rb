require 'time'
require 'yaml'

class ResqMe 
  def initialize
    begin
      @emergency_contacts = YAML.load_file("config/emergency_contacts.yaml")
      @expected_return_time = YAML.load_file("config/expected_return_time.yaml")
      @flag = YAML.load_file("config/flag.yaml")
    rescue => error
      puts "Error loading files: #{error.message}"
      exit
    end
  end

  def expected_return_time_has_elapsed?
    Time.now > Time.parse(@expected_return_time["expected_return_time"])
  end

  def countdown_is_active?
    @flag["countdown_is_active"] == true
  end

  def countdown_is_inactive?
    @flag["countdown_is_active"] == false
  end

  def begin_countdown
    puts "Countdown is now active."
    loop do
      if expected_return_time_has_elapsed? && countdown_is_active?
        notify_emergency_contacts
        break
      elsif expected_return_time_has_elapsed? && countdown_is_inactive?
        break
      else
        sleep 20
      end
    end
  end

  private

  def notify_emergency_contacts
    @emergency_contacts.each do |name, details|
      puts "Name: #{name}"
      puts "Phone: #{details['phone_number']}"
      puts "Email: #{details['email_address']}"
    end
  end
end
