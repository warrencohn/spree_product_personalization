require 'spec_helper'

describe Spree::Variant do


  let (:quantity) { 2 }
  let (:variant) { create(:variant_with_personalizations, price: 15) }
  let (:product_personalizations) { variant.product.personalizations }
  let (:personalization_1) { { name: product_personalizations[0].name, value: 'Red' } }
  let (:personalization_2) { { name: product_personalizations[1].name, value: 'Happy Birthday' } }
  let (:order) { create(:order) }

  context "#personalizations_attributes_price_modifier_amount_in" do
    context "if the product has personalizations" do
      context "if the personalization attributes for the product are passed in" do
        before do
          product_personalization_1_calc = product_personalizations[0].calculator
          product_personalization_1_calc.preferred_amount = 5.0
          product_personalization_1_calc.save
          product_personalization_2_calc = product_personalizations[1].calculator
          product_personalization_2_calc.preferred_amount = 7.0
          product_personalization_2_calc.save

          order.contents.add(variant, quantity, { personalizations_attributes: [personalization_1, personalization_2] })
        end

        it "sums the personalizations price and adds it to the order" do
          expect(order.total.to_s).to eq "54.0"
        end
      end

      context "if some unrelated personalization attributes are passed in" do
        before do
          random_personaliztion = { name: 'amicool', value: 'notcool'}
          order.contents.add(variant, quantity, { personalizations_attributes: [random_personaliztion] })
        end

        it "retains just the price of the product" do
          expect(order.total.to_s).to eq "30.0"
        end
      end
    end

    context "if the product does not have any personalizations" do
      before do
        order.contents.add(create(:variant, price: 10), quantity, { personalizations_attributes: [personalization_1, personalization_2] })
      end

      it "retains just the price of the product" do
          expect(order.total.to_s).to eq "20.0"
      end
    end
  end
end
