# This file is part of Pils.
#
#     Pils is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as
#     published by the Free Software Foundation, either version 3 of
#     the License, or (at your option) any later version.
#
#     Pils is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
#
#     You should have received a copy of the
#     GNU Lesser General Public License along with Pils.
#     If not, see <http://www.gnu.org/licenses/>.

module Pils
  module Parsing
    class Rule
      attr_accessor :grammar
      attr_accessor :left
      attr_accessor :right


      def initialize(new_left, new_right, new_grammar={})
        @left  = new_left
        @right = new_right
        @grammar = new_grammar
      end

      def expandible?(cat)
        cat < @left
      end

      def display
        "%s -> %s" % [left.display, right.collect{|r| r.display}.join(' ')]
      end
    end
  end
end



