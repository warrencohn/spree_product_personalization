FactoryGirl.define do

  sequence(:personalization_name) { |n| "Engrave-#{n}" }
  sequence(:personalization_description) { |n| "Description-#{n}" }

  factory :personalization_calculator, :class => Spree::Calculator::FlatRate do
    preferred_amount 3.0
  end

  factory :product_personalization, :class => Spree::ProductPersonalization do
    name { generate(:personalization_name) }
    description { generate(:personalization_description) }
    required true
    limit 200
    calculator { |p| p.association(:personalization_calculator) }
  end

  factory :option_value_product_personalization, :class => Spree::OptionValueProductPersonalization do
    product_personalization
    option_value
    calculator { |p| p.association(:personalization_calculator) }
  end

  factory :product_with_personalizations, parent: :product do
    ignore do
      personalization_count 3
    end
    after(:create) do |product, evaluator|
      create_list(:product_personalization, evaluator.personalization_count, product: product)
    end    
  end

  factory :variant_with_personalizations, parent: :variant do
    ignore do
      personalization_count 3
    end
    after(:create) do |variant, evaluator|
      variant.product = create(:product_with_personalizations, personalization_count: evaluator.personalization_count)
    end
  end

end
