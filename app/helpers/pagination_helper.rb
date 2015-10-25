

module PaginationHelper

  def paginate (items, number_of_items_per_page)
    items.page(params[:page]).per_page(number_of_items_per_page)
  end

end