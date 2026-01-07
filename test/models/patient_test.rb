require "test_helper"

class PatientTest < ActiveSupport::TestCase
  test "can create a patient" do
    patient = Patient.create!(
      name: "John Doe",
      dob: Date.new(1990, 1, 15),
      sex_at_birth: "Male"
    )

    assert patient.persisted?
    assert_equal "John Doe", patient.name
  end

  test "patient has many assessments" do
    patient = Patient.create!(name: "Jane Doe", dob: Date.new(1985, 5, 20), sex_at_birth: "Female")
    patient.assessments.create!(date: "2025-01-01", reference: "ASM-001")
    patient.assessments.create!(date: "2025-01-02", reference: "ASM-002")

    assert_equal 2, patient.assessments.count
  end
end
