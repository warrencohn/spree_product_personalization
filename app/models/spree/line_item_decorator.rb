module Spree
  PermittedAttributes.module_eval do
    mattr_writer :line_item_attributes
  end

  unless PermittedAttributes.line_item_attributes.include? :personalizations_attributes
    PermittedAttributes.line_item_attributes += [personalizations_attributes: LineItemPersonalization.permitted_attributes]
  end

  LineItem.class_eval do
    has_many :personalizations, class_name: "Spree::LineItemPersonalization", :dependent => :destroy
    accepts_nested_attributes_for :personalizations, :allow_destroy => true

    before_validation :copy_personalizations, :on => :create, :if => -> { self.personalizations.present? }


    def personalizations_match_with?(other_line_item_or_personalizations_attributes)
    end

    private

    def copy_personalizations
      if self.product.personalizations.present?
        self.personalizations.each do |line_item_personalization|
          matching_product_personalization = self.product.personalizations.find {|product_personalization| product_personalization.name == line_item_personalization.name }

          if matching_product_personalization
            line_item_personalization.line_item = self
            calculator = matching_product_personalization.calculator
            line_item_personalization.price = calculator.preferred_amount
            line_item_personalization.currency = calculator.preferred_currency
          else
            line_item_personalization.destroy
          end
        end
      else
        # line_item personalization should not be created if the product doesn't have personalization
        self.personalizations = []
      end
    end

  end
end
