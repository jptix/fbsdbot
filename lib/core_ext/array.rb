# encoding: utf-8
class Array
  def pick
    @item.nil? ? self[@item = rand(size)] : next_item
  end

  private
  def next_item
    self[self[(@item += 1)].nil? ? @item = 0 : @item]
  end
end
