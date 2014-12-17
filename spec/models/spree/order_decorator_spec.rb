require 'spec_helper'

describe Spree::Order do

  context "#merge!" do
    let(:variant) { create(:variant_with_personalization) }
    let(:order_1) { create(:order) }
    let(:order_2) { create(:order) }
    let(:value_1) { "Happy Birthday!" }
    let(:value_2) { "Hello World!" }

    it "merges together two orders with line items for the same variant and personalization" do
      order_1.contents.add(variant, 1, { personalization_attributes: { value: value_1 } })
      order_2.contents.add(variant, 1, { personalization_attributes: { value: value_1 } })
      order_1.merge!(order_2)
      line_item = order_1.line_items.first

      expect(order_1.line_items.count).to eq(1)
      expect(line_item.quantity).to eq(2)
      expect(line_item.variant_id).to eq(variant.id)
      expect(line_item.personalization.value).to eq(value_1)
    end

    it "does not merge together two orders with line items for the same variant but different personalization" do
      order_1.contents.add(variant, 1, { personalization_attributes: { value: value_1 } })
      order_2.contents.add(variant, 1, { personalization_attributes: { value: value_2 } })
      order_1.merge!(order_2)
      line_items = order_1.line_items
      line_item_1, line_item_2 = line_items.all

      expect(line_items.count).to eq(2)
      expect(line_items.pluck(:quantity)).to eq([1, 1])
      expect(line_items.pluck(:variant_id)).to eq([variant.id, variant.id])
      expect(line_item_1.personalization.value).to eq(value_1)
      expect(line_item_2.personalization.value).to eq(value_2)
    end

    it "does not merge together two orders with line items for the same variant wo/w personalization" do
      order_1.contents.add(variant, 1)
      order_2.contents.add(variant, 1, { personalization_attributes: { value: value_2 } })
      order_1.merge!(order_2)
      line_items = order_1.line_items
      line_item_1, line_item_2 = line_items.all

      expect(line_items.count).to eq(2)
      expect(line_items.pluck(:quantity)).to eq([1, 1])
      expect(line_items.pluck(:variant_id)).to eq([variant.id, variant.id])
      expect(line_item_1.personalization).to be_nil
      expect(line_item_2.personalization.value).to eq(value_2)
    end

    it "does not merge together two orders with line items for the same variant w/wo personalization" do
      order_1.contents.add(variant, 1, { personalization_attributes: { value: value_1 } })
      order_2.contents.add(variant, 1)
      order_1.merge!(order_2)
      line_items = order_1.line_items
      line_item_1, line_item_2 = line_items.all

      expect(line_items.count).to eq(2)
      expect(line_items.pluck(:quantity)).to eq([1, 1])
      expect(line_items.pluck(:variant_id)).to eq([variant.id, variant.id])
      expect(line_item_1.personalization.value).to eq(value_1)
      expect(line_item_2.personalization).to be_nil
    end

  end

end
