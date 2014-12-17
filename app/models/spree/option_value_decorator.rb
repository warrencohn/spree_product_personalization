module Spree
  OptionValue.class_eval do
    has_and_belongs_to_many :product_personalizations,
      join_table: :spree_option_values_product_personalizations,
      class_name: "Spree::ProductPersonalization"
  end
end

