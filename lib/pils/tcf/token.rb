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

    class Token < BoundedElement

      attr_accessor :pos
      attr_accessor :lemma
      attr_accessor :previous_token
      attr_accessor :next_token

      def initialize(tcf_document, xml_element)
        @tcf_document = tcf_document
        @xml_element = xml_element
        @pos, @lemma, @previous_token, @next_token = nil
      end

      def form
        @form ||= CGI.unescapeHTML(@xml_element.text)
      end

      def pos?
        not pos.nil?
      end

      def lemma?
        not lemma.nil?
      end

    end

  end
end