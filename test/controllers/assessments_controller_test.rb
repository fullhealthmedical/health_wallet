require "test_helper"

class AssessmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(
      name: "Test Patient",
      dob: Date.new(1990, 5, 15),
      sex_at_birth: "Male"
    )
    @assessment = @patient.assessments.create!(
      date: "2025-01-07",
      reference: "ASM-TEST-001"
    )
  end

  test "should show assessment" do
    get assessment_url(@assessment)
    assert_response :success
  end

  test "shows assessment reference" do
    get assessment_url(@assessment)
    assert_match @assessment.reference, response.body
  end
end
