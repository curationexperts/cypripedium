# frozen_string_literal: true

Qa::Authorities::Local::FileBasedAuthority.class_eval do
  def search(q)
    r = q.blank? ? [] : terms.select { |term| /\b#{q.downcase}/.match(term[:term].downcase) }
    r.map do |res|
      enrich_term_hash res
    end
  end

  def all
    terms.map do |res|
      enrich_term_hash res
    end
  end

  private

  def enrich_term_hash(res)
    res[:label] = res[:term] if res[:label].nil?
    res[:active] = true if res[:active].nil?
    res.with_indifferent_access
  end
end
