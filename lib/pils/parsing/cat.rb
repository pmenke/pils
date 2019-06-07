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
    class Cat
      attr_accessor :grammar
      attr_accessor :rule
      attr_accessor :cat
      attr_accessor :feat
      attr_accessor :descriptor


      def initialize(new_cat, new_desc = nil, new_feat={})
        @cat = new_cat
        @descriptor = new_desc
        @feat = Pils::Structures::Avm.new()
        new_feat.each do |k,v|
          @feat[k] = v
        end
      end

      # true if the grammar lets you expand this symbol
      # def expandible?()
      #   grammar.rules.each do |r|
      #     return true if self < r.left
      #   end#
      # end

      # true if this cat matches other one.
      def <(other)
        return false if self.cat != other.cat
        return self.feat < other.feat
      end

      def display
        "%s" % [cat.to_s, feat.values.collect{|v| v.to_s}.join(',')]
      end

      def to_s
        self.display
      end

    end
  end
end


