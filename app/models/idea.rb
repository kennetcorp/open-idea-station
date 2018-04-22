class Idea < ApplicationRecord
  include CableBroadcast

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :viewers, dependent: :destroy
  has_many :idea_categories, dependent: :destroy
  has_many :categories, through: :idea_categories

  validates :name, presence: true, length: { minimum: 3 }, uniqueness: { case_sensitive: false }
  validates :description, presence: true, length: { minimum: 10 }

  attr_accessor :all_categories
  after_save :save_categories
  after_destroy :broadcast_delete
  after_initialize :set_is_archived

  def set_is_archived
    self.is_archived ||= false
  end

  def broadcast_delete
    send_broadcast(status: 'delete', id: id, name: name)
  end

  def all_categories
    self.categories.uniq.map(&:name).join(', ')
  end

  private

  def save_categories
    if @all_categories
      @all_categories.split(',').each do |name|
        self.categories << Category.where(name: name.strip).first_or_create!
      end
    end
  end

end
