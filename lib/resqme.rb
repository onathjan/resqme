require 'pony'
require 'time'
require 'yaml'

class ResqMe 
  def initialize
    begin
      @emergency_contacts = YAML.load_file("config/config.yaml")["emergency_contacts"]
      @expected_return_time = YAML.load_file("config/expected_return_time.yaml")["expected_return_time"]
      @flag = YAML.load_file("config/flag.yaml")
    rescue => error
      puts "Error loading files: #{error.message}"
      exit
    end
  end

  def expected_return_time_has_elapsed?
    Time.now > Time.parse(@expected_return_time)
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
      Pony.mail(
        to: details["email_address"],
        from: config_file["user_email_address"],
        subject: "Rescue plan for #{config_file["user"]["full_name"]}",
        body: File.read("./rescue_plan.md"),
        via: :smtp,
        :via_options => {
          :address        => ENV['RESQME_SMTP_ADDRESS'],
          :port           => ENV['RESQME_SMTP_PORT'],
          :user_name      => ENV['RESQME_SMTP_USERNAME'],
          :password       => ENV['RESQME_SMTP_PASSWORD'],
          :authentication => :plain,
          :domain         => ENV['RESQME_SMTP_DOMAIN']
    })
    end
  end
end
