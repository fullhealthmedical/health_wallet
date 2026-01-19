class LabResultsImportJob < ApplicationJob
  queue_as :default

  # LOINC codes whitelist
  VALID_LOINC_CODES = {
    '8480-6' => 'Blood Pressure (Systolic)',
    '8462-4' => 'Blood Pressure (Diastolic)',
    '8867-4' => 'Heart Rate',
    '8310-5' => 'Body Temperature',
    '9279-1' => 'Respiratory Rate',
    '2708-6' => 'Oxygen Saturation',
    '29463-7' => 'Body Weight',
    '8302-2' => 'Body Height',
    '2339-0' => 'Blood Glucose',
    '2093-3' => 'Cholesterol'
  }.freeze

  def perform(imported_file_id)
    imported_file = ImportedFile.find(imported_file_id)
    imported_file.processing!

    begin
      # Validate file
      if imported_file.file_content.blank?
        imported_file.failed!("No file content")
        return
      end

      # Validate file is not empty
      if imported_file.file_content.blank?
        imported_file.failed!("File is empty")
        return
      end

      # Parse and import
      parse_and_import(imported_file.file_content, imported_file)

      # Mark as completed
      imported_file.completed!
    rescue StandardError => e
      imported_file.failed!("Unexpected error: #{e.message}")
      raise e
    end
  end

  private

  def parse_and_import(content, imported_file)
    lines = content.split("\n").map(&:strip).reject(&:blank?)
    
    return if lines.empty?

    line_index = 0
    
    while line_index < lines.length
      line = lines[line_index]
      
      # Check if this is a patient header line (contains 4 pipe-delimited fields)
      if line.count('|') == 3
        # Parse patient header
        patient_data = parse_patient_line(line, line_index + 1, imported_file)
        
        if patient_data
          # Process observations that follow
          line_index += 1
          observations_data = []
          
          # Collect all observation lines until next patient header or EOF
          while line_index < lines.length && lines[line_index].count('|') == 2
            obs_data = parse_observation_line(lines[line_index], line_index + 1, imported_file)
            observations_data << obs_data if obs_data
            line_index += 1
          end
          
          Rails.logger.info "Processing patient #{patient_data[:name]} with #{observations_data.length} observations"
          
          # Create or update patient, assessment, and observations
          process_import(patient_data, observations_data, imported_file)
        else
          line_index += 1
        end
      else
        # Malformed line - not a valid header or observation
        imported_file.add_error("Line #{line_index + 1}: Malformed line - '#{line.truncate(100)}'")
        line_index += 1
      end
    end
  end

  def parse_patient_line(line, line_number, imported_file)
    parts = line.split('|').map(&:strip)
    
    if parts.length != 4
      imported_file.add_error("Line #{line_number}: Invalid patient header format")
      return nil
    end

    patient_name, dob_str, sex_at_birth, assessment_reference = parts

    # Validate required fields
    if patient_name.blank? || dob_str.blank? || sex_at_birth.blank? || assessment_reference.blank?
      imported_file.add_error("Line #{line_number}: Missing required patient fields")
      return nil
    end

    # Parse date of birth
    begin
      dob = Date.parse(dob_str)
    rescue ArgumentError
      imported_file.add_error("Line #{line_number}: Invalid date format '#{dob_str}'")
      return nil
    end

    {
      name: patient_name,
      dob: dob,
      sex_at_birth: sex_at_birth,
      assessment_reference: assessment_reference
    }
  end

  def parse_observation_line(line, line_number, imported_file)
    parts = line.split('|').map(&:strip)
    
    if parts.length != 3
      imported_file.add_error("Line #{line_number}: Invalid observation format")
      return nil
    end

    code, result, units = parts

    # Validate LOINC code
    unless VALID_LOINC_CODES.key?(code)
      imported_file.add_error("Line #{line_number}: Invalid LOINC code '#{code}'")
      return nil
    end

    # Parse result as float
    begin
      value = Float(result)
    rescue ArgumentError
      imported_file.add_error("Line #{line_number}: Invalid numeric value '#{result}'")
      return nil
    end

    {
      code: code,
      name: VALID_LOINC_CODES[code],
      value: value,
      units: units
    }
  end

  def process_import(patient_data, observations_data, imported_file)
    # Find or create patient (upsert by name + dob + sex_at_birth)
    patient = Patient.find_or_initialize_by(
      name: patient_data[:name],
      dob: patient_data[:dob],
      sex_at_birth: patient_data[:sex_at_birth]
    )

    is_new_patient = patient.new_record?
    patient.save!

    if is_new_patient
      imported_file.inc(patients_created_count: 1)
    else
      imported_file.inc(patients_updated_count: 1)
    end

    # Find or create assessment (upsert by reference within patient)
    assessment = patient.assessments.find_or_initialize_by(
      reference: patient_data[:assessment_reference]
    )

    is_new_assessment = assessment.new_record?
    
    # Set assessment date to today if new
    assessment.date ||= Date.today.to_s

    # Process observations
    Rails.logger.info "Building #{observations_data.length} observations for assessment #{assessment.reference}"
    
    observations_data.each do |obs_data|
      # Find existing observation by code or create new
      existing_obs = assessment.observations.detect { |o| o.code == obs_data[:code] }
      
      if existing_obs
        # Update existing observation (embedded document)
        existing_obs.value = obs_data[:value]
        existing_obs.units = obs_data[:units]
        existing_obs.name = obs_data[:name]
        imported_file.inc(observations_updated_count: 1)
      else
        # Create new observation
        assessment.observations.build(obs_data)
        imported_file.inc(observations_created_count: 1)
      end
    end

    # Save assessment with all observations
    assessment.save!
    Rails.logger.info "Saved assessment with #{assessment.observations.count} observations"

    if is_new_assessment
      imported_file.inc(assessments_created_count: 1)
    else
      imported_file.inc(assessments_updated_count: 1)
    end

    # Associate the imported_file with the last assessment processed
    # (Note: If multiple assessments per file, only the last one gets associated)
    if imported_file.assessment_id.nil?
      imported_file.update(assessment_id: assessment.id)
    end
  end
end
