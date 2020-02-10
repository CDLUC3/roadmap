# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id           :integer          not null, primary key
#  firstname    :string
#  surname      :string
#  email        :string
#  phone        :string
#  roles        :integer
#  org_id       :integer
#  plan_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_contributors_on_id      (id)
#  index_contributors_on_email   (email)
#  index_contributors_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (plan_id => plans.id)

class Contributor < ActiveRecord::Base

  include FlagShihTzu
  include ValidationMessages
  include Identifiable

  # ================
  # = Associations =
  # ================

  # TODO: uncomment the 'optional' bit after the Rails 5 migration. Rails 5+ will
  #       NOT allow nil values in a belong_to field!
  belongs_to :org #, optional: true

  belongs_to :plan

  # =====================
  # = Nested attributes =
  # =====================

  accepts_nested_attributes_for :org

  # ===============
  # = Validations =
  # ===============

  validates :roles, presence: { message: PRESENCE_MESSAGE }

  validate :name_or_email_presence

  ONTOLOGY_NAME = "CRediT - Contributor Roles Taxonomy".freeze
  ONTOLOGY_LANDING_PAGE = "https://casrai.org/credit/".freeze
  ONTOLOGY_BASE_URL = "https://dictionary.casrai.org/Contributor_Roles".freeze

  ##
  # Define Bit Field values for roles
  # Derived from the CASRAI CRediT Taxonomy: https://casrai.org/credit/
  has_flags 1 =>  :conceptualization,
            2 =>  :data_curation,
            3 =>  :formal_analysis,
            4 =>  :funding_acquisition,
            5 =>  :investigation,
            6 =>  :methodology,
            7 =>  :project_administration,
            8 =>  :resources,
            9 =>  :software,
            10 => :supervision,
            11 => :validation,
            12 => :visualization,
            13 => :writing_original_draft,
            14 => :writing_review_editing,
            column: "roles"

  private

  def name_or_email_presence
    if name.blank? && email.blank?
      errors.add(:name, _("can't be blank if no email is provided"))
      errors.add(:email, _("can't be blank if no name is provided"))
    end
  end

end
