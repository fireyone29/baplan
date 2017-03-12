# Each person gets their own user.
#
# Use devise to create relatively secure log ins. Everything else is
# scoped on user to ensure privacy.
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :confirmable, :timeoutable

  has_many :goals, dependent: :destroy
end
