class CartController < ApplicationController
	before_action :authenticate_user!, except: [:add_to_cart, :view_order]



  def add_to_cart

 	line_items = LineItem.all
  	 	if line_items.any? {|l| l.product_id == params[:product_id].to_i }
	 			line_item = LineItem.find_by(product_id: params[:product_id])
	 			line_item.update(quantity: line_item.quantity += params[:quantity].to_i)
	 			line_item.update(line_item_total: line_item.quantity * line_item.product.price)

  	 	else	
		  	line_item = LineItem.create(product_id: params[:product_id], quantity: params[:quantity])
		  	line_item.update(line_item_total: line_item.quantity * line_item.product.price)
		  end
  		redirect_back(fallback_location: root_path)

  end

  def view_order
  	@line_items = LineItem.all
  end

  def checkout
  line_items = LineItem.all
  @order = Order.create(user_id: current_user.id, subtotal: 0)

  line_items.each do |line_item|
    line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
    @order.order_items[line_item.product_id] = line_item.quantity 
    @order.subtotal += line_item.line_item_total
  end
  @order.save

  @order.update(sales_tax: (@order.subtotal * 0.08))
  @order.update(grand_total: (@order.sales_tax + @order.subtotal))

  line_items.destroy_all
  end

  def edit_line_item
  	line_item = LineItem.find(params[:id])
  	price = line_item.product.price
  	line_item.update(quantity: params[:quantity], line_item_total: params[:quantity].to_f * price)

  	redirect_back(fallback_location: root_path)
  end	


  def delete_line_item
  	line_item = LineItem.find(params[:id])
  	line_item.destroy
  	redirect_back(fallback_location: root_path)
  end

end

