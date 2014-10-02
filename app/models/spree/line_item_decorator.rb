module Spree
  PermittedAttributes.module_eval do
    mattr_writer :line_item_attributes
  end

  unless PermittedAttributes.line_item_attributes.include? :personalization_attributes
    PermittedAttributes.line_item_attributes += [personalization_attributes: LineItemPersonalization.permitted_attributes] 
  end

  LineItem.class_eval do
    has_one :personalization, class_name: "Spree::LineItemPersonalization", :dependent => :destroy
    accepts_nested_attributes_for :personalization, :allow_destroy => true

    before_save :save_personalization, :if => -> { self.personalization }

    private

    def save_personalization
      pp = self.product.personalization
      if pp
        lp = self.personalization
        lp.line_item = self
        lp.name = pp.name
        calc = pp.calculator
        lp.price = calc.preferred_amount
        lp.currency = calc.preferred_currency
        lp.save!
      else
        # line_item personalization should not be created if the product doesn't have personalization
        self.personalization = nil
      end
    end

  end
end
