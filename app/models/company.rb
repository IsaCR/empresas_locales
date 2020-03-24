class Company < ApplicationRecord
  validates :name, :url, :description, presence: true

  has_and_belongs_to_many :categories
  has_and_belongs_to_many :deliveries

  filterrific(
      default_filter_params: { sorted_by: "name_asc" },
      available_filters: [
          :sorted_by,
          :search_query,
          :with_category_is,
          :with_delivery_is,
      ],
      )

  scope :search_query, ->(query) {
    return nil  if query.blank?

    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 2
    where(
        terms.map {
          or_clauses = [
              "LOWER(companies.name) LIKE ?",
              "LOWER(companies.description) LIKE ?"
          ].join(' OR ')
          "(#{ or_clauses })"
        }.join(' AND '),
        *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :with_category_is, ->(category_ids) {
    joins(:categories).where( 'categories.id' => [*category_ids])
  }

  scope :with_delivery_is, ->(delivery_ids) {
    joins(:deliveries).where( 'deliveries.id' => [*delivery_ids])
  }

  scope :sorted_by, ->(sort_key) {
    # extract the sort direction from the param value.

    direction = (sort_key =~ /desc$/) ? 'desc' : 'asc'
    companies = Company.arel_table
    categories = Category.arel_table
    deliveries = Delivery.arel_table
    case sort_key.to_s
    when /^category_name_/
      Company.joins(:categories).order(categories[:name].lower.send(direction)).order(companies[:name].lower.send(direction))
    when /^delivery_name_/
      Company.joins(:deliveries).order(deliveries[:name].lower.send(direction)).order(companies[:name].lower.send(direction))
    when /^name_/
      order(companies[:name].lower.send(direction))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_key.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
        ["Name (a-z)", "name_asc"],
        ["Category (a-z)", "category_name_asc"],
        ["Delivery (a-z)", "delivery_name_asc"],
    ]
  end
end
