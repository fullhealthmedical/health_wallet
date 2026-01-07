require "test_helper"

class AssessmentTest < ActiveSupport::TestCase
  test "can create an assessment" do
    patient = Patient.create!(name: "Test Patient", dob: Date.today, sex_at_birth: "Male")
    assessment = patient.assessments.create!(date: "2025-01-07", reference: "ASM-TEST-001")

    assert assessment.persisted?
    assert_equal "ASM-TEST-001", assessment.reference
  end

  test "assessment belongs to patient" do
    patient = Patient.create!(name: "Test Patient", dob: Date.today, sex_at_birth: "Female")
    assessment = patient.assessments.create!(date: "2025-01-07", reference: "ASM-TEST-002")

    assert_equal patient, assessment.patient
  end
end
