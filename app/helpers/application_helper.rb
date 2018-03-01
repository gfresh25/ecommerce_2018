module ApplicationHelper

	def count_items
 		current_order.line_items.count
 	end

end
