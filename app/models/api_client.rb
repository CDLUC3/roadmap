# frozen_string_literal: true

# == Schema Information
#
# Table name: api_clients
#
#  id             :integer          not null, primary key
#  name           :string,          not null
#  contact_email  :string,          not null
#  client_id      :string,          not null
#  client_secret  :string,          not null
#  last_access    :datetime
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_api_clients_on_name     (name)
#

class ApiClient < ActiveRecord::Base

  include ValidationMessages

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { case_sensitive: false,
                                 message: UNIQUENESS_MESSAGE }

  validates :contact_email, presence: { message: PRESENCE_MESSAGE },
                            email: { allow_nil: false }

  validates :client_id, presence: { message: PRESENCE_MESSAGE }
  validates :client_secret, presence: { message: PRESENCE_MESSAGE }

  # ===========================
  # = Public instance methods =
  # ===========================

  # Override the to_s method to keep the id and secret hidden
  def to_s
    name
  end

  def authenticate(secret:)
    client_secret == secret
  end

end
