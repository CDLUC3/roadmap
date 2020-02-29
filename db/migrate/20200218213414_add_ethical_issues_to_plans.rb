class AddEthicalIssuesToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :ethical_issues, :integer, null: true
    add_column :plans, :ethical_issues_description, :text
    add_column :plans, :ethical_issues_report, :string
    add_column :plans, :start_date, :datetime
    add_column :plans, :end_date, :datetime
  end
end
