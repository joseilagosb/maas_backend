# Compara cada atributo del objeto serializado con el del objeto esperado
# Permite revisar un solo objeto o un listado de ellos

# Actual: JSONAPI::SerializableResource (un objeto json con attributes)
# Expected: ActiveRecord::Associations::CollectionProxy o Array
RSpec::Matchers.define :serialized_equals do |expected|
  match do |actual|
    if expected.kind_of?(Array) || expected.kind_of?(ActiveRecord::Associations::CollectionProxy)
      if actual.kind_of?(Array)
        expect(actual.length).to eq(expected.length)
        actual.each_with_index do |element, element_index|
          element["attributes"].each do |key, value|
            if expected.kind_of?(Array)
              expect(element["attributes"][key]).to eq(expected[element_index][key])
            elsif expected.kind_of?(ActiveRecord::Associations::CollectionProxy)
              expect(element["attributes"][key]).to eq(expected[element_index][key])
            end
          end
        end
      end
    else
      actual["attributes"].each do |key|
        expect(actual[key]).to eq(expected.attributes[key]) 
      end
    end
  end

  description do
    "expected #{actual} to equal jsonapi_serializer object #{expected}"
  end
end