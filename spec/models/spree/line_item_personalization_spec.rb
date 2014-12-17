require 'spec_helper'

describe Spree::LineItemPersonalization do

  let(:quantity) { 2 }
  let(:value_1) { "Happy Birthday!" }
  let(:value_2) { "Hello World!" }
  let(:order) { create(:order) }
  let(:variant) { create(:variant_with_personalizations) }
  let(:product_personalization) { variant.product.personalization }

  def get_params(value)
    options  = { personalization_attributes: { value: value } }
    ActionController::Parameters.new(options).permit(:personalization_attributes => Spree::LineItemPersonalization.permitted_attributes)
  end

  it "adds line_item with personalization to the order" do
    before = order.line_items.count
    line_item = order.contents.add(variant, quantity, get_params(value_1))
    order.reload

    expect(order.line_items.count).to eq(before + 1)
    expect(line_item.quantity).to eq(quantity)
    expect(line_item.personalization).to be
    expect(line_item.personalization.value).to eq(value_1)
    expect(line_item.personalization.name).to eq(product_personalization.name)
    expect(line_item.personalization.price).to eq(product_personalization.calculator.preferred_amount)
  end

  it "adds line_item of variant that does not have personalization to the order" do
    before = order.line_items.count
    line_item = order.contents.add(create(:variant), quantity, get_params(value_1))
    order.reload

    expect(order.line_items.count).to eq(before + 1)
    expect(line_item.quantity).to eq(quantity)
    expect(line_item.personalization).to be_nil
  end

  it "match line_item when personalization is same" do
    old_item = order.contents.add(variant, quantity, get_params(value_1))
    new_item = order.contents.add(variant, quantity, get_params(value_1))

    expect(new_item.id).to eq(old_item.id)
    expect(new_item.quantity).to eq(quantity * 2)
  end

  it "create new line_item when personalization is different" do
    old_item = order.contents.add(variant, quantity, get_params(value_1))
    new_item = order.contents.add(variant, quantity, get_params(value_2))

    expect(new_item.id).not_to eq(old_item.id)
  end

  it "create new line_item when old line_item does not have personalization while the new one does" do
    old_item = order.contents.add(variant, quantity)
    new_item = order.contents.add(variant, quantity, get_params(value_1))

    expect(new_item.id).not_to eq(old_item.id)
  end

  it "create new line_item when old line_item has personalization while the new one doesn't" do
    old_item = order.contents.add(variant, quantity, get_params(value_1))
    new_item = order.contents.add(variant, quantity)

    expect(new_item.id).not_to eq(old_item.id)
  end

  it "create new line_item when params is in wrong format" do
    old_item = order.contents.add(variant, quantity)

    expect(order.personalization_match(old_item, 1)).to be_false
  end

end
