class UpdateCoursesJob < ApplicationJob
	require "./app/scraper.rb"
	
	queue_as :default

  def perform()
	scrape
    puts "sucessfully ran"
  end
end
