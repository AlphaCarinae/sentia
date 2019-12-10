class PagesController < ApplicationController

  require 'csv'


  def index
    data = Person.all.page(params[:page]).per(10).order(params[:order])
    
    @current_data = params[:search].present? ? data.where(first_name: params[:search]) : data
  end

  def import
    rowarray = Array.new
    csv_file = params[:file]

    @imported_data = CSV.read(csv_file.path, headers: true)

    @imported_data.each do |row| 
      new_data = row.to_h
      new_person = Person.new

      new_person.first_name = new_data["Name"].split(' ').first.titleize
      new_person.last_name = last_namer(new_data["Name"])
      new_person.species = new_data["Species"]
      new_person.gender = guess_gender(new_data["Gender"])
      new_person.weapon = new_data["Weapon"] if new_data["Weapon"]
      new_person.vehicle = new_data["Vehicle"] if new_data["Vehicle"]

      no_affiliations =  new_data["Affiliations"].present? ? false : true

      new_data["Affiliations"]&.split(',')&.each do |aff|
        old_aff = Affiliation.find_by name: aff

        if old_aff.present? 
          new_person.affiliations << old_aff
        else 
          new_affiliation = Affiliation.new name: aff
          new_affiliation.save

          new_person.affiliations << new_affiliation
        end
      end

      new_data["Location"]&.split(',')&.each do |loc|
        loc = loc.titleize

        old_loc = Location.find_by name: loc

        if old_loc.present?
          new_person.locations << old_loc
        else 
          new_loc = Location.new name: loc
          new_loc.save

          new_person.locations << new_loc
        end

      end

      exisiting_entry = Person.find_by first_name: new_person.first_name, last_name: new_person.last_name
      new_person.save if !exisiting_entry.present? && !no_affiliations
    end

    redirect_to '/'
  end

  def find
    redirect_to "/?search=#{params[:search]}"
  end


  private

  def guess_gender(entry)
    case entry.first.upcase
    when "M"
      "Male"
    when "F"
      "Female"
    when "O"
      "Other"
    end
  end

  def last_namer(string)
   string.slice(string.index(' '), string.size).titleize if string.index(' ')
  end
end
