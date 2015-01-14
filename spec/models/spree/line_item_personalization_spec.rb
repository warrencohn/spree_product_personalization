require 'spec_helper'

describe Spree::LineItemPersonalization do

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

  context "validations" do
    context "#value" do
      before do
        @line_item_personalization = Spree::LineItemPersonalization.new
      end

      it "should have length greater than 1" do
        @line_item_personalization.value = ""
        expect(@line_item_personalization.valid?).to be_false
        expect(@line_item_personalization.errors[:value].first).to eq "Value is too short (minimum is 1 characters)"

        @line_item_personalization.value = "A"
        expect(@line_item_personalization.valid?).to be_true
      end

      it "should have length less than limit" do
        @line_item_personalization.limit = 5
        @line_item_personalization.value = "A long value"
        expect(@line_item_personalization.valid?).to be_false
        expect(@line_item_personalization.errors[:value].first).to eq "Value is too long (maximum is 5 characters)"

        @line_item_personalization.value = "long"
        expect(@line_item_personalization.valid?).to be_true
      end
    end

  end

  it "adds line_item with personalization to the order" do
    original_count = order.line_items.count
    line_item = order.contents.add(variant, quantity, get_params([personalization_1]))
    order.reload

    expect(order.line_items.count).to eq(original_count + 1)
    expect(line_item.quantity).to eq(quantity)
    expect(line_item.personalizations).to be
    expect(line_item.personalizations.first.value).to eq(personalization_1[:value])
    expect(line_item.personalizations.first.name).to eq(product_personalizations.first.name)
    expect(line_item.personalizations.first.price).to eq(product_personalizations.first.calculator.preferred_amount)
  end

  it "adds line_item of variant that does not have personalization to the order" do
    original_count = order.line_items.count
    line_item = order.contents.add(create(:variant), quantity, get_params([personalization_1]))
    order.reload

    expect(order.line_items.count).to eq(original_count + 1)
    expect(line_item.quantity).to eq(quantity)
    expect(line_item.personalizations).to eq([])
  end

  it "match line_item when personalization is same" do
    old_item = order.contents.add(variant, quantity, get_params([personalization_1]))
    new_item = order.contents.add(variant, quantity, get_params([personalization_1]))

    expect(new_item.id).to eq(old_item.id)
    expect(new_item.quantity).to eq(quantity * 2)
  end

  it "create new line_item when personalization is different" do
    old_item = order.contents.add(variant, quantity, get_params([personalization_1]))
    new_item = order.contents.add(variant, quantity, get_params([personalization_2]))

    expect(new_item.id).not_to eq(old_item.id)
  end

  context "if first order has more personalizations than the second" do
    before do
      @old_item = order.contents.add(variant, quantity, get_params([personalization_1, personalization_2]))
      @new_item = order.contents.add(variant, quantity, get_params([personalization_2]))
    end

    it "creats a new line_item" do
      expect(@new_item.id).not_to eq(@old_item.id)
    end
  end

  context "if the second order has more personalizations than the first" do
    before do
      @old_item = order.contents.add(variant, quantity, get_params([personalization_1]))
      @new_item = order.contents.add(variant, quantity, get_params([personalization_1, personalization_2]))
    end

    it "creats a new line_item" do
      expect(@new_item.id).not_to eq(@old_item.id)
    end
  end

  it "create new line_item when old line_item does not have personalization while the new one does" do
    old_item = order.contents.add(variant, quantity)
    new_item = order.contents.add(variant, quantity, get_params([personalization_1]))

    expect(new_item.id).not_to eq(old_item.id)
  end

  it "create new line_item when old line_item has personalization while the new one doesn't" do
    old_item = order.contents.add(variant, quantity, get_params([personalization_1]))
    new_item = order.contents.add(variant, quantity)

    expect(new_item.id).not_to eq(old_item.id)
  end

  it "create new line_item when params is in wrong format" do
    old_item = order.contents.add(variant, quantity)

    expect(order.personalizations_match(old_item, 1)).to be_false
  end

end
