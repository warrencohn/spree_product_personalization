module Spree

  Order.class_eval do

    def personalizations_match(line_item, other_line_item_or_personalizations_attributes)
      line_item.personalizations_match_with? other_line_item_or_personalizations_attributes
    end

    self.register_line_item_comparison_hook(:personalizations_match)

  end
end
