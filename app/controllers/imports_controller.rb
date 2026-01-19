class ImportsController < ApplicationController
  def new
    @imported_file = ImportedFile.new
  end

  def create
    # Create a temporary assessment to attach the imported file
    # The actual assessment will be found/created during import
    assessment = Assessment.new(
      date: Date.today.to_s,
      reference: "TEMP-#{SecureRandom.hex(8)}"
    )
    
    @imported_file = ImportedFile.new(assessment: assessment)
    
    # Handle file upload
    if params[:imported_file][:file].present?
      file = params[:imported_file][:file]
      @imported_file.filename = file.original_filename
      @imported_file.file_content = file.read
    end

    if @imported_file.valid? && assessment.save
      @imported_file.save!
      # Enqueue background job
      LabResultsImportJob.perform_later(@imported_file.id.to_s)
      
      redirect_to import_path(@imported_file), notice: "File uploaded successfully. Import is processing in the background."
    else
      flash.now[:alert] = "Failed to upload file: #{@imported_file.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @imported_file = ImportedFile.find(params[:id])
  end

  def index
    @imported_files = ImportedFile.all.order(created_at: :desc).limit(50)
  end
end
