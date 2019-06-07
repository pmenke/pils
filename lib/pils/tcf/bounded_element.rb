# encoding: utf-8
#
# (c) 2019 Peter Menke
#
# This file is part of pils
# ("Programming in linguistic seminars").
#
# pils is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# pils is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with pils.  If not, see <http://www.gnu.org/licenses/>.

module Pils
  module Tcf

    class BoundedElement

      attr_accessor :begin_index
      attr_accessor :end_index


      def boundaries=(new_boundaries)
        @begin_index=new_boundaries.first
        @end_index=new_boundaries.last
      end

      def boundaries?
        @begin_index && @end_index
      end

      def length
        end_index - begin_index
      end

    end
  end

end
