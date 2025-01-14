# frozen_string_literal: true

module IndexesMetadata
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ssi'] = object.title.first
      solr_doc['date_created_ssi'] = object.date_created.first
      solr_doc['date_created_iti'] = extract_year_from_date_created
      solr_doc['creator_tesim'] = creator_alternate_names(object).to_a + creator_names(object).to_a
      solr_doc['alpha_creator_tesim'] = creator_names(object).sort_by(&:downcase)
      solr_doc['creator_sim'] = creator_names(object)
      solr_doc['creator_id_ssim'] = creator_numerical_ids(object) if creator_numerical_ids(object)
      solr_doc['volume_number_isi'] = volume_no
      solr_doc['issue_number_isi'] = issue_no
    end
  end

  def creator_names(object)
    @creator_names ||= if object.creator_id.present?
                         creator_numerical_ids(object).flat_map do |creator_id|
                           Creator.find_by(id: creator_id)&.display_name
                         end.compact_blank
                       else
                         object.creator
                       end
  end

  def creator_alternate_names(object)
    @creator_alternate_names ||= if object.creator_id.present?
                                   creator_numerical_ids(object).flat_map do |creator_id|
                                     Creator.find_by(id: creator_id)&.alternate_names
                                   end.compact_blank
                                 else
                                   object.creator.flat_map do |name|
                                     Creator.find_by(display_name: name)&.alternate_names
                                   end.compact_blank
                                 end
  end

  def creator_numerical_ids(object)
    @creator_numerical_ids ||= if object.creator_id.present?
                                 object.creator_id.map do |identifier|
                                   identifier.to_s
                                   # URI(creator_triple.id).path.split('/').last
                                 end
                               end
  end

  # Looks for the first sequence of four digits in a row in date_created
  # and returns them as an integer
  def extract_year_from_date_created
    year = object.date_created.first&.match(/\d{4}/)
    year.to_s.to_i if year
  end

  # Convert issue portion of `issue_number` to an Integer
  # returns nil for non-integer and nil values
  # Note: force base 10 conversion to correctly handle leading 0's
  # "060" --> 60 (base 10)
  # instead of
  # "060" --> 48 (base 8, octal)
  def issue_no
    Integer(parsed_issue[:issue], 10, exception: false)
  end

  # Convert volume portion of `issue_number` to an Integer
  # returns nil for non-integer and nil values
  # Note: force base 10 conversion to correctly handle leading 0's
  def volume_no
    Integer(parsed_issue[:volume], 10, exception: false)
  end

  # Extract issue and volume numbers from the `issue_number` field
  # and returns a hash-like MatchData object
  # Examples from live data
  #   '006'             --> {volume: nil, issue: '006'}
  #   '130'             --> {volume: nil, issue: '130'}
  #   'Vol. 9, No. 1'   --> {volume: '9', issue: '1'}
  #   'Volume 32, No. 1'    etc.
  #   '203_1'
  #   'vol.6 no.236'
  #   'no. 70'
  #   'no.115'
  #   'no. 54A'
  #   'Vol. XIX'        --> {volume: nil, issue: nil} - i.e. return nil for non-numeric data
  def parsed_issue
    # prefixing with known text ensures we always return matchdata and don't have to deal with nil cases
    issue_string = "text: #{object.issue_number.first}"
    issue_string.match(/(?<anchor>text)[^\d]+(((?<volume>\d+)[^\d]+)?(?<issue>\d+))?/i)
  end
end
