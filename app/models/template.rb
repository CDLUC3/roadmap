class Template < ActiveRecord::Base
  include GlobalHelpers
  include ActiveModel::Validations
  include TemplateScope
  validates_with TemplateLinksValidator

  before_validation :set_defaults 

  # Stores links as an JSON object: { funder: [{"link":"www.example.com","text":"foo"}, ...], sample_plan: [{"link":"www.example.com","text":"foo"}, ...]}
  # The links is validated against custom validator allocated at validators/template_links_validator.rb
  serialize :links, JSON
  
  ##
  # Associations
  belongs_to :org
  has_many :plans
  has_many :phases, dependent: :destroy
  has_many :sections, through: :phases
  has_many :questions, through: :sections

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :id, :org_id, :description, :published, :title, :locale, :customization_of,
                  :is_default, :guidance_group_ids, :org, :plans, :phases, :family_id,
                  :archived, :version, :visibility, :published, :links, :as => [:default, :admin]

  # A standard template should be organisationally visible. Funder templates that are 
  # meant for external use will be publicly visible. This allows a funder to create 'funder' as
  # well as organisational templates. The default template should also always be publicly_visible
  enum visibility: [:organisationally_visible, :publicly_visible]

  # defines the export setting for a template object
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  validates :org, :title, presence: {message: _("can't be blank")}

  # Class methods gets defined within this 
  class << self
    def current(family_id)
      unarchived.where(family_id: family_id).order(version: :desc).first
    end
    def live(family_id)
      if family_id.respond_to?(:each)
        unarchived.where(family_id: family_id, published: true)
      else
        unarchived.where(family_id: family_id, published: true).first
      end
    end
    def default
      unarchived.where(is_default: true, published: true).order(:version).last
    end
  end


  # Returns whether or not this is the latest version of the current template's family
  def is_latest?
    return (self.id == Template.latest_version(self.family_id).pluck(:id).first)
  end

  # Returns a new unpublished copy of self with a new family_id, version = zero for the specified org
  def generate_copy(org)
    template = deep_copy(modifiable: true, version: 0, published: false, save: true)
    template.update!({
      family_id: new_family_id,
      org: org,
      is_default: false,
      title: _('Copy of %{template}') % { template: template.title }
    })
    return template
  end

  # Generates a new copy of self with an incremented version number
  def generate_version
    raise _('generate_version requires a published template') unless published
    template = deep_copy(version: self.version+1, published: false, save: true)
    return template
  end

  # Generates a new copy of self for the specified customizing_org
  def customize(customizing_org)
    raise _('customize requires an organisation target') unless customizing_org.is_a?(Org) # Assume customizing_org is persisted
    raise _('customize requires a template from a funder') unless org.funder_only? # Assume self has org associated
    customization = deep_copy(modifiable: false, version: 0, published: false, save: true)
    customization.update!({
      family_id: new_family_id,
      customization_of: self.family_id,
      org: customizing_org,
      visibility: Template.visibilities[:organisationally_visible],
      is_default: false
    })
    return customization
  end
  
  # Generates a new copy of self including latest changes from the funder this template is customized_of
  def upgrade_customization
    raise _('upgrade_customization requires a customised template') unless customization_of.present?
    source = self
    source = deep_copy(version: self.version+1, published: false) # preserves modifiable flags from the self template copied
    # Creates a new customisation for the published template whose family_id is self.customization_of
    customization = Template.published(self.customization_of).first.customize(self.org)
    # Sorts the phases from the source template, i.e. self
    sorted_phases = source.phases.sort{ |phase1,phase2| phase1.number <=> phase2.number }
    # Merges modifiable sections or questions from source into customization template object
    customization.phases.each do |customization_phase|
      # Search for the phase in the source template whose number matches the customization_phase
      candidate_phase = sorted_phases.bsearch{ |phase| customization_phase.number <=> phase.number }
      if candidate_phase.present? # The funder could have added this new phase after the customisation took place
        # Selects modifiable sections from the candidate_phase
        modifiable_sections = candidate_phase.sections.select{ |section| section.modifiable }
        # Attaches modifiable sections into the customization_phase
        modifiable_sections.each{ |modifiable_section| customization_phase.sections << modifiable_section }
        # Sorts the sections for the customization_phase
        sorted_sections = customization_phase.sections.sort{ |section1, section2| section1.number <=> section2.number }
        # Selects unmodifiable sections from the candidate_phase
        unmodifiable_sections = candidate_phase.sections.select{ |section| !section.modifiable }
        unmodifiable_sections.each do |unmodifiable_section|
          # Search for modifiable questions within the unmodifiable_section from candidate_phase
          modifiable_questions = unmodifiable_section.questions.select{ |question| question.modifiable }
          customization_section = sorted_sections.bsearch{ |section| unmodifiable_section.number <=> section.number }
          if customization_section.present? # The funder could have deleted the section
            modifiable_questions.each{ |modifiable_question| customization_section.questions << modifiable_question; }
          end
          # Search for unmodifiable questions within the unmodifiable_section in case source template added annotations
          unmodifiable_questions = unmodifiable_section.questions.select{ |question| !question.modifiable }
          sorted_questions = customization_section.questions.sort{ |question1, question2| question1.number <=> question2.number }
          unmodifiable_questions.each do |unmodifiable_question|
            customization_question = sorted_questions.bsearch{ |question| unmodifiable_question.number <=> question.number }
            if customization_question.present?  # The funder could have deleted the question
              annotations_added_by_customiser = unmodifiable_question.annotations.select{ |annotation| annotation.org_id == source.org_id }
              annotations_added_by_customiser.each{ |annotation| customization_question.annotations << annotation }
            end
          end
        end
      end
    end
    # Appends the modifiable phases from source
    source.phases.select{ |phase| phase.modifiable }.each{ |modifiable_phase| customization.phases << modifiable_phase }
    # Sets template properties to those from source template
    customization.version = source.version
    customization.family_id = source.family_id
    return customization
  end

  ##
  # convert the given template to a hash and return with all it's associations
  # to use, please pre-fetch org, phases, section, questions, annotations,
  #   question_options, question_formats,
  # TODO: Themes & guidance?
  #
  # @return [hash] hash of template, phases, sections, questions, question_options, annotations
  def to_hash
    hash = {}
    hash[:template] = {}
    hash[:template][:data] = self
    hash[:template][:org] = self.org
    phases = {}
    hash[:template][:phases] = phases
    self.phases.each do |phase|
      phases[phase.number] = {}
      phases[phase.number][:data] = phase
      phases[phase.number][:sections] = {}
      phase.sections.each do |section|
        phases[phase.number][:sections][section.number] = {}
        phases[phase.number][:sections][section.number][:data] = section
        phases[phase.number][:sections][section.number][:questions] = {}
        section.questions.each do |question|
          phases[phase.number][:sections][section.number][:questions][question.number] = {}
          phases[phase.number][:sections][section.number][:questions][question.number][:data] = question
          phases[phase.number][:sections][section.number][:questions][question.number][:annotations] = {}
          question.annotations.each do |annotation|
            phases[phase.number][:sections][section.number][:questions][question.number][:annotations][annotation.id] = {}
            phases[phase.number][:sections][section.number][:questions][question.number][:annotations][annotation.id][:data] = annotation
          end
          phases[phase.number][:sections][section.number][:questions][question.number][:question_options] = {}
          question.question_options.each do |question_option|
            phases[phase.number][:sections][section.number][:questions][question.number][:question_options][:data] = question_option
            phases[phase.number][:sections][section.number][:questions][question.number][:question_format] = question.question_format
          end
        end
      end
    end
    return hash
  end

  # TODO: Determine if this should be in the controller/views instead of the model
  def template_type
    self.customization_of.present? ? _('customisation') : _('template')
  end

  # Retrieves the template's org or the org of the template this one is derived
  # from of it is a customization
  def base_org
    if self.customization_of.present?
      return Template.where(family_id: self.customization_of).first.org
    else
      return self.org
    end
  end

  private
  # Generate a new random family identifier
  def new_family_id
    family_id = loop do
      random = rand 2147483647
      break random unless Template.exists?(family_id: random)
    end
    family_id
  end

  # Creates a copy of the current template
  # raises ActiveRecord::RecordInvalid when save option is true and validations fails
  def deep_copy(**options)
    copy = self.dup
    copy.version = options.fetch(:version, self.version)
    copy.published = options.fetch(:published, self.published)
    copy.save! if options.fetch(:save, false)
    self.phases.each{ |phase| copy.phases << phase.deep_copy(options) }
    return copy
  end
  
  # Default values to set before running any validation
  def set_defaults
    self.published ||= false
    self.archived ||= false
    self.is_default ||= false
    self.version ||= 0
    self.visibility = (org.present? && org.funder_only?) ? Template.visibilities[:publicly_visible] : Template.visibilities[:organisationally_visible]
    self.customization_of ||= nil
    self.family_id ||= new_family_id
    self.archived ||= false
    self.links ||= { funder: [], sample_plan: [] }
  end
end
