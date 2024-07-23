require 'active_support/inflector'

# Compara cada atributo del objeto serializado con el del objeto esperado
# Permite revisar un solo objeto o un listado de ellos

# Actual: JSONAPI::SerializableResource (un objeto json con attributes)
# Expected: ActiveRecord::Associations::CollectionProxy o Array
RSpec::Matchers.define :serialized_equals do |expected|
  match do |actual|
    data = actual['data']
    if expected.is_a?(Array) || expected.is_a?(ActiveRecord::Associations::CollectionProxy)
      if data.is_a?(Array)
        expect(data.length).to eq(expected.length)
        data.each_with_index do |element, element_index|
          element['attributes'].each_key do |key|
            expect(element['attributes'][key]).to eq(expected[element_index][key])
          end
        end
      end
    else
      data['attributes'].each do |key|
        expect(data[key]).to eq(expected.attributes[key])
      end
    end

    if actual.key?(:included)
      relationships = expected.class.reflections.map { |r| r.first.to_s }
      expect(relationships).to eq(actual[:data][:relationships].keys)

      relationship_types = actual[:data][:relationships].each_with_object({}) do |(_, value), memo|
        if value[:data].is_a?(Array)
          relationship_name = value[:data].first[:type]
          relationship_variable = relationship_name.pluralize
        else
          relationship_name = value[:data][:type]
          relationship_variable = relationship_name
        end
        memo[relationship_name] = relationship_variable
        memo
      end

      relationship_types.each do |key, value|
        expected_elements = expected.send(value)
        included_elements = actual[:included].select { |included_element| included_element['type'] == key }

        included_elements.each do |included_element|
          expected_element = expected_elements.find_by(id: included_element['id'])
          included_element['attributes'].each do |attribute_key, attribute_value|
            expect(attribute_value).to eq(expected_element.attributes[attribute_key])
          end
        end
      end
    else
      assert(true)
    end
  end

  description do
    "expected #{actual} to equal jsonapi_serializer object #{expected}"
  end
end
