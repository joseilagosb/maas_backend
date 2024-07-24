require 'active_support/inflector'

# Compara cada atributo del objeto serializado con el del objeto esperado
# * Permite revisar un solo objeto o un listado de ellos.
# * Permite revisar el modelo principal como también las relaciones incluidas (las relaciones se revisarán
# desde el punto de vista del objeto ActiveRecord, es decir, la query debe incluir dichas relationships).

# Actual: JSONAPI::SerializableResource (un objeto json serializado con data, included)
# Expected: ActiveRecord::Associations::CollectionProxy o Array

# -------------------------------------------------------------------------------------------------------------

# ESTRUCTURA DEL OBJETO SERIALIZADO

# [data]: Hash de atributos (attributes) del modelo consultado y relaciones (relationships) incluidas mediante
# el parámetro include

# [included]: Array de hashes con todos los resultados de las relaciones incluidas. Para acceder a los resultados de
# cada modelo por separado hay que filtrar por su type previamente.
# Cada resultado es un hash de atributos de estructura similar a [data] pero cuyo tipo es un modelo asociado al
# modelo principal. Tiene attributes y relationships.

# -------------------------------------------------------------------------------------------------------------

RSpec::Matchers.define :serialized_equals do |expected|
  match do |actual|
    data = actual['data']
    if expected.is_a?(Array) || expected.is_a?(ActiveRecord::Associations::CollectionProxy)
      # Expected es una colección de records o un array de POROs
      # Se itera primero sobre cada elemento del listado de elementos en el [data] del JSON, y luego sobre cada
      # uno de sus atributos
      expect(data.length).to eq(expected.length)
      data.each_with_index do |element, element_index|
        element['attributes'].each_key do |key|
          expect(element['attributes'][key]).to eq(expected[element_index][key])
        end
      end
    else
      # Expected es un solo elemento de ActiveRecord, se itera sobre los atributos del JSON
      data['attributes'].each do |key|
        expect(data[key]).to eq(expected.attributes[key])
      end
    end

    if actual.key?(:included)
      # Si tiene un atributo included, se trata de un serializable que incluye relaciones

      # Extraemos primero las relaciones del objeto ActiveRecord (aquí se asume que fueron incluidos mediante 
      # eager loading) y las comparamos con las relationships del JSON
      relationships = expected.class.reflections.map { |r| r.first.to_s }
      expect(relationships).to eq(actual[:data][:relationships].keys)

      # Creamos un hash de tipos de relación
      # Para cada elemento del hash: la 'key' es el nombre del 'type' del elemento en el [relationships] del JSON,
      # y el 'value' es el nombre que se espera en la instancia de ActiveRecord
      # (Si es un array, se asume que es una relación de tipo 'has_many', por lo tanto el 'value' va en plural,
      # de lo contrario irá en singular)
      relationship_types = actual[:data][:relationships].each_with_object({}) do |(_, value), acc|
        if value[:data].is_a?(Array)
          relationship_name = value[:data].first[:type]
          relationship_variable = relationship_name.pluralize
        else
          relationship_name = value[:data][:type]
          relationship_variable = relationship_name
        end
        acc[relationship_name] = relationship_variable
        acc
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
