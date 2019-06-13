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
    class Lexicon

      attr_accessor :entries
      attr_accessor :definite_articles

      def initialize
        @entries = Set.new
        @definite_articles = [
            'der', 'des', 'dem', 'den', 'die', 'der', 'den', 'die',
            'die', 'der', 'der', 'die', 'die', 'der', 'den', 'die',
            'das', 'des', 'dem', 'das', 'die', 'der', 'den', 'die'
        ]
        @indefinite_articles = [
            'ein',  'eines', 'einem', 'einen', '', '', '', '',
            'eine', 'einer', 'einer', 'eine',  '', '', '', '',
            'ein',  'eines', 'einem', 'ein',   '', '', '', ''
        ]
      end

      def definite_article(kase=:nom, number=:sg, gender=:m)
        pos = 0
        pos = 8 if gender==:f
        pos = 16 if gender==:n
        pos = pos + 4 if number==:pl
        pos = pos + 1 if kase==:gen
        pos = pos + 2 if kase==:dat
        pos = pos + 3 if kase==:acc
        @definite_articles[pos]
      end

      def indefinite_article(kase=:nom, number=:sg, gender=:m)
        pos = 0
        pos = 8 if gender==:f
        pos = 16 if gender==:n
        pos = pos + 4 if number==:pl
        pos = pos + 1 if kase==:gen
        pos = pos + 2 if kase==:dat
        pos = pos + 3 if kase==:acc
        @indefinite_articles[pos]
      end


      def add_wordform(new_form)
        @entries << new_form
      end


      def get(params={})
        temp = @entries
        # Pils::log ">>>> " +  temp.to_a.collect{|a| ("%s(%s)" % [a.form,a.cat])}.join(', ')
        return {} if (temp.empty? || params[:form] =~ /^\s*$/ )
        if params.has_key?(:form) && !(params[:form].nil?)
          # Pils::log "§FORM"
          # temp.each do |t|
          #   puts t
          #   puts t.form
          # end
          # puts params[:form]
          temp = temp.select{|t| !(t.form.nil?) && t.form.downcase==params[:form].downcase}
        end
        if params.has_key?(:cat) && !(params[:cat].nil?)
          # Pils::log "§CAT"
          temp = temp.select{|t| t.cat==params[:cat]}
        end
        if params.has_key?(:grammar)
          g = Pils::Structures::Avm.new(params[:grammar])
          temp = temp.select{|t| g < t.grammar}
        end
        temp
      end


      def describe
        @entries.each do |entry|
          Pils::log "// %s" % [entry.display.to_s]
        end
      end

    end
  end
end
