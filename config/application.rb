require_relative 'boot'

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CuScheduling
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
	config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
	# -- all .rb files in that directory are automatically loaded.
	
	config.after_initialize do
		UpdateCoursesJob.perform_later

		scheduler = Rufus::Scheduler.new 
		scheduler.every "3h" do #also scrape every day
		begin
			UpdateCoursesJob.perform_later
		rescue
			puts "Error scraping data"
		end
	end
	end

  end
end
