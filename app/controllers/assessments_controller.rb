class AssessmentsController < ApplicationController
  def show
    @assessment = Assessment.find(params[:id])
    @patient = @assessment.patient
    @observations = @assessment.observations
  end
end
