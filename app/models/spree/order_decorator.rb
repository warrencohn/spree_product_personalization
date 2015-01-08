module Spree

  Order.class_eval do

    def personalizations_match(line_item, other_line_item_or_personalizations_attributes)
      if other_line_item_or_personalizations_attributes.kind_of? LineItem
        other_line_item = other_line_item_or_personalizations_attributes

        if line_item.personalizations.present?
          return false if line_item.personalizations.count != other_line_item.personalizations.count

          line_item.personalizations.each do |line_item_personalization|
            match = other_line_item.personalizations.detect do |other_line_item_personalization|
              line_item_personalization.match? other_line_item_personalization
            end
            return false unless match
          end
          true
        else
          other_line_item.personalizations.blank?
        end

      elsif other_line_item_or_personalizations_attributes.kind_of? Hash
        personalizations_attributes = other_line_item_or_personalizations_attributes[:personalizations_attributes]

        if line_item.personalizations.present?
          return false unless personalizations_attributes.kind_of? Array
          return false if line_item.personalizations.count != personalizations_attributes.count

          personalizations_attributes.each do |personalization_attributes|
            matching_product_personalization = line_item.product.personalizations.find do |product_personalization|
              product_personalization.name == personalization_attributes[:name]
            end

            if matching_product_personalization
              calculator = matching_product_personalization.calculator
              personalization_attributes[:price] = calculator.preferred_amount
              personalization_attributes[:currency] = calculator.preferred_currency
            end

            match = line_item.personalizations.detect do |line_item_personalization|
              line_item_personalization.match? personalization_attributes.with_indifferent_access
            end
            return false unless match
          end
          true

        else
          personalizations_attributes.blank?
        end
      else
        # wrong data passed in. force to not match (better create separate line_items than merge two different ones)
        false
      end
    end

    self.register_line_item_comparison_hook(:personalizations_match)

  end
end
