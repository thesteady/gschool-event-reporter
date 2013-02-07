require 'csv'

class Attendee

def initialize(filename)
  @filename = filename.empty? ? "event_attendees.csv" : filename
end

def get_attendees
  all_data = []
  contents = CSV.open(@filename, headers: true)
  contents.each do |line|
    person_hash = {}
    person_hash[:first_name] = line["first_Name"]
    person_hash[:phone_number] = "phone number" #call clean phonenumber method to pass in
    #fill in data here.
    all_data << person_hash
  end
end
end