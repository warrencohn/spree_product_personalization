require 'spec_helper'

describe Spree::Product do

  context "duplication" do

    let(:product) { create(:product_with_personalizations) }
    let(:source) { product.personalizations }
    let(:product_with_options) { create(:product_with_option_value_personalizations) }
    let(:source_with_options) { product_with_options.personalizations }

    it 'clones personalization info' do
      target = product.duplicate.personalizations

      expect(target).to be
      expect(target.count).to eq(source.count)
      target.each_with_index do |t, i|
        expect(t.id).not_to eq(source[i].id)
        expect(t.name).to eq(source[i].name)
        expect(t.description).to eq(source[i].description)
        expect(t.required).to eq(source[i].required)
        expect(t.limit).to eq(source[i].limit)
        expect(t.calculator.id).to_not eq(source[i].calculator.id)
        expect(t.calculator.preferred_amount).to eq(source[i].calculator.preferred_amount)
      end
    end

    it 'clones option value personalization info' do
      target = product_with_options.duplicate.personalizations

      expect(target).to be
      expect(target.count).to eq(source_with_options.count)
      target.each_with_index do |t, i|
        expect(t.id).not_to eq(source_with_options[i].id)
        expect(t.name).to eq(source_with_options[i].name)
        expect(t.calculator.id).to_not eq(source_with_options[i].calculator.id)
        expect(t.calculator.preferred_amount).to eq(source_with_options[i].calculator.preferred_amount)
        s = source_with_options[i].option_value_product_personalizations
        t.option_value_product_personalizations.each_with_index do |o, p|
          expect(o.id).not_to eq(s[p].id)
          expect(o.product_personalization_id).not_to eq(s[p].product_personalization_id)
          expect(o.option_value_id).to eq(s[p].option_value_id)
          expect(o.position).to eq(s[p].position)
          expect(o.calculator.id).not_to eq(s[p].calculator.id)
          expect(o.calculator.preferred_amount).to eq(s[p].calculator.preferred_amount)
        end
      end
    end
  end

end
