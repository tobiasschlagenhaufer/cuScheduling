class UpdateCoursesJob < ApplicationJob
	require "./app/scraper.rb"
	require "rufus-scheduler"
	
	queue_as :default

  def perform()
	#perform a transaction which only modifies the record after completion
	ActiveRecord::Base.transaction do
		scrape
		$updated = Time.now
	end

  end
end
