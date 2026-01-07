class AssessmentsController < ApplicationController
  def show
    @assessment = Assessment.find(params[:id])
    @patient = @assessment.patient
    @observations = @assessment.observations
  end

  def edit
    @assessment = Assessment.find(params[:id])
    @patient = @assessment.patient
  end

  def update
    @assessment = Assessment.find(params[:id])

    if @assessment.update(assessment_params)
      redirect_to assessment_path(@assessment), notice: "Assessment updated successfully."
    else
      @patient = @assessment.patient
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def assessment_params
    params.require(:assessment).permit(
      observations_attributes: [ :id, :value, :units ]
    )
  end
end
