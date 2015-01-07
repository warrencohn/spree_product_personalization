require 'spec_helper'

describe Spree::Product do

  context "duplication" do

    let(:product) { create(:product_with_personalizations) }
    let(:source) { product.personalizations }

    it 'clones personalization info' do
      target = product.duplicate.personalizations

      expect(target).to be
      expect(target.count).to eq(source.count)
      target.each_with_index do |t, i|
        expect(target[i].id).not_to eq(source[i].id)
        expect(target[i].name).to eq(source[i].name)
        expect(target[i].description).to eq(source[i].description)
        expect(target[i].required).to eq(source[i].required)
        expect(target[i].limit).to eq(source[i].limit)
        expect(target[i].calculator.id).to_not eq(source[i].calculator.id)
        expect(target[i].calculator.preferred_amount).to eq(source[i].calculator.preferred_amount)
      end
    end
  end

end
