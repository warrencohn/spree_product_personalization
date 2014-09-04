module Spree
  class LineItemPersonalization < ActiveRecord::Base
    belongs_to :line_item

    COMPARISON_KEYS = [:name, :value, :price, :currency]

    def self.permitted_attributes 
      [:value]
    end

    def match?(olp)
      return false if olp.blank?

      self.slice(*COMPARISON_KEYS) == olp.slice(*COMPARISON_KEYS)
    end

  end
end
