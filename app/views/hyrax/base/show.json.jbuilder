# frozen_string_literal: true
resource = Wings::ActiveFedoraConverter.convert(resource: @curation_concern)
fields = ((@curation_concern.class.fields & @presenter.methods)).sort # alphabedized list of field names to include
json.extract! resource, :id, :title # ensure id and title appear first
json.extract! resource, *fields         # add the other fields
json.creator @presenter.alpha_creator   # replace the creator node with the alphabetized creator list
json.version resource.try(:etag)
