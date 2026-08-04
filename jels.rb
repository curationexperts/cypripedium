require 'net/http'
require 'uri'
require 'csv'

# List of JEL codes (identifiers) to query against the Solr index
jel_codes = ['D64', 'E12', 'E62', 'G10', 'G12', 'G51', 'J14', 'P16', 'P20', 'P24', 'P27', 'P29', 'P48', 'Q18', 'R14']

output_file = 'jel_changes.csv'
base_solr_url = 'http://localhost:8993/solr/cypripedium/select'

puts "Starting Solr data extraction..."

File.open(output_file, 'w') do |file|
  jel_codes.each do |jel|
    puts "Querying for JEL code: #{jel}"

    query_string = "?fl=id%2C%20jel%3A%22#{jel}%22%2C%20date_modified_dtsi%2C%20date_modified_ssi%2C%20link%3Aconcat(%22https%3A%2F%2Fresearchdatabasestaging.minneapolisfed.org%2Fconcern%2Fpublications%2F%22%2C%20id)%2C%20title_tesim%2C%20alpha_creator_tesim&indent=true&q.op=OR&q=subject_tesim%3A#{jel}&rows=100&wt=csv"
    
    full_url = URI("#{base_solr_url}#{query_string}")
    
    response = Net::HTTP.get_response(full_url)
    
    # Write the raw response body (including the header)
    file.puts(response.body)
    
    # Adding a blank line to visually separate blocks as requested in the example
    file.puts("") 
    
    sleep(0.1) 
  end
end

puts "Finished extracting data. Results saved to #{output_file}"
