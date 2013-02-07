require 'csv'
require 'yaml'
require_relative 'csvfile'

class EventReporter
  attr_accessor :queue

  def initialize
    puts "Welcome to the Event Manager!"
    @queue = []
    @yaml = YAML.load(File.open("help.yml"))

    loop do
      process_input(ask_prompt)
      end
  end

  def ask_prompt
    printf "enter command:"
    gets.chomp.split(" ")
  end

  def process_input(input)
    rest_of_input = input[1..-1]
    case input[0]
    when 'load' then process_csv(rest_of_input)
    when 'help' then help_user(rest_of_input)
    when 'queue' then queue(rest_of_input)
    when 'find' then find(rest_of_input)
    when 'quit' then quit_loop
    else
      puts "I don't understand your input, please try again."
    end
  end

def process_csv(rest_of_input)
  @csv = CsvFile.new(rest_of_input)
  @csv.load
end

  def quit_loop
    puts "Goodbye!"
    exit
  end

################# QUEUE ##################
  def queue(queue_command)
   puts "#{queue_command[0]}"
     case queue_command[0]
     when 'count' then puts "#{@queue.count} people in the queue."
     when 'clear' then queue_clear
     when 'print' then queue_print(queue_command)
     when 'save' then queue_save_to_file(queue_command)
     else
      puts "I don't know..."
    end
  end

  def queue_clear
    @queue = []
    puts "Queue cleared."
  end

  def queue_print(queue_command)
    case queue_command[1]
    when nil then queue_print_records
    when "by" then queue_print_by_attribute(queue_command)
    else
      puts "I don't recognize this command."
    end
  end

  def queue_print_records
    puts "LAST NAME\tFIRST NAME\tEMAIL\tZIPCODE\tCITY\tSTATE\tADDRESS\tPHONE"

    @queue.each do |attendee|
      row = []
      attendee.each  do |attribute| 
        row << attribute
      end
      puts row.join("\t")
    end
  end

  def queue_print_by_attribute(queue_command)
    attribute = queue_command[2].downcase
    puts "attribute is:  #{attribute}"

    @queue.sort! do |attendee1, attendee2|
     attendee1.send(attribute).downcase <=> attendee2.send(attribute).downcase
    end
    queue_print_records
  end

  def queue_save_to_file(queue_command)
    filename = queue_command[-1]

    CSV.open(filename, "w") do |csv|
    csv << ["LAST NAME", "FIRST NAME", "EMAIL", 
            "ZIPCODE", "CITY", "STATE", 
            "ADDRESS", "PHONE"
          ]
      
      @queue.each do |attendee|
        csv <<[ attendee.last_name, attendee.first_name,
                attendee.email, attendee.zipcode,
                attendee.city, attendee.state,
                attendee.address, attendee.phone
              ]
      end
    end
    puts "File #{filename} has been created."
  end

################  FIND  ################
  def find(rest_of_input)
    attribute = rest_of_input[0].downcase
    criteria = rest_of_input[1..-1].join(" ").downcase

    puts " searched on attribute: #{attribute}, criteria: #{criteria}"

    @queue = @csv.people.select do |attendee|
      attendee.send(attribute).to_s.downcase == criteria
    end

    puts "Found #{@queue.count} results. Type 'queue print' for results."
  end

############### HELP #####################
  def help_user(rest_of_input)
    
    case rest_of_input.join(" ")
    when "" then display_help_options
    when "queue" then display_help_queue_options
    when "queue count" then puts @yaml["help"]["queue"]["count"]
    when "queue clear" then puts @yaml["help"]["queue"]["clear"]
    when "queue save" then puts @yaml["help"]["queue"]["save"]
    when "queue print" then puts @yaml["help"]["queue"]["print"]["print"]
    when "queue print by" then puts @yaml["help"]["queue"]["print"]["by"]
    when "find" then puts @yaml["help"]["find"]
    when "load" then puts @yaml["help"]["load"]
    when "quit" then puts @yaml["help"]["quit"]
    else
    puts "I don't recognize this command."
    end
  end

  def display_help_options
    puts "To open a specific help option, please type 'help .....'"
    puts @yaml["help"]
  end

  def display_help_queue_options
    puts "Your queue options are as follows:"
    @yaml["help"]["queue"]. each do |key, value|
      puts "#{key}: #{value}"
    end
  end
end
