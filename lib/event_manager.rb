require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

contents = CSV.open('event_attendees.csv', headers:true,
header_converters: :symbol)
data = contents.read
size =  data.length
contents.rewind

puts 'EventManager initialized.'

template_letter = File.read('form_letter.html')

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  file_name = "output/thanks_#{id}.html"
  File.open(file_name, 'w') do |file|
    file.puts form_letter
  end
end

def valid_phone_number(phone)
    phone = phone.to_s.scan(/\d+/).join("")
    if phone.length==10
        return phone
    elsif phone.length==11 && phone[0]=="1"
        phone = phone.slice(1,11)
        return phone
    else
        return "Invalid"
    end
end

def clean_zipcode(zipcode)
    # if zipcode.length>5
    #     zipcode = zipcode.slice(0,5)
    # end
    # until zipcode.length==5
    #     zipcode = '0'+zipcode
    # end
    zipcode.to_s.rjust(5,'0')[0..4] # rjust adjusts the length by adding '0' and the front(ljust for the end)
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

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter


# contents.each do |row|
#     id = row[0]
#     name = row[:first_name]
#     zipcode = clean_zipcode(row[:zipcode])
#     legislators = legislators_by_zipcode(zipcode)

#     form_letter = erb_template.result(binding)

#     save_thank_you_letter(id, form_letter)

# end

# contents.each do |row|
#     puts valid_phone_number(row[:homephone])
# end
array = ['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
hour = Hash.new(0)
day = Hash.new(0)
contents.each do |row|
#   time = row[:regdate].to_s.split(" ")[1].split(":")[0]
    date = row[:regdate]
    time = DateTime.strptime(date, "%m/%d/%y %H:%M")
    hour[time.hour] += 1
    day[time.wday] +=1
    # puts time.hour
end
hour.each do |key, value|
    puts "#{key} #{value}"
end

day.each do|key, value|
  puts "#{array[key]} #{value}"
end
