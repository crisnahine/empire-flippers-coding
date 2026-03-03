require "pagy/extras/metadata"
require "pagy/extras/overflow"
require "pagy/extras/limit"

Pagy::DEFAULT[:limit]     = 20
Pagy::DEFAULT[:limit_max] = 100
Pagy::DEFAULT[:metadata]  = %i[count page next prev last]
Pagy::DEFAULT[:overflow]  = :empty_page
