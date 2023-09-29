require 'csv'
require 'google/apis/civicinfo_v2'

contents = CSV.open('event_attendees.csv', headers:true,
header_converters: :symbol)

puts 'EventManager initialized.'


def clean_zipcode(zipcode)
    # if zipcode.length>5
    #     zipcode = zipcode.slice(0,5)
    # end
    # until zipcode.length==5
    #     zipcode = '0'+zipcode
    # end
    zipcode.rjust(5,'0')[0..4] # rjust adjusts the length by adding '0' and the front(ljust for the end)
end

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
            address: zip,
            levels:'country',
            roles:['legislatorUpperBody', 'LegislatorLowerBody']
        )
        legislators = legislators.officials
        legislators_names = legislators.map(&:name)
        legislators_names.join(",")
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

contents.each do |row|
    name = row[:first_name]
    zipcode = row[:zipcode].to_s
    zipcode = clean_zipcode(zipcode)
    legislators_string = legislators_by_zipcode(zipcode)

    puts "#{name} #{zipcode} #{legislators_string}"
end
