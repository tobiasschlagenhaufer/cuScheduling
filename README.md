# cuScheduling

The Carleton Student Timetable Generator - Build your schedule at the click of a button!

  Get all your labs and tutorials           |  Prioritize days off
:-------------------------:|:-------------------------:
 ![alt-1](cus_1.png "schedule-1") | ![alt-2](cus_2.png "schedule-2")

visit www.cuscheduling.net 

# Courses API
www.cuscheduling.net/courses.json

If you are building an application that requires Carleton's Courses, feel free to use this REST API for free!

Returns a json object with Course name, section, term, status (availability), location, start and end time

Query Parameters:
* name - this is the exact name of the course, ie COMP1405
* subject - the 4 letter course code, ie "COMP"  Note: you may be more specific, ie COMP2 etc.
* status - the availiability of the course, from waitlisted to open to closed
* term - Winter, Summer, Fall
* location - Building, room or room number you're looking for

Note: Restricted to 100 courses per Query


Documentation
* Ruby 2.3.3
* Rails 5.1.7
* Nokogiri 1.10.5
* Mechanize 2.7.6
* Capistrano 3.11


Developed by Tobias Schlagenhaufer

If you have any questions or would like to report a bug, email me at tobiasschlagenhaufer@cmail.carleton.ca
