# Test import script
# Run with: rails runner test_import.rb

# Clean up existing test data
Patient.where(name: /Test Patient/).destroy_all

file = File.open("sample_import.txt")
patient = Patient.create!(name: "Test Patient", dob: Date.new(1980, 1, 1), sex_at_birth: "Male")
assessment = Assessment.create!(patient: patient, date: Date.today.to_s, reference: "TEMP-#{SecureRandom.hex(8)}")
imported_file = ImportedFile.create!(assessment: assessment, filename: "sample_import.txt", file_content: file.read)
file.close

puts "Created imported_file: #{imported_file.id}"
puts "File content length: #{imported_file.file_content.length}"
puts "First 200 chars: #{imported_file.file_content[0..200]}"
puts "\n--- Running import job ---\n"

LabResultsImportJob.perform_now(imported_file.id.to_s)

imported_file.reload
puts "\n--- Import Results ---"
puts "Status: #{imported_file.status}"
puts "Patients created: #{imported_file.patients_created_count}"
puts "Patients updated: #{imported_file.patients_updated_count}"
puts "Assessments created: #{imported_file.assessments_created_count}"
puts "Assessments updated: #{imported_file.assessments_updated_count}"
puts "Observations created: #{imported_file.observations_created_count}"
puts "Observations updated: #{imported_file.observations_updated_count}"
puts "Error count: #{imported_file.error_count}"
puts "Errors: #{imported_file.error_messages.inspect}"

# Check actual patients and assessments created
puts "\n--- Database Check ---"
Patient.where(name: /John|Jane|Robert/).each do |p|
  puts "Patient: #{p.name} (#{p.dob})"
  p.assessments.each do |a|
    puts "  Assessment: #{a.reference} - #{a.observations.count} observations"
    a.observations.each do |o|
      puts "    - #{o.name} (#{o.code}): #{o.value} #{o.units}"
    end
  end
end
