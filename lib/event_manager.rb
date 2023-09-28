require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
    begin
      civic_info.representative_info_by_address(
        address: zip,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']
      ).officials
    rescue
      'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

def save_thank_you_letter(id,form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"
  
    File.open(filename, 'w') do |file|
      file.puts form_letter
    end
end

def clean_phone_number(phone_number)
    if phone_number.count("0123456789") < 10
        ""
    elsif phone_number.count("0123456789") == 10
        phone_number
    elsif phone_number.count("0123456789") == 11
        if phone_number[0] == "1"
            phone_number[1..10]
        else
            ""
        end
    elsif phone_number.count("0123456789") > 11
        ""
    end
end

def time_targeting(contents)
  numbers = ("0".."9").to_a
  times = []
  contents.each do |row|
      registration_date_and_time = row[:regdate].split(" ")
      registration_time = registration_date_and_time[1]
      
      times << registration_time[0, 2] 
  end
    times.tally.sort {|a1,a2| a2[1]<=>a1[1]}
end
def day_of_the_week_targeting(contents)
  array_of_week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday"]
  array_of_days = []
  contents.each do |row|
    registration_date_and_time = row[:regdate].split(" ")
    registration_date = registration_date_and_time[0]
    Date.strptime(registration_date.gsub("/", "-"), '%m-%d-%Y').wday.class
  
    array_of_days << array_of_week[Date.strptime(registration_date.gsub("/", "-"), '%m-%d-%Y').wday]

  end

  array_of_days.tally
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

# contents.each do |row|
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   legislators = legislators_by_zipcode(zipcode)

#   form_letter = erb_template.result(binding)

#   save_thank_you_letter(row[:id], form_letter)

# end


p day_of_the_week_targeting(contents)