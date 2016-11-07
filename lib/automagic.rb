require 'csv'

standard_properties = ['id', 'email', 'name', 'first_name', 'last_name', 'user_name', 'phone', 'created_at']

csv = CSV.read('dummy_data.csv')

properties = {}
hash = []


values = csv[1]
x = 0 
standard_properties.each  do |property| 
properties[property]  = values[x]
x+=1
hash << properties
end

end
