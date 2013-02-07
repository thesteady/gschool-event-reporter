 require 'csv'

Attendee = Struct.new(:last_name, 
                      :first_name, 
                      :email, 
                      :zipcode, 
                      :city, 
                      :state, 
                      :address, 
                      :phone)

  class CsvFile
    attr_accessor :people

    def initialize(filename)
      @filename = filename
      @people = []
    end

    def people
      @people
    end

   def load
      checked_filename = check_filename

      if File.exists?(checked_filename)
        contents = CSV.open(checked_filename, :headers=>true)
        parse(contents)
        puts "file loaded."
      else
        puts "Couldn't find file!"
      end
    end

    def check_filename
      default_filename = 'event_attendees.csv'
      if @filename[0] == nil
        filename = default_filename
      else
        filename = @filename[0]
      end
    end

    def parse(contents)
      contents.each do |line|
        last_name = line["last_Name"]
        first_name = line["first_Name"]
        email = line["Email_Address"]
        phone = clean_phone_number(line["HomePhone"])
        address = line["Street"]
        zipcode = clean_zipcode(line["Zipcode"])
        city = line["City"]
        state = line["State"]

        @people << Attendee.new(last_name, first_name, email, zipcode, city, 
                                state, address, phone)
      end
      @people
    end

    def clean_zipcode(zipcode)
      if zipcode.nil?
        "00000"
      else
        "0"*(5 - zipcode.length) + zipcode
      end
    end

    def clean_phone_number(phone_number)
      if phone_number.nil?
        "000-000-0000"
      else
        stripped_number = phone_number.gsub(/[^0-9]/, "")
      end

      if stripped_number.length < 10 || stripped_number.length > 11
        "000-000-0000"
      elsif stripped_number.length == 11 && stripped_number[0] != "1"
        "000-000-0000"
      else
        format_clean_phone_number(stripped_number)
      end 
    end

    def format_clean_phone_number(stripped_number)
      area_code = stripped_number[-10..-8]
      prefix = stripped_number[-7..-5]
      base = stripped_number[-4..-1]
      "#{area_code}-#{prefix}-#{base}"
    end
  end

#rest_of_input = ["event_attendees.csv"]
#csv = CsvFile.new(rest_of_input)
#csv.load