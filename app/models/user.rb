class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy

  def user_name
    self.email.split("@")[0].capitalize
  end
end
