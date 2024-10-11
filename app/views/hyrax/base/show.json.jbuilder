# frozen_string_literal: true
fields = ((@curation_concern.class.fields & @presenter.methods)).sort # alphabedized list of field names to include
fields = fields.reject { |field| field.match?(/id/) } # exclude internal ID fields

json.extract! @curation_concern, :id, :title # ensure id and title appear first
json.extract! @curation_concern, *fields # add the other fields
json.creator @presenter.alpha_creator # replace the creator node with the alphabetized creator list
json.version @curation_concern.try(:etag)
