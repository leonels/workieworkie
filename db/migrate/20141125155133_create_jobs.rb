class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :title
      t.string :salary
      t.string :department
      t.string :link

      t.timestamps
    end
  end
end
