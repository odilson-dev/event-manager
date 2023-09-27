require 'csv'
puts 'EventManager initialized.'

def clean_zipcode(zipcode)

    if zipcode.nil?
        "00000"
    elsif zipcode.size > 5
        zipcode[0..4] 
    elsif zipcode.size < 5
        zipcode = zipcode.rjust(5, "0") 
    else
        zipcode
    end
end

contents = CSV.open("event_attendees.csv", 
                    headers: true, 
                    header_converters: :symbol)

contents.each do |row|
    name = row[:first_name]
    zipcode = row[:zipcode]
    
    zipcode = clean_zipcode(zipcode)
    
    puts "#{name} #{zipcode}"
end

