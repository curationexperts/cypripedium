# frozen_string_literal: true
Flipflop.configure do
  feature :apa_citation,
          default: false,
          description: "Display APA format citation in the citation pop-up"
  feature :mla_citation,
          default: false,
          description: "Display MLA format citation in the citation pop-up"
end
