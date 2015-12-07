module Spree
  OptionValue.class_eval do
    has_many :option_value_product_personalizations, dependent: :destroy, inverse_of: :option_value
    has_many :product_personalizations, through: :option_value_product_personalizations
  end
end

