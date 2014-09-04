module Spree
  Variant.class_eval do

    def personalization_attributes_price_modifier_amount_in(currency, options)
      calc = self.product.personalization.try(:calculator)
      if calc && calc.preferred_currency == currency
        calc.preferred_amount
      else
        0
      end
    end

  end
end
