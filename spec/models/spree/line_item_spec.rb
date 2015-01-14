require 'spec_helper'

describe Spree::LineItem do

  let (:quantity) { 2 }
  let (:variant) { create(:variant_with_personalizations) }
  let (:product_personalizations) { variant.product.personalizations }
  let (:personalization_1) { { name: product_personalizations[0].name, value: 'Red' } }
  let (:personalization_2) { { name: product_personalizations[1].name, value: 'Happy Birthday' } }
  let(:order) { create(:order) }

  def get_params(personalization_attributes)
    options  = { personalizations_attributes: personalization_attributes }
    ActionController::Parameters.new(options).permit(:personalizations_attributes => Spree::LineItemPersonalization.permitted_attributes)
  end

  context "#copy_personalizations" do
    context "if the product does not have any personalization" do
      it 'does not copy any personalizations even if personalization is passed' do
        original_line_items_count = order.line_items.count
        line_item = order.contents.add(create(:variant), quantity, get_params([personalization_1, personalization_2]))
        order.reload

        expect(order.line_items.count).to eq(original_line_items_count + 1)
        expect(line_item.quantity).to eq(quantity)
        expect(line_item.personalizations.first).to be_nil
      end
    end

    context "if the product has personalizations" do
      it 'copies the found the personalizations' do
        pp_1 = product_personalizations[0]
        pp_1.update(limit: 45)
        pp_2 = product_personalizations[1]
        pp_2.update(limit: 67)

        original_line_items_count = order.line_items.count
        random_personaliztion = { name: 'Not-Set-In-Product', value: 'some_value' }
        line_item = order.contents.add(variant, quantity, get_params([personalization_1, personalization_2, random_personaliztion]))
        order.reload

        expect(order.line_items.count).to eq(original_line_items_count + 1)
        expect(line_item.quantity).to eq(quantity)
        expect(line_item.personalizations.count).to eq 2

        expect(line_item.personalizations.map(&:value).uniq).to eq [personalization_1[:value], personalization_2[:value]]
        expect(line_item.personalizations.map(&:name).uniq).to eq [personalization_1[:name], personalization_2[:name]]
        expect(line_item.personalizations.map(&:limit).uniq).to eq [45, 67]

        personalization_calculators = product_personalizations.map(&:calculator)[0..1]
        expect(line_item.personalizations.map(&:price).map(&:to_s)).to eq personalization_calculators.map(&:preferred_amount).map(&:to_s)
        expect(line_item.personalizations.map(&:currency)).to eq personalization_calculators.map(&:preferred_currency)
      end
    end
  end
end
