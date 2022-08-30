# frozen_string_literal: true

require "test_helper"
require "jbuilder/schema/template"
require "jbuilder/schema/handler"

class TemplateTest < ActiveSupport::TestCase

  test "user fields" do
    assert_equal({type: :integer}, json.integer(1))
    assert_equal({type: :number}, json.number(1.5))
    assert_equal({type: :number}, json.big_decimal(BigDecimal("1.5", 1)))
    assert_equal({type: :string}, json.string("String"))
    assert_equal({type: :string}, json.nil_method(nil))
    assert_equal({type: :string, format: "date-time"}, json.time(DateTime.new(2012, 12, 01)))
    assert_equal({type: :string, format: "date-time"}, json.time_with_zone(ActiveSupport::TimeWithZone.new(Time.now, ActiveSupport::TimeZone.all.sample)))
    assert_equal({type: :boolean}, json.true_method(true))
    assert_equal({type: :boolean}, json.false_method(false))
    assert_equal({type: :array, contains: {type: :string}, minContains: 0}.as_json, json.string_array(%w[a b c d]).as_json)
    assert_equal({type: :array, contains: {type: %i[string integer number boolean]}, minContains: 0}.as_json, json.multitype_array(['a', 1, 1.5, false]).as_json)
  end

  test "blocks" do
    hash = { name: "David" }

    # block = ->{ json.id 123; json.merge!(hash) }
    assert_equal({type: :string}, json.author { json.id 123; json.merge!(hash) })
  end

  test "collections" do
    articles = FactoryBot.create_list(:article, 3)
    assert_equal({id: {type: :integer}, title: {type: :string}}, json.articles(articles, :id, :title))
    assert_equal({type: :array, items: { id: { type: :integer },
                                         title: {type: :string},
                                         body: {type: :string},
                                         created_at: {type: :string, format: "date-time"},
                                         updated_at: {type: :string, format: "date-time"},
                                         user_id: {type: :integer}}},
                 json.articles(articles))
  end

  test "jbuilder methods" do

    assert_equal({type: :string}, json.set!(:name, "David"))
    assert_equal({"$ref" => "#/components/schemas/article"}, json.partial!('articles/article', collection: [1, 2, 3], as: :article))
  end

  test "schematize type" do
    assert_equal({type: :integer}, json.send(:_schema, 1))
    assert_equal({type: :number}, json.send(:_schema, 1.5))
    assert_equal({type: :number}, json.send(:_schema, BigDecimal("1.5", 1)))
    assert_equal({type: :string}, json.send(:_schema, "String"))
    assert_equal({type: :string}, json.send(:_schema, nil))
    assert_equal({type: :string, format: "date-time"}, json.send(:_schema, DateTime.new(2012, 12, 01)))
    assert_equal({type: :string, format: "date-time"}, json.send(:_schema, ActiveSupport::TimeWithZone.new(Time.now, ActiveSupport::TimeZone.all.sample)))
    assert_equal({type: :boolean}, json.send(:_schema, true))
    assert_equal({type: :boolean}, json.send(:_schema, false))
    assert_equal({type: :array, contains: {type: :string}, minContains: 0}.as_json, json.send(:_schema, %w[a b c d]).as_json)
    assert_equal({type: :array, contains: {type: %i[string integer number boolean]}, minContains: 0}.as_json, json.send(:_get_type, ['a', 1, 1.5, false]).as_json)
  end

  private

  def json
    JbuilderSchema::Template.new(JbuilderSchema::Handler)
  end
end
