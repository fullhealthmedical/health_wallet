require "test_helper"

class ObservationTest < ActiveSupport::TestCase
  test "can create an observation" do
    patient = Patient.create!(name: "Test Patient", dob: Date.today, sex_at_birth: "Male")
    assessment = patient.assessments.create!(date: "2025-01-07", reference: "ASM-TEST-001")

    observation = assessment.observations.create!(
      name: "Heart Rate",
      code: "8867-4",
      value: 72.0,
      units: "bpm"
    )

    assert_equal "Heart Rate", observation.name
    assert_equal 72.0, observation.value
  end
end
