FactoryGirl.define do

  factory :personalization_calculator, :class => Spree::Calculator::FlatRate do
    preferred_amount 3.0
  end

  factory :product_personalization, :class => Spree::ProductPersonalization do
    name "Engrave"
    required true
    limit 200
    calculator { |p| p.association(:personalization_calculator) }
  end

  factory :product_with_personalization, parent: :product do
    personalization { |p| p.association(:product_personalization) }
  end

  factory :variant_with_personalization, parent: :variant do
    product { |p| p.association(:product_with_personalization) }
  end

end
