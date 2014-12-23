module Spree
  class OptionValueProductPersonalization < ActiveRecord::Base
    include Spree::Core::CalculatedAdjustments

    belongs_to :product_personalization, class_name: 'Spree::ProductPersonalization', inverse_of: :option_value_product_personalizations
    belongs_to :option_value, class_name: 'Spree::OptionValue', inverse_of: :option_value_product_personalizations
  end
end
