# frozen_string_literal: true
# Note: Everything is 0-indexed here.

module ThemeCheck
  module PositionHelper
    def from_row_column_to_index(content, row, col)
      return 0 unless content.is_a?(String) && !content.empty?
      return 0 unless row.is_a?(Integer) && col.is_a?(Integer)
      i = 0
      safe_row = bounded(0, row, content.count("\n"))
      scanner = StringScanner.new(content)
      scanner.scan_until(/\n/) while i < safe_row && (i += 1)
      result = scanner.charpos || 0
      scanner.scan_until(/\n|\z/)
      bounded(result, result + col, scanner.pre_match.size)
    end

    def from_index_to_row_column(content, index)
      return [0, 0] unless content.is_a?(String) && !content.empty?
      return [0, 0] unless index.is_a?(Integer)
      safe_index = bounded(0, index, content.size - 1)
      content_up_to_index = content[0...safe_index]
      row = content_up_to_index.count("\n")
      col = 0
      col += 1 while (safe_index -= 1) && safe_index >= 0 && content[safe_index] != "\n"
      [row, col]
    end

    def bounded(a, x, b)
      return a if x < a
      return b if x > b
      x
    end
  end
end
