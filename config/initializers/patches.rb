# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  # Extend engine and gem classes here, so this gets called on reload
  # to re-patch the newly redefined classes
  Hyrax::Collections::CollectionMemberSearchService.include(Extensions::CollectionMemberSearchService)
  Hydra::FileCharacterization::Characterizers::Fits.include(Extensions::ServletCharacterizer)
  Deprecation.include(Extensions::DeprecationReporting)
end
