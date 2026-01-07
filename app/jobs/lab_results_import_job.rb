class LabResultsImportJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    importer = LabResultsImporter.new(file_path)
    importer.import
  end
end
