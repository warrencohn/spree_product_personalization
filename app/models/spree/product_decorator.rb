module Spree
  Product.class_eval do
    has_many :personalizations, class_name: "Spree::ProductPersonalization", :dependent => :destroy
    accepts_nested_attributes_for :personalizations, :allow_destroy => true

    def duplicate_extra(product)
      product.personalizations.each do |p|
        new_p = p.dup
        new_p.product = self
        new_p.calculator = p.calculator.dup
        new_p.calculator.preferred_amount = p.calculator.preferred_amount
        new_p.option_value_product_personalizations = p.option_value_product_personalizations.map do |v|
          new_v = v.dup
          new_v.calculator = v.calculator.dup
          new_v.calculator.preferred_amount = v.calculator.preferred_amount
          new_v
        end
        self.personalizations << new_p
      end
    end

    def personalization_with_name(name)
      personalizations.includes(:calculator).detect { |product_personalization| product_personalization.name == name }
    end
  end
end
