require "test_helper"

class PatientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @patient = Patient.create!(
      name: "Test Patient",
      dob: Date.new(1990, 5, 15),
      sex_at_birth: "Female"
    )
  end

  test "should get index" do
    get patients_url
    assert_response :success
  end

  test "should show patient" do
    get patient_url(@patient)
    assert_response :success
  end

  test "index displays patient name" do
    get patients_url
    assert_match @patient.name, response.body
  end
end
