class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  delegate :name, to: :user
  default_scope ->{order(created_at: :desc)}
  validates :content, presence: true,
            length: {maximum: Settings.digits.length_140}
  validates :image,
            content_type: {in: Settings.image.accept_format,
                           message: I18n.t(".invalid_img_type")},
            size: {less_than: Settings.image.max_size.megabytes,
                   message: I18n.t(".invalid_img_size")}

  def display_image
    image.variant(resize_to_limit: Settings.image.size_500_500)
  end
end
