# Imports lab results from a pipe-delimited file
#
# File format:
#   patient_name|dob|sex_at_birth|assessment_reference
#   code|result|units
#   code|result|units
#   ...
#
# Example:
#   John Doe|1990-01-15|Male|LAB-2025-001
#   8867-4|72.0|bpm
#   8480-6|120.0|mmHg
#
class LabResultsImporter
  DELIMITER = "|"

  def initialize(file_path)
    @file_path = file_path
    @errors = []
  end

  attr_reader :errors

  def import
    lines = File.readlines(@file_path).map(&:strip).reject(&:empty?)
    return if lines.empty?

    header = parse_header(lines.first)
    observations_data = lines[1..].map { |line| parse_observation(line) }

    patient = find_or_create_patient(header)
    assessment = create_assessment(patient, header)
    create_observations(assessment, observations_data)

    assessment
  end

  private

  def parse_header(line)
    parts = line.split(DELIMITER)
    {
      patient_name: parts[0],
      dob: parts[1],
      sex_at_birth: parts[2],
      reference: parts[3]
    }
  end

  def parse_observation(line)
    parts = line.split(DELIMITER)
    {
      code: parts[0],
      value: parts[1].to_f,
      units: parts[2]
    }
  end

  def find_or_create_patient(header)
    Patient.find_or_create_by(
      name: header[:patient_name],
      dob: Date.parse(header[:dob]),
      sex_at_birth: header[:sex_at_birth]
    )
  end

  def create_assessment(patient, header)
    patient.assessments.create!(
      date: Date.today.to_s,
      reference: header[:reference]
    )
  end

  def create_observations(assessment, observations_data)
    observations_data.each do |obs_data|
      assessment.observations.create!(
        code: obs_data[:code],
        value: obs_data[:value],
        units: obs_data[:units],
        name: lookup_observation_name(obs_data[:code])
      )
    end
  end

  def lookup_observation_name(code)
    # TODO: Implement proper LOINC code lookup
    OBSERVATION_CODES[code] || "Unknown (#{code})"
  end

  OBSERVATION_CODES = {
    "8480-6" => "Blood Pressure (Systolic)",
    "8462-4" => "Blood Pressure (Diastolic)",
    "8867-4" => "Heart Rate",
    "8310-5" => "Body Temperature",
    "9279-1" => "Respiratory Rate",
    "2708-6" => "Oxygen Saturation",
    "29463-7" => "Body Weight",
    "8302-2" => "Body Height",
    "2339-0" => "Blood Glucose",
    "2093-3" => "Cholesterol"
  }.freeze
end
