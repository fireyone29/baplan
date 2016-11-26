class Goal < ApplicationRecord
  belongs_to :user

  validates :description, presence: true, allow_blank: false
  validates_uniqueness_of :description, scope: :user_id
  enum frequency: [:daily, :weekly]
end
