module Spree
  class LineItemPersonalization < ActiveRecord::Base
    belongs_to :line_item

    validates_length_of :value, in: Range.new(1, Spree::Personalization::Config[:text_limit])

    before_validation { self.value = self.value.strip }

    COMPARISON_KEYS = [:name, :value, :price, :currency]

    def self.permitted_attributes
      [:name, :value]
    end

    def match?(olp)
      return false if olp.blank?

      olp[:value] = olp[:value].strip if olp[:value]
      self.slice(*COMPARISON_KEYS) == olp.slice(*COMPARISON_KEYS)
    end
  end
end
