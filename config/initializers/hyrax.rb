# frozen_string_literal: true

Hyrax.config do |config|
  # Injected via `rails g hyrax:work Publication`
  config.register_curation_concern :publication
  # Injected via `rails g hyrax:work ConferenceProceeding`
  config.register_curation_concern :conference_proceeding
  # Injected via `rails g hyrax:work Dataset`
  config.register_curation_concern :dataset
  # Register roles that are expected by your implementation.
  # @see Hyrax::RoleRegistry for additional details.
  # @note there are magical roles as defined in Hyrax::RoleRegistry::MAGIC_ROLES
  # config.register_roles do |registry|
  #   registry.add(name: 'captaining', description: 'For those that really like the front lines')
  # end

  # When an admin set is created, we need to activate a workflow.
  # The :default_active_workflow_name is the name of the workflow we will activate.
  # @see Hyrax::Configuration for additional details and defaults.
  # config.default_active_workflow_name = 'default'

  # Which RDF term should be used to relate objects to an admin set?
  # If this is a new repository, you may want to set a custom predicate term here to
  # avoid clashes if you plan to use the default (dct:isPartOf) for other relations.
  # config.admin_set_predicate = ::RDF::DC.isPartOf

  # Which RDF term should be used to relate objects to a rendering?
  # If this is a new repository, you may want to set a custom predicate term here to
  # avoid clashes if you plan to use the default (dct:hasFormat) for other relations.
  # config.rendering_predicate = ::RDF::DC.hasFormat

  # Configure the Logger for the Hyrax application; by default it is the Rails.logger.
  # config.logger = Rails.logger

  # Email recipient of messages sent via the contact form
  config.contact_email = "mpls.research.info.svcs@mpls.frb.org"

  # Text prefacing the subject entered in the contact form
  # config.subject_prefix = "Contact form:"

  # How many notifications should be displayed on the dashboard
  # config.max_notifications_for_dashboard = 5

  # How frequently should a file be fixity checked
  # config.max_days_between_fixity_checks = 7

  # Options to control the file uploader
  config.uploader = {
    limitConcurrentUploads: 6,
    maxNumberOfFiles: 100,
    maxFileSize: 900.megabytes
  }

  # Enable displaying usage statistics in the UI
  # Defaults to false
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  config.analytics = false

  # Enables a link to the citations page for a work
  # Default is false
  # config.citations = false

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # Hostpath to be used in Endnote exports
  config.persistent_hostpath = 'https://researchdatabase.minneapolisfed.org/concern/publications/'

  # If you have ffmpeg installed and want to transcode audio and video set to true
  # config.enable_ffmpeg = false

  # Hyrax uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  config.enable_noids = true

  # Template for your repository's NOID IDs
  # config.noid_template = ".reeddeeddk"

  # Use the database-backed minter class
  # config.noid_minter_class = Noid::Rails::Minter::Db

  # Store identifier minter's state in a file for later replayability
  # config.minter_statefile = '/tmp/minter-state'

  # Prefix for Redis keys
  # config.redis_namespace = "hyrax"

  # Path to the file characterization tool
  # config.fits_path = "fits.sh"

  # Path to the file derivatives creation tool
  # config.libreoffice_path = "soffice"

  # Option to enable/disable full text extraction from PDFs
  # Default is true, set to false to disable full text extraction
  # config.extract_full_text = true

  # How many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Hyrax can integrate with Zotero's Arkivo service for automatic deposit
  # of Zotero-managed research items.
  # config.arkivo_api = false

  # Stream realtime notifications to users in the browser
  # config.realtime_notifications = true

  # Location autocomplete uses geonames to search for named regions
  # Username for connecting to geonames
  config.geonames_username = ENV['GEONAMES_USERNAME'] || 'mplsfedris'

  # Should the acceptance of the licence agreement be active (checkbox), or
  # implied when the save button is pressed? Set to true for active
  # The default is true.
  # TODO: Turn off checkbox - will likely break javascript that enables the Save button in spec/system/create_publication_spec.rb
  config.active_deposit_agreement_acceptance = ENV["RAILS_ENV"] == "production" ? false : true

  # Should work creation require file upload, or can a work be created first
  # and a file added at a later time?
  # The default is true.
  # config.work_requires_files = true

  # How many rows of items should appear on the work show view?
  # The default is 10
  # config.show_work_item_rows = 10

  # Enable IIIF image service. This is required to use the
  # IIIF viewer enabled show page
  #
  # If you have run the riiif generator, an embedded riiif service
  # will be used to deliver images via IIIF. If you have not, you will
  # need to configure the following other configuration values to work
  # with your image server:
  #
  #   * iiif_image_url_builder
  #   * iiif_info_url_builder
  #   * iiif_image_compliance_level_uri
  #   * iiif_image_size_default
  #
  # Default is false
  # config.iiif_image_server = false

  # Returns a URL that resolves to an image provided by a IIIF image server
  # config.iiif_image_url_builder = lambda do |file_id, base_url, size, format|
  #   "#{base_url}/downloads/#{file_id.split('/').first}"
  # end

  # Returns a URL that resolves to an info.json file provided by a IIIF image server
  # config.iiif_info_url_builder = lambda do |_, _|
  #   ""
  # end

  # Returns a URL that indicates your IIIF image server compliance level
  # config.iiif_image_compliance_level_uri = 'http://iiif.io/api/image/2/level2.json'

  # Returns a IIIF image size default
  # config.iiif_image_size_default = '600,'

  # Fields to display in the IIIF metadata section; default is the required fields
  # config.iiif_metadata_fields = Hyrax::Forms::WorkForm.required_fields

  # Should a button with "Share my work" show on the front page to all users (even those not logged in)?
  config.display_share_button_when_not_logged_in = false

  # This user is logged as the acting user for jobs and other processes that
  # run without being attributed to a specific user (e.g. creation of the
  # default admin set).
  # config.system_user_key = 'systemuser@example.com'

  # The user who runs batch jobs. Update this if you aren't using emails
  # config.batch_user_key = 'batchuser@example.com'

  # The user who runs fixity check jobs. Update this if you aren't using emails
  # config.audit_user_key = 'audituser@example.com'
  #
  # The banner image. Should be 5000px wide by 1000px tall
  config.banner_image = 'https://raw.githubusercontent.com/MPLSFedResearch/cypripedium/main/app/assets/images/chalkboardcrop.jpg'

  # Temporary paths to hold uploads before they are ingested into FCrepo
  # These must be lambdas that return a Pathname. Can be configured separately
  #  config.upload_path = ->() { Rails.root + 'tmp' + 'uploads' }
  #  config.cache_path = ->() { Rails.root + 'tmp' + 'uploads' + 'cache' }

  # The registered candidate derivative services.  In the array, the first `valid?` candidate will
  # handle the derivative generation.
  # config.derivative_services = [Hyrax::FileSetDerivativesService]

  # Location on local file system where derivatives will be stored
  # If you use a multi-server architecture, this MUST be a shared volume
  # config.derivatives_path = Rails.root.join('tmp', 'derivatives')
  # NOTE: the default value is overridden in the production environment

  # Should schema.org microdata be displayed?
  config.display_microdata = true

  # What default microdata type should be used if a more appropriate
  # type can not be found in the locale file?
  #  config.microdata_default_type = 'http://schema.org/CreativeWork'

  # Location on local file system where uploaded files will be staged
  # prior to being ingested into the repository or having derivatives generated.
  # If you use a multi-server architecture, this MUST be a shared volume.
  # config.working_path = Rails.root.join( 'tmp', 'uploads')

  # Should the media display partial render a download link?
  # config.display_media_download_link = true

  # A configuration point for changing the behavior of the license service
  #   @see Hyrax::LicenseService for implementation details
  # config.license_service_class = Hyrax::LicenseService

  # Labels for display of permission levels
  # config.permission_levels = { "View/Download" => "read", "Edit access" => "edit" }

  # Labels for permission level options used in dropdown menus
  # config.permission_options = { "Choose Access" => "none", "View/Download" => "read", "Edit" => "edit" }

  # Labels for owner permission levels
  # config.owner_permission_levels = { "Edit Access" => "edit" }

  # Path to the ffmpeg tool
  # config.ffmpeg_path = 'ffmpeg'

  # Max length of FITS messages to display in UI
  # config.fits_message_length = 5

  # ActiveJob queue to handle ingest-like jobs
  # config.ingest_queue_name = :default

  ## Attributes for the lock manager which ensures a single process/thread is mutating a ore:Aggregation at once.
  # How many times to retry to acquire the lock before raising UnableToAcquireLockError
  # config.lock_retry_count = 600 # Up to 2 minutes of trying at intervals up to 200ms
  #
  # Maximum wait time in milliseconds before retrying. Wait time is a random value between 0 and retry_delay.
  # config.lock_retry_delay = 200
  #
  # How long to hold the lock in milliseconds
  # config.lock_time_to_live = 60_000

  ## Do not alter unless you understand how ActiveFedora handles URI/ID translation
  # config.translate_id_to_uri = lambda do |uri|
  #                                baseparts = 2 + [(Noid::Rails::Config.template.gsub(/\.[rsz]/, '').length.to_f / 2).ceil, 4].min
  #                                uri.to_s.sub(baseurl, '').split('/', baseparts).last
  #                              end
  # config.translate_uri_to_id = lambda do |id|
  #                                "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{Noid::Rails.treeify(id)}"
  #                              end

  # Identify the model class name that will be used for Collections in your app
  # (i.e. ::Collection for ActiveFedora, Hyrax::PcdmCollection for Valkyrie)
  config.collection_model = '::Collection'
  # config.collection_model = 'Hyrax::PcdmCollection'

  # Identify the model class name that will be used for Admin Sets in your app
  # (i.e. AdminSet for ActiveFedora, Hyrax::AdministrativeSet for Valkyrie)
  config.admin_set_model = 'AdminSet'
  # config.admin_set_model = 'Hyrax::AdministrativeSet'

  # Identify the form that will be used for Admin Sets
  # config.administrative_set_form = Hyrax::Forms::AdministrativeSetForm

  # Identify the indexer that will be used for Admin Sets
  # config.administrative_set_indexer = Hyrax::Indexers::AdministrativeSetIndexer

  # Identify the model class name that will be used for File Sets in your app
  # (i.e. FileSet for ActiveFedora, Hyrax::FileSet for Valkyrie)
  config.file_set_model = '::FileSet'

  # Identify the form that will be used for File Sets
  # config.file_set_form = Hyrax::Forms::FileSetForm

  # Identify the indexer that will be used for File Sets
  # config.file_set_indexer = Hyrax::Indexers::FileSetIndexer

  # Service for resolving {FileMetadata} nodes by status, e.g. "primary", rather
  # than use.
  # config.file_set_file_service = Hyrax::FileSetFileService

  # Identify the form that will be used for Collections
  # config.pcdm_collection_form = Hyrax::Forms::PcdmCollectionForm

  # Identify the indexer that will be used for Collections
  # config.pcdm_collection_indexer = Hyrax::Indexers::PcdmCollectionIndexer

  # Provide a proc for form generation for Objects
  # config.pcdm_object_form_builder = lambda do |model_class|
  #   Hyrax::Forms::PcdmObjectForm(model_class)
  # end

  # Provide a proc for indexer generation for Objects
  # config.pcdm_object_indexer_builder = lambda do |model_class|
  #   Hyrax::Indexers::PcdmObjectIndexer(model_class)
  # end

  ## Enable Valkyrie only mode
  # config.use_valkyrie = true
  # config.disable_wings = true

  # When your application is ready to use the valkyrie index instead of the one
  # maintained by active fedora, you will need to set this to true. You will
  # also need to update your Blacklight configuration.
  config.query_index_from_valkyrie = false

  ## Configure index adapter for Valkyrie::Resources to use solr readonly indexer
  config.index_adapter = :solr_index

  ## Fedora import/export tool
  #
  # Path to the Fedora import export tool jar file
  # config.import_export_jar_file_path = "tmp/fcrepo-import-export.jar"
  #
  # Location where BagIt files should be exported
  # config.bagit_dir = "tmp/descriptions"

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      Hyrax.logger.warn 'BrowseEverything is not installed'
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end

  ## Register all directories which can be used to ingest from the local file
  # system.
  #
  # Any file, and only those, that is anywhere under one of the specified
  # directories can be used by CreateWithRemoteFilesActor to add local files
  # to works. Files uploaded by the user are handled separately and the
  # temporary directory for those need not be included here.
  #
  # Default value includes BrowseEverything.config['file_system'][:home] if it
  # is set, otherwise default is an empty list. You should only need to change
  # this if you have custom ingestions using CreateWithRemoteFilesActor to
  # ingest files from the file system that are not part of the BrowseEverything
  # mount point.
  #
  # config.registered_ingest_dirs = []

  ##
  # Set the system-wide virus scanner
  config.virus_scanner = Hyrax::VirusScanner

  ## Remote identifiers configuration
  # Add registrar implementations by uncommenting and adding to the hash below.
  # See app/services/hyrax/identifier/registrar.rb for the registrar interface
  # config.identifier_registrars = {}
end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"

Qa::Authorities::Local.register_subauthority('subjects', 'Qa::Authorities::Local::TableBasedAuthority')
Qa::Authorities::Local.register_subauthority('languages', 'Qa::Authorities::Local::TableBasedAuthority')
Qa::Authorities::Local.register_subauthority('genres', 'Qa::Authorities::Local::TableBasedAuthority')
