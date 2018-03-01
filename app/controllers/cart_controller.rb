class CartController < ApplicationController
	before_action :authenticate_user!, except: [:add_to_cart, :view_order]


  def add_to_cart
##create an order earlier using our helper method
  @order = current_order
## get all the items from our line_item table
 	line_item = @order.line_items.find_by(product_id: params[:product_id])
  #if line_items.any? {|l| l.product_id == params[:product_id].to_i }

  ##check to see if product already exists in our cart to prevent doubles
  if !line_item.blank?
	 # 	line_item = LineItem.find_by(product_id: params[:product_id])
	 			line_item.update(quantity: line_item.quantity += params[:quantity].to_i)
	 			line_item.update(line_item_total: line_item.quantity * line_item.product.price)

    	 	else	
          ##if item is already in cart, update the quantity
  		  	line_item = @order.line_items.new(product_id: params[:product_id], quantity: params[:quantity])

          @order.save
          session[:order_id] = @order.id

  		  	line_item.update(line_item_total: line_item.quantity * line_item.product.price)
		  end
    redirect_back(fallback_location: root_path)

  end

  def view_order
  	@line_items = current_order.line_items
  end

  def checkout
    line_items = current_order.line_items
    current_order.update(user_id: current_user.id, subtotal: 0)

    @order = current_order


    unless line_items == 0
      line_items.each do |line_item|
        line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
        @order.order_items[line_item.product_id] = line_item.quantity 
        @order.subtotal += line_item.line_item_total
      end

      @order.save
      @order.update(sales_tax: (@order.subtotal * 0.08))
      @order.update(grand_total: (@order.sales_tax + @order.subtotal))
    end
  end

  def order_complete
    @order = Order.find(params[:order_id])
    @amount = (@order.grand_total.to_f.round(2) * 100).to_i
    @order.line_items.destroy_all
    session[:order_id] = nil

    customer = Stripe::Customer.create(
      :email => current_user.email,
      :card => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer => customer.id,
      :amount => @amount,
      :description => 'Spreeshopper',
      :currency => 'usd'
    )

    rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to cart_path
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

