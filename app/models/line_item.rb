class LineItem < ApplicationRecord
	belongs_to :product
	belongs_to :order, optional: true #true means User can add line items to cart without checking out.
end
