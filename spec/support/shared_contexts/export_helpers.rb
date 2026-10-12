# frozen_string_literal: true

# Helpers for inspecting the zip archive attached to an Export
RSpec.shared_context 'export helpers' do
  def zip_filenames(export)
    zip_entries = Zip::File.open_buffer(export.export_file.download).entries
    zip_entries.select(&:file?).map(&:name)
  end

  def zip_entry(export, name)
    Zip::File.open_buffer(export.export_file.download).read(name)
  end

  def parsed_csv(export)
    csv_name = "#{export.export_file.filename.base}/#{ExportPackager::METADATA_FILENAME}"
    CSV.parse(zip_entry(export, csv_name), headers: true, skip_blanks: true)
  end
end
