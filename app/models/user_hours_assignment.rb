class UserHoursAssignment
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :id, :name, :hours_count, :color

  COLORS = %w[red green blue yellow orange purple pink].freeze

  validates :name, presence: true
  validates :hours_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :color, presence: true, inclusion: { in: COLORS }
end
