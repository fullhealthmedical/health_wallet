class PatientsController < ApplicationController
  def index
    page = params[:page].to_i
    page = 1 if page < 1

    @patients = Patient.all.skip((page - 1) * 10).limit(10)
    @total_count = Patient.count
    @current_page = page
    @total_pages = (@total_count / 10.0).ceil
  end

  def show
    @patient = Patient.find(params[:id])
    @assessments = @patient.assessments
  end
end
