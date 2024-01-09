# frozen_string_literal: true
@curation_concern = Wings::ActiveFedoraConverter.convert(resource: @curation_concern) if
  @curation_concern.is_a? Hyrax::Resource

# de-normalize creators from IDs and load their string display values
@curation_concern.load_creators_from_ids

json.extract! @curation_concern, *[:id] + @curation_concern.class.fields.reject { |f| [:has_model, :head, :tail, :state].include? f }
json.version @curation_concern.try(:etag)