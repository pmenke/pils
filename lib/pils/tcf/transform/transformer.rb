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
    module Transform

      class Transformer


        def self.encode_pos(pos)
          replacements = {
              ','  => '_COMMA',
              '.'  => '_FULLSTOP',
              ':'  => '_COLON',
              '('  => '_LPAREN',
              ')'  => '_RPAREN',
              '``' => 'QUOT',
          }
          return pos if pos =~ /\w+/
          # else: return word description of the pos.
          if replacements.has_key?(pos)
            return replacements[pos]
          end
          return pos
        end

        def initialize(tcf_doc, rdf_opts)
          @tcf_doc = tcf_doc
          @rdf_opts = rdf_opts
          @uri_base = rdf_opts[:base_uri] if rdf_opts.has_key?(:base_uri)

          if rdf_opts.has_key?(:tagger_label)
            @tagger_label = rdf_opts[:tagger_label]
          else
            @tagger_label = nil
          end

          if rdf_opts.has_key?(:tagger_uri)
            @tagger_uri = rdf_opts[:tagger_uri]
          else
            @tagger_uri = nil
          end

        end


        def char_uri(base, from,to)
          RDF::URI("#{base}#char=#{from},#{to}")
        end

        def twopart_uri(base, suffix)
          RDF::URI("#{base}##{suffix}")
        end

        def transform(mode = :plain)
          return transform_plain       if mode == :plain
          return transform_noprov      if mode == :noprov
          return transform_modularized if mode == :modularized
        end

        def uri_base
          @uri_base || 'http://example.org/tcf2nif/example.txt'
        end

        def text_converter_uri
          RDF::URI('http://hdl.handle.net/11858/00-1778-0000-0004-BA56-7')
        end

        def tokenizer_uri
          # TODO make it possible to use a custom tokenizer

          RDF::URI('http://hdl.handle.net/11858/00-1778-0000-0004-BA56-7')
        end

        def pos_tagger_uri
          # TODO make it possible to use a custom tokenizer
          if @tagger_uri
            return RDF::URI(@tagger_uri)
          else
            return RDF::URI('http://hdl.handle.net/11858/00-247C-0000-0007-3739-5')
          end
        end

        def tokenization_activity_uri
          twopart_uri(uri_base, 'TokenizationActivity')
        end

        def pos_tagging_activity_uri
          # TODO make it possible to use a custom tokenizer
          if @tagger_label
            return twopart_uri(uri_base, "PosTaggingActivity#{@tagger_label}")
          else
            return twopart_uri(uri_base, 'PosTaggingActivity')
          end
        end

        def ne_tagging_activity_uri
          twopart_uri(uri_base, 'NeTaggingActivity')
        end

        def geo_tagging_activity_uri
          twopart_uri(uri_base, 'GeoTaggingActivity')
        end

        def dep_parsing_activity_uri
          twopart_uri(uri_base, 'DependencyParsingActivity')
        end

        def tokenization_activity_time
          RDF::Literal.new('2015-07-09T14:01:00', datatype: RDF::XSD.dateTime)
        end

        def pos_tagging_activity_time
          RDF::Literal.new('2015-07-09T14:02:00', datatype: RDF::XSD.dateTime)
        end

        def ne_tagging_activity_time
          RDF::Literal.new('2015-07-09T14:03:00', datatype: RDF::XSD.dateTime)
        end

        def geo_tagging_activity_time
          RDF::Literal.new('2015-07-09T14:04:00', datatype: RDF::XSD.dateTime)
        end

        def dep_parsing_activity_time
          RDF::Literal.new('2015-07-09T14:05:00', datatype: RDF::XSD.dateTime)
        end

        def transform_noprov(reify=false)
          graph = RDF::Graph.new

          # create a document URI for the document.
          context_uri = char_uri(uri_base, 0, '')

          # this generates a representation of the whole primary text
          graph << [ context_uri, RDF.type, NIF.String ]
          graph << [ context_uri, RDF.type, NIF.Context ]
          graph << [ context_uri, RDF.type, NIF.RFC5147String ]
          graph << [ context_uri, NIF.isString, RDF::Literal.new(@tcf_doc.text, lang: :en) ]
          graph << [ context_uri, NIF.beginIndex, RDF::Literal.new(0, datatype: RDF::XSD.nonNegativeInteger) ]
          graph << [ context_uri, NIF.endIndex,   RDF::Literal.new(@tcf_doc.text.length, datatype: RDF::XSD.nonNegativeInteger) ]

          # This generates a representation of the single tokens
          @tcf_doc.tokens.each_with_index do |token,i|
            token_uri = char_uri(uri_base, token.begin_index, token.end_index)
            graph << [ token_uri, NIF.referenceContext, context_uri ]
            graph << [ token_uri, RDF.type, NIF.String ]
            graph << [ token_uri, RDF.type, NIF.Word ]
            graph << [ token_uri, RDF.type, NIF.RFC5147String ]
            graph << [ token_uri, NIF.beginIndex, RDF::Literal.new(token.begin_index, datatype: RDF::XSD.nonNegativeInteger) ]
            graph << [ token_uri, NIF.endIndex, RDF::Literal.new(token.end_index, datatype: RDF::XSD.nonNegativeInteger) ]
            graph << [ token_uri, NIF.anchorOf, RDF::Literal.new(token.form, datatype: RDF::XSD.string) ]

            if token.previous_token
              graph << [ token_uri, NIF.previousWord, char_uri(uri_base, token.previous_token.begin_index, token.previous_token.end_index) ]
            end
            if token.next_token
              graph << [ token_uri, NIF.nextWord, char_uri(uri_base, token.next_token.begin_index, token.next_token.end_index) ]
            end

            # adds data about POS if this data is present
            if token.pos? #  && token.pos =~ /\w+/
              # TODO Tokens must be checked whether they contain strange characters!
              # Do this! COMMA, COLON, QUESTION_MARK
              nif_pos(token, i, reify).each do |trip|
                graph << trip
              end
            end
            # Adds data about lemma if this data is present
            if token.lemma?
              nif_lemma(token, i, reify).each do |trip|
                graph << trip #[ token_uri, NIF.lemma, RDF::Literal.new(token.lemma, datatype: RDF::XSD.string) ]
              end
            end
          end

                i = 0
          @tcf_doc.dependency_map.each do |key, value|
            dep = key.first
            gov = key.last
            i = i + 1
            if reify
              tok_uri  = char_uri(uri_base, dep.begin_index, dep.end_index)
              anno_uri = twopart_uri(uri_base, "Dep#{i}")
              graph << [tok_uri, NIF.annotation, anno_uri]
              graph << [anno_uri, NIF.dependency, char_uri(uri_base, gov.begin_index, gov.end_index)]
              graph << [anno_uri, NIF.dependencyRelationType, RDF::Literal.new(value)]
              graph << [anno_uri, PROV.wasGeneratedBy, dep_parsing_activity_uri]
              graph << [anno_uri, PROV.wasDerivedFrom, tok_uri]
              graph << [anno_uri, PROV.wasDerivedFrom, char_uri(uri_base, gov.begin_index, gov.end_index)]
              graph << [anno_uri, PROV.generatedAtTime, dep_parsing_activity_time]
            else
              graph << [char_uri(uri_base, dep.begin_index, dep.end_index), NIF.dependency, char_uri(uri_base, gov.begin_index, gov.end_index)]
              graph << [char_uri(uri_base, dep.begin_index, dep.end_index), NIF.dependencyRelationType, RDF::Literal.new(value)]
            end
          end

          return graph if reify

          # TODO add information about named entities
          # named entities
          # get all named entities from the corpus.
          # are they in there, anyway?
          @tcf_doc.named_entities.each_with_index do |ne,i|
            # generate a string for reference if more than one token is used.
            # else, use just the URI for that given token.
            current_uri = char_uri(uri_base, ne.tokens.first.begin_index, ne.tokens.first.end_index)
            if ne.tokens.size > 1
              # create a new string thing
              min_ind = ne.tokens.min{|t| t.begin_index}.begin_index
              max_ind = ne.tokens.max{|t| t.end_index}.end_index
              current_uri = char_uri(uri_base, min_ind, max_ind)
            end
            anno_uri = twopart_uri(uri_base, "ne#{i}")
            graph << [current_uri, NIF::annotation, anno_uri]
            graph << [anno_uri, RDF.type, NIF.String]
            # Pils::log '(%3i) %20s . %40s : %20s' % [ne.tokens.size, current_uri, ne.tokens.collect{|t| t.form}.join(' '), ne.category]
            graph << [anno_uri, NIF.taNerdCoreClassRef, NERD[ne.category.capitalize] ]
          end

          # TODO add information about geolocations
          @tcf_doc.geo_annotations.each_with_index do |geo,i|
            min_ind = geo.tokens.min{|t| t.begin_index}.begin_index
            max_ind = geo.tokens.max{|t| t.end_index}.end_index
            current_uri = char_uri(uri_base, min_ind, max_ind)
            graph << [current_uri, RDF.type, NIF.String]
            anno_uri = twopart_uri(uri_base, "geo#{i}")

            graph << [current_uri, NIF::annotation, anno_uri]
            graph << [anno_uri, Pils::Tcf::GEO.lat,  geo.lat]
            graph << [anno_uri, Pils::Tcf::GEO.long, geo.lon]
            graph << [anno_uri, Pils::Tcf::GEO.alt,  geo.alt]
            graph << [anno_uri, RDF::URI('http://example.org/tcf2nif/continent'), geo.continent]
          end

          # TODO add information about dependency trees

          graph

        end

        def transform_plain
          #Pils::log "1"
          graph = transform_noprov(true)
          #Pils::log "2"
          text_uri = char_uri(uri_base, 0, '')
          # add provenance info to some of the triples.
          # 1. add static Prov data for the tool chain.
          # 2. add provenance data for the TCF-formatted text.
          # 3. add provenance data for each token.
          #Pils::log "3"
          @tcf_doc.tokens.each do |token|
            token_uri = char_uri(uri_base, token.begin_index, token.end_index)
            graph << [token_uri, Pils::Tcf::PROV.wasGeneratedBy, tokenization_activity_uri]
            graph << [token_uri, Pils::Tcf::PROV.wasDerivedFrom, text_uri]
            graph << [token_uri, Pils::Tcf::PROV.generatedAtTime, tokenization_activity_time]
          end

          # add info to named entities
          #Pils::log "4"
          @tcf_doc.named_entities.each_with_index do |ne,i|
            #Pils::log " a"
            anno_uri = twopart_uri(uri_base, "ne#{i}")
            #Pils::log " b"
            graph << [anno_uri, Pils::Tcf::PROV.wasGeneratedBy, ne_tagging_activity_uri]
            #Pils::log " c"
            #Pils::log ne.tokens.size
            ne.tokens.each do |tok|
              #Pils::log tok.class.name
              #Pils::log tok.begin_index
              #Pils::log tok.end_index

              graph << [anno_uri, Pils::Tcf::PROV.wasDerivedFrom, char_uri(uri_base, tok.begin_index, tok.end_index)]
              graph << [char_uri(uri_base, tok.begin_index, tok.end_index), NIF.annotation, anno_uri]
            #Pils::log " d"
            end
            #Pils::log " e"
            graph << [anno_uri, Pils::Tcf::PROV.generatedAtTime, ne_tagging_activity_time]
          end
          #Pils::log "5"

          @tcf_doc.geo_annotations.each_with_index do |geo,i|
            anno_uri = twopart_uri(uri_base, "geo#{i}")
            graph << [anno_uri, Pils::Tcf::PROV.wasGeneratedBy, geo_tagging_activity_uri]
            geo.tokens.each do |tok|
              graph << [anno_uri, Pils::Tcf::PROV.wasDerivedFrom, char_uri(uri_base, tok.begin_index, tok.end_index)]
              graph << [char_uri(uri_base, tok.begin_index, tok.end_index), NIF.annotation, anno_uri]
            end
            graph << [anno_uri, Pils::Tcf::PROV.generatedAtTime, geo_tagging_activity_time]
          end
          graph
        end

        def transform_modularized()
          graph = RDF::Graph.new

          # create a document URI for the document.
          context_uri = char_uri(uri_base, 0, '')

          # generate the modules
          # ToDo: make this configurable! we certainly need
          #   custom URIs here. also, custom metadata.
          pri_module_uri = twopart_uri(uri_base, 'PrimaryTextModule')
          tok_module_uri = twopart_uri(uri_base, 'TokenizationModule')
          pos_module_uri = twopart_uri(uri_base, 'PosModule')
          lem_module_uri = twopart_uri(uri_base, 'LemmaModule')
          ner_module_uri = twopart_uri(uri_base, 'NeModule')
          geo_module_uri = twopart_uri(uri_base, 'GeoModule')
          dep_module_uri = twopart_uri(uri_base, 'DependencyModule')

          module_uris = [pri_module_uri, tok_module_uri, pos_module_uri, lem_module_uri]

          module_uris.each do |u|
            graph << [u, RDF.type, MOND.Module ]
            graph << [u, MOND.belongsToDocument, uri_base ]
          end

          graph << [ tok_module_uri, MOND.propagateType, NIF.String ]
          graph << [ tok_module_uri, MOND.propagateType, NIF.Word ]
          graph << [ tok_module_uri, MOND.propagateType, NIF.RFC5147String ]

          # this generates a representation of the whole primary text
          # put this into a separate module. Assign the module to the document.
          graph << [ context_uri, RDF.type, NIF.String ]
          graph << [ context_uri, RDF.type, NIF.Context ]
          graph << [ context_uri, RDF.type, NIF.RFC5147String ]
          graph << [ context_uri, NIF.isString, RDF::Literal.new(@tcf_doc.text, lang: :en) ]
          graph << [ context_uri, NIF.beginIndex, RDF::Literal.new(0, datatype: RDF::XSD.nonNegativeInteger) ]
          graph << [ context_uri, NIF.endIndex,   RDF::Literal.new(@tcf_doc.text.length, datatype: RDF::XSD.nonNegativeInteger) ]
          graph << [ context_uri, MOND.belongsToModule, pri_module_uri ]

          # This generates a representation of the single tokens
          poscounter = 1
          lemcounter = 1
          @tcf_doc.tokens.each_with_index do |token,i|
            token_uri = char_uri(uri_base, token.begin_index, token.end_index)
            graph << [ token_uri, NIF.referenceContext, context_uri ]
            graph << [ token_uri, NIF.beginIndex, RDF::Literal.new(token.begin_index, datatype: RDF::XSD.nonNegativeInteger) ]
            graph << [ token_uri, NIF.endIndex, RDF::Literal.new(token.end_index, datatype: RDF::XSD.nonNegativeInteger) ]
            graph << [ token_uri, NIF.anchorOf, RDF::Literal.new(token.form, datatype: RDF::XSD.string) ]
            if token.pos?
              pos = Transformer.encode_pos(token.pos)
              # pos = "QUOT" if pos == "``"
              graph << [ token_uri, NIF.annotation, twopart_uri(uri_base, "Pos#{poscounter}") ]
              graph << [ twopart_uri(uri_base, "Pos#{poscounter}"), NIF.oliaLink, Pils::Tcf::PENN[pos] ]
              graph << [ twopart_uri(uri_base, "Pos#{poscounter}"), MOND.belongsToModule, pos_module_uri ]
              poscounter = poscounter + 1
            end
            if token.lemma?
              graph << [ token_uri, NIF.annotation, twopart_uri(uri_base, "Lemma#{lemcounter}") ]
              graph << [ twopart_uri(uri_base, "Lemma#{lemcounter}"), NIF.lemma, RDF::Literal.new(token.lemma) ]
              graph << [ twopart_uri(uri_base, "Lemma#{lemcounter}"), MOND.belongsToModule, lem_module_uri ]
              lemcounter = lemcounter + 1
            end
            graph << [ token_uri, MOND.belongsToModule, tok_module_uri ]
          end

          @tcf_doc.named_entities.each_with_index do |ne,i|
            current_uri = char_uri(uri_base, ne.tokens.first.begin_index, ne.tokens.first.end_index)
            if ne.tokens.size > 1
              # create a new string thing
              min_ind = ne.tokens.min{|t| t.begin_index}.begin_index
              max_ind = ne.tokens.max{|t| t.end_index}.end_index
              current_uri = char_uri(uri_base, min_ind, max_ind)
            end
            anno_uri = twopart_uri(uri_base, "NE#{i}")
            graph << [current_uri, NIF::annotation, anno_uri]
            graph << [anno_uri, RDF.type, NIF.String]
            graph << [anno_uri, MOND.belongsToModule, ner_module_uri ]
            graph << [anno_uri, NIF.taNerdCoreClassRef, NERD[ne.category.capitalize] ]
          end

          @tcf_doc.geo_annotations.each_with_index do |geo,i|
            min_ind = geo.tokens.min{|t| t.begin_index}.begin_index
            max_ind = geo.tokens.max{|t| t.end_index}.end_index
            current_uri = char_uri(uri_base, min_ind, max_ind)
            graph << [current_uri, RDF.type, NIF.String]
            anno_uri = twopart_uri(uri_base, "Geo#{i}")

            graph << [current_uri, NIF::annotation, anno_uri]
            graph << [anno_uri, MOND.belongsToModule, geo_module_uri ]
            graph << [anno_uri, Pils::Tcf::GEO.lat,  geo.lat]
            graph << [anno_uri, Pils::Tcf::GEO.long, geo.lon]
            graph << [anno_uri, Pils::Tcf::GEO.alt,  geo.alt]
            graph << [anno_uri, RDF::URI('http://example.org/tcf2nif/continent'), geo.continent]
          end

          d = 0
          @tcf_doc.dependency_map.each do |key, value|
            dep = key.first
            gov = key.last
            d = d + 1
            tok_uri  = char_uri(uri_base, dep.begin_index, dep.end_index)
            anno_uri = twopart_uri(uri_base, "Dep#{d}")
            graph << [tok_uri, NIF.annotation, anno_uri]
            graph << [anno_uri, NIF.dependency, char_uri(uri_base, gov.begin_index, gov.end_index)]
            graph << [anno_uri, NIF.dependencyRelationType, RDF::Literal.new(value)]
            graph << [anno_uri, MOND.belongsToModule, dep_module_uri ]
            #graph << [anno_uri, PROV.wasGeneratedBy, dep_parsing_activity_uri]
            #graph << [anno_uri, PROV.wasDerivedFrom, tok_uri]
            #graph << [anno_uri, PROV.wasDerivedFrom, char_uri(uri_base, gov.begin_index, gov.end_index)]
            #graph << [anno_uri, PROV.generatedAtTime, dep_parsing_activity_time]
          end
          graph
        end

        def nif_pos(token, index, reify=false, tagset=Pils::Tcf::PENN)
          subject = char_uri(uri_base, token.begin_index, token.end_index)
          pos = Transformer.encode_pos(token.pos)
          if reify
            if @tagger_label
              anno_uri = twopart_uri(uri_base, "Pos#{@tagger_label}#{index}")
            else
              anno_uri = twopart_uri(uri_base, "Pos#{index}")
            end
            [
              [subject, NIF.annotation, anno_uri],
              [anno_uri, NIF.oliaLink, tagset[pos]],
              [anno_uri, PROV.wasGeneratedBy, pos_tagging_activity_uri],
              [anno_uri, PROV.wasDerivedFrom, subject],
              [anno_uri, PROV.generatedAtTime, pos_tagging_activity_time]
            ]
          else
            [[subject, NIF.oliaLink, tagset[pos]]]
          end
        end

        def nif_lemma(token, index, reify=false)
          subject = char_uri(uri_base, token.begin_index, token.end_index)
          lemma = token.lemma
          if reify
            anno_uri = twopart_uri(uri_base, "Lemma#{index}")
            [
              [subject, NIF.annotation, anno_uri],
              [anno_uri, NIF.lemma, RDF::Literal.new(lemma, datatype: RDF::XSD.string)],
              [anno_uri, PROV.wasGeneratedBy, pos_tagging_activity_uri],
              [anno_uri, PROV.wasDerivedFrom, subject],
              [anno_uri, PROV.generatedAtTime, pos_tagging_activity_time]
            ]
          else
            [[subject, NIF.lemma, RDF::Literal.new(lemma, datatype: RDF::XSD.string)]]
          end
        end


      end

    end
  end
end
