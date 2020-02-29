# frozen_string_literal: true

# locals: identifier

presenter = Api::IdentifierPresenter.new(identifier: identifier)

json.type identifier.identifier_scheme.name.downcase
json.identifier presenter.identifier
