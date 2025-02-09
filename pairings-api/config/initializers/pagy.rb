require 'pagy/extras/overflow'
require 'pagy/extras/jsonapi'

Pagy::DEFAULT[:limit] = 10
Pagy::DEFAULT[:overflow] = :last_page
Pagy::DEFAULT[:jsonapi_meta] = true
Pagy::DEFAULT[:jsonapi_meta_include_total] = true
Pagy::DEFAULT[:jsonapi_meta_include_total_pages] = true
Pagy::DEFAULT[:jsonapi_meta_include_total_count] = true
Pagy::DEFAULT[:jsonapi_meta_include_params] = true
Pagy::DEFAULT[:jsonapi_meta_include_params_page] = true
