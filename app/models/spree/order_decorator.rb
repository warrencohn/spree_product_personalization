module Spree

  Order.class_eval do

    def personalization_match(line_item, other_line_item_or_personalization_attributes)
      if other_line_item_or_personalization_attributes.kind_of? LineItem
        other_line_item = other_line_item_or_personalization_attributes
        lp = line_item.personalization
        olp = other_line_item.personalization
        if lp.nil?
          olp.nil?
        else
          lp.match? olp
        end

      elsif other_line_item_or_personalization_attributes.kind_of? Hash
        options = other_line_item_or_personalization_attributes[:personalization_attributes]
        lp = line_item.personalization
        if lp.nil?
          options.blank?
        else
          pp = line_item.product.personalization
          if pp
            options ||= {}
            options['name'] = pp.name
            calc = pp.calculator
            options['price'] = calc.preferred_amount
            options['currency'] = calc.preferred_currency
          end
          lp.match? options.with_indifferent_access
        end
      else
        # wrong data passed in. force to not match (better create separate line_items than merge two different ones)
        false
      end
    end

    self.register_line_item_comparison_hook(:personalization_match)

  end
end
