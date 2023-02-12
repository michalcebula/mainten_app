# frozen_string_literal: true

module Helpers
  module Paginable
    include Pagy::Backend

    def paginate(collection, serializer:)
      @pagy, collection = pagy(collection)
      return { data: collection, meta: customized_metadata } unless serializer

      data = serializer.new(collection).serializable_hash
      data.merge(meta: customized_metadata)
    end

    private

    def customized_metadata
      metadata = pagy_metadata(@pagy)
      metadata[:items_per_page] = metadata.delete(:items)
      metadata[:total_count] = metadata.delete(:count)
      metadata[:total_pages] = metadata.delete(:pages)

      metadata
    end
  end
end
