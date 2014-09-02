module Spree
  class LineItemPersonalization < ActiveRecord::Base
    belongs_to :line_item

    COMPARISON_KEYS = [:name, :value, :price, :currency]

    def self.permitted_attributes 
      [:value]
    end

    def match?(olip)
      return false if olip.blank?

      self.slice(*COMPARISON_KEYS) == olip.slice(*COMPARISON_KEYS)
    end

  end
end
