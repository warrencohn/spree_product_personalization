module Spree
  class LineItemPersonalization < ActiveRecord::Base
    belongs_to :line_item

    validate :value_length

    before_validation { self.value = self.value.strip }

    COMPARISON_KEYS = [:name, :value, :price, :currency]

    def self.permitted_attributes
      [:name, :value, :option_value_id]
    end

    def match?(olp)
      return false if olp.blank?

      olp[:value] = olp[:value].strip if olp[:value]
      self.slice(*COMPARISON_KEYS) == olp.slice(*COMPARISON_KEYS)
    end

    def option_value_id
      @option_value_id
    end

    def option_value_id=(id)
      self.value = Spree::OptionValue.find_by_id(id).name
      @option_value_id = id
    end

    private

    def value_length
      if value.size < 1
        errors.add(:value, Spree.t('errors.line_item_personalization_value_greater_than_zero', size: 1))
      end

      if value.size > limit
        errors.add(:value, Spree.t('errors.line_item_personalization_value_less_than_limit', size: limit))
      end
    end
  end
end
