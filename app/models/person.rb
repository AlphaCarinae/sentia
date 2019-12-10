class Person < ApplicationRecord

  validates :first_name, :species, :gender, presence: true

  has_and_belongs_to_many :locations
  has_and_belongs_to_many :affiliations
end
