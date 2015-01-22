module Spree
  Variant.class_eval do

    def personalizations_attributes_price_modifier_amount_in(currency, options)
      modifier_amount = 0

      options.each do |personalization_attributes|
        personalization = product.personalization_with_name(personalization_attributes[:name])

        if personalization && personalization.list?
          option_value_id = personalization_attributes[:option_value_id]
          option_value_product_personalization = personalization.option_value_product_personalizations.find_by_option_value_id(option_value_id)
          calc = option_value_product_personalization.try(:calculator)
        else
          calc = personalization.try(:calculator)
        end

        if calc && calc.preferred_currency == currency
          modifier_amount += calc.preferred_amount
        end
      end

      modifier_amount
    end

  end
end
