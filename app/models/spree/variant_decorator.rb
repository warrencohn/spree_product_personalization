module Spree
  Variant.class_eval do

    def personalizations_attributes_price_modifier_amount_in(currency, options)
      modifier_amount = 0

      options.each do |personalization_attributes|
        personalization = product.personalization_with_name(personalization_attributes[:name])

        calc = personalization.try(:calculator)
        if calc && calc.preferred_currency == currency
          modifier_amount += calc.preferred_amount
        end
      end

      modifier_amount
    end

  end
end
