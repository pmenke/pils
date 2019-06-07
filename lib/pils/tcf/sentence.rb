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

    class Sentence < BoundedElement

      attr_accessor :tokens
      attr_accessor :previous_sentence
      attr_accessor :next_sentence

      def initialize(tcf_document, xml_element)
        @tcf_document = tcf_document
        @xml_element = xml_element
        @tokens = []
        @previous_sentence, @next_sentence = nil
      end

      def token_length
        @tokens.size
      end

      def character_length
        @tokens.collect{|token| token.length}.sum
      end

    end
  end
end
