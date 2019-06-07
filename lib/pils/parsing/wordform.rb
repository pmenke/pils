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
    class Wordform

      attr_accessor :form
      attr_accessor :cat
      attr_accessor :grammar
      attr_accessor :semantics

      def initialize(new_form, new_cat, new_grammar={}, new_semantics={})
        @form = new_form
        if new_cat.kind_of?(Cat)
          @cat = new_cat.cat
        else
          @cat = new_cat
        end
        
        @grammar = Pils::Structures::Avm.new(new_grammar)
        @semantics = Pils::Structures::Avm.new(new_semantics)

      end

      def display()
        "#{@form}/#{@cat.to_s}/#{@semantics.to_s}"
      end
    end
  end
end
