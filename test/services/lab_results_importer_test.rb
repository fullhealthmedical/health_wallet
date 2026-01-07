require "test_helper"

class LabResultsImporterTest < ActiveSupport::TestCase
  test "imports a valid lab results file" do
    file_path = create_temp_file(<<~FILE)
      John Doe|1990-01-15|Male|LAB-2025-001
      8867-4|72.0|bpm
      8480-6|120.0|mmHg
    FILE

    importer = LabResultsImporter.new(file_path)
    assessment = importer.import

    assert assessment.persisted?
    assert_equal "LAB-2025-001", assessment.reference
    assert_equal 2, assessment.observations.count
  end

  test "creates patient if not exists" do
    file_path = create_temp_file(<<~FILE)
      New Patient|1985-05-20|Female|LAB-2025-002
      8867-4|80.0|bpm
    FILE

    assert_difference "Patient.count", 1 do
      LabResultsImporter.new(file_path).import
    end
  end

  private

  def create_temp_file(content)
    file = Tempfile.new([ "lab_results", ".txt" ])
    file.write(content)
    file.rewind
    file.path
  end
end
