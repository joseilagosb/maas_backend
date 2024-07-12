RSpec::Matchers.define :equal_serialized do |expected|
  match do |actual|
    if actual.kind_of?(Array)
      expect(actual.length).to eq(expected.length)
      actual.each_with_index do |parsed_element, element_index|
        parsed_element.attributes.each do |key|
          expect(parsed_element[key]).to eq(expected[element_index]["attributes"][key])
        end
      end
    else
      actual.attributes.each do |key|
        expect(actual[key]).to eq(expected["attributes"][key])
      end
    end
  end

  description do
    "expected #{actual} to equal jsonapi_serializer object #{expected}"
  end
end