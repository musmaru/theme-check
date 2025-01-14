# frozen_string_literal: true
require "test_helper"

class CorrectorTest < Minitest::Test
  def setup
    @contents = <<~END
      <p>
        {{1 + 2}}
        {%
          include
          "foo"
        %}
      </p>
    END
    @theme = make_theme("templates/index.liquid" => @contents)
    @theme_file = @theme["templates/index"]
  end

  def test_insert_after_adds_suffix
    node = stub(
      theme_file: @theme_file,
      start_index: @contents.index('1'),
      end_index: @contents.index('2') + 1,
    )
    corrector = ThemeCheck::Corrector.new(theme_file: @theme_file)
    corrector.insert_after(node, " ")
    @theme_file.write
    assert_equal("{{1 + 2 }}", @theme_file.source_excerpt(2))
  end

  def test_insert_before_adds_prefix
    node = stub(
      theme_file: @theme_file,
      start_index: @contents.index('1'),
      end_index: @contents.index('2') + 1,
    )
    corrector = ThemeCheck::Corrector.new(theme_file: @theme_file)
    corrector.insert_before(node, " ")
    @theme_file.write
    assert_equal("{{ 1 + 2}}", @theme_file.source_excerpt(2))
  end

  def test_replace_replaces_markup
    node = stub(
      theme_file: @theme_file,
      start_index: @contents.index('1'),
      end_index: @contents.index('2') + 1,
      :markup= => ()
    )
    corrector = ThemeCheck::Corrector.new(theme_file: @theme_file)
    corrector.replace(node, "3 + 4")
    @theme_file.write
    assert_equal("{{3 + 4}}", @theme_file.source_excerpt(2))
  end

  def test_wrap_adds_prefix_and_suffix
    node = stub(
      theme_file: @theme_file,
      start_index: @contents.index('1'),
      end_index: @contents.index('2') + 1,
      :markup= => ()
    )
    corrector = ThemeCheck::Corrector.new(theme_file: @theme_file)
    corrector.wrap(node, "a", "b")
    @theme_file.write
    assert_equal("{{a1 + 2b}}", @theme_file.source_excerpt(2))
  end

  def test_handles_multiple_updates_properly
    node = stub(
      theme_file: @theme_file,
      start_index: @contents.index('1'),
      end_index: @contents.index('2') + 1,
    )
    corrector = ThemeCheck::Corrector.new(theme_file: @theme_file)
    corrector.wrap(node, "a", "b")
    corrector.insert_before(node, " ")
    corrector.insert_after(node, " ")
    @theme_file.write
    assert_equal("{{ a1 + 2b }}", @theme_file.source_excerpt(2))
  end

  def test_handles_multiline_updates
    node = stub(
      theme_file: @theme_file,
      start_index: @contents.index('{%') + 2,
      end_index: @contents.index('%}'),
      :markup= => ()
    )
    corrector = ThemeCheck::Corrector.new(theme_file: @theme_file)
    corrector.replace(node, "\n    render\n    'foo',\n    product: product\n  ")
    @theme_file.write
    assert_equal(<<~UPDATED_SOURCE, @theme_file.source)
      <p>
        {{1 + 2}}
        {%
          render
          'foo',
          product: product
        %}
      </p>
    UPDATED_SOURCE
  end
end
