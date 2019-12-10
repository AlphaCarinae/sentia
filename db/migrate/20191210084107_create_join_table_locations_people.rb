class CreateJoinTableLocationsPeople < ActiveRecord::Migration[5.2]
  def change
    create_join_table :locations, :people do |t|
      t.index [:location_id, :person_id]
      t.index [:person_id, :location_id]
    end
  end
end
