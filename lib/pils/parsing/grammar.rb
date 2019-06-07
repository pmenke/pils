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
    class Grammar

      attr_accessor :starting_cats
      attr_accessor :rules

      def initialize()
        @rules = []
        @starting_cats = []
      end

      def expandible?(cat)
        !@rules.find{|r| r.expandible?(cat)}.nil?
      end

      def expand(cat)
        @rules.select{|r| r.expandible?(cat)}
      end
      
      def describe_rules 
        @rules.each do |rule|
          Pils::log rule.display
        end
      end

    end
  end
end

