# frozen_string_literal: true

Pagy::OPTIONS[:limit] = 20
Pagy::OPTIONS[:size] = 10
Pagy::OPTIONS[:page_key] = :page
Pagy::OPTIONS[:overflow] = :last_page
Pagy::OPTIONS[:metadata] = %i[page prev next last count pages series]
