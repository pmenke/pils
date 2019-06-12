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

# This is a language config file.

module Pils
  module De
    module Skeleton


      CAS = %w(nom gen dat acc) #[:nom, :gen, :dat, :acc]
      NUM = %w(sg pl) #[:sg, :pl]
      GEN = %w(m f n) # [:m, :f, :n]
      PER = %w(1 2 3) # [:er, :zw, :dr]
      MOD = %w(imp ind) # [:imp, :fin, :inf]
      TMP = %w(pres)
      VAL = %w(t0 tdir tind tdirind)

      def self.add_german_verb(lex, grundform, zweitform, praetform, partform, valence, semantic_component)
        lex.add_wordform Wordform.new(normalize_forms("#{grundform}e"),   "V_fin_sg_1_pres_#{valence}".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{zweitform}st"),  "V_fin_sg_2_pres_#{valence}".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{zweitform}t"),   "V_fin_sg_3_pres_#{valence}".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{grundform}en"),  "V_fin_pl_1_pres_#{valence}".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{grundform}t"),   "V_fin_pl_2_pres_#{valence}".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{grundform}en"),  "V_fin_pl_3_pres_#{valence}".to_sym,   {}, semantic_component.clone )
      end

      def self.add_irregular_verb(lex, tempus, valence, semantic_component, *forms)
        lex.add_wordform Wordform.new(normalize_forms(forms[0]), "V_fin_sg_1_#{tempus}_#{valence}".to_sym, {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms(forms[1]), "V_fin_sg_2_#{tempus}_#{valence}".to_sym, {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms(forms[2]), "V_fin_sg_3_#{tempus}_#{valence}".to_sym, {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms(forms[3]), "V_fin_pl_1_#{tempus}_#{valence}".to_sym, {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms(forms[4]), "V_fin_pl_2_#{tempus}_#{valence}".to_sym, {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms(forms[5]), "V_fin_pl_3_#{tempus}_#{valence}".to_sym, {}, semantic_component.clone )
      end

      def self.add_german_noun(lex, semantic_component, gender, forms)
        lex.add_wordform(Wordform.new(forms[0], "N_nom_sg_#{gender}_3".to_sym, {}, semantic_component.clone.merge({number: :singular}) ))
        lex.add_wordform(Wordform.new(forms[1], "N_gen_sg_#{gender}_3".to_sym, {}, semantic_component.clone.merge({number: :singular})  ))
        lex.add_wordform(Wordform.new(forms[2], "N_dat_sg_#{gender}_3".to_sym, {}, semantic_component.clone.merge({number: :singular})  ))
        lex.add_wordform(Wordform.new(forms[3], "N_acc_sg_#{gender}_3".to_sym, {}, semantic_component.clone.merge({number: :singular})  ))
        lex.add_wordform(Wordform.new(forms[4], "N_nom_pl_#{gender}_3".to_sym, {}, semantic_component.clone.merge({number: :plural})  ))
        lex.add_wordform(Wordform.new(forms[5], "N_gen_pl_#{gender}_3".to_sym, {}, semantic_component.clone.merge({number: :plural}) ))
        lex.add_wordform(Wordform.new(forms[6], "N_dat_pl_#{gender}_3".to_sym, {}, semantic_component.clone.merge({number: :plural}) ))
        lex.add_wordform(Wordform.new(forms[7], "N_acc_pl_#{gender}_3".to_sym, {}, semantic_component.clone.merge({number: :plural}) ))
      end

      def self.normalize_forms(form)
        form = form.gsub(/ee/, 'e')
        form
      end

      def self.define_grammar
        include Pils::Parsing
        g = Grammar.new()
        sentence = Cat.new(:S)
        g.starting_cats = [ sentence ]

        # Define rules for S -> NP VP
        # for each combination of (NUM, PER, TMP, GEN)
        NUM.each do |num|
          PER.each do |per|
            TMP.each do |tmp|
              # define a rule VP_fin -> V_fin
              r = Rule.new(Cat.new("VP_fin_#{num}_#{per}_#{tmp}".to_sym, :agens), [ Cat.new("V_fin_#{num}_#{per}_#{tmp}_t0".to_sym, :predicate)], {})
              g.rules << r
              GEN.each do |gen|
                r = Rule.new(Cat.new(:S), [ Cat.new("NP_nom_#{num}_#{gen}_#{per}".to_sym, :agens), Cat.new("VP_fin_#{num}_#{per}_#{tmp}".to_sym, :predicate)], {})
                g.rules << r

                # define a rule VP_fin -> V_fin NP_!AKK (both NUM, all PER, all GEN)
                # independent PERSON!
                NUM.each do |num2|
                  r = Rule.new(Cat.new("VP_fin_#{num}_#{per}_#{tmp}".to_sym, :agens),
                    [ Cat.new("V_fin_#{num}_#{per}_#{tmp}_tdir".to_sym, :predicate),
                      Cat.new("NP_acc_#{num2}_#{gen}_#{per}".to_sym, :dirobj)], {})
                  g.rules << r
                end
              end
            end
          end
        end

        # NP rules
        # NP -> DET NPX
        # NPX -> ADJA NPX
        # NPX -> N
        #  for each combination of (CAS, NUM, GEN)
        CAS.each do |cas|
          NUM.each do |num|
            GEN.each do |gen|
              #PER.each do |per|
                r = Rule.new(Cat.new("NP_#{cas}_#{num}_#{gen}_3".to_sym), [ Cat.new("DETD_#{cas}_#{num}_#{gen}_3".to_sym), Cat.new("NPX_#{cas}_#{num}_#{gen}_3".to_sym)], {})
                g.rules << r
                r = Rule.new(Cat.new("NP_#{cas}_#{num}_#{gen}_3".to_sym), [ Cat.new("INTP_#{cas}_#{num}_#{gen}_3".to_sym), Cat.new("NPX_#{cas}_#{num}_#{gen}_3".to_sym)], {})
                g.rules << r
                r = Rule.new(Cat.new("NPX_#{cas}_#{num}_#{gen}_3".to_sym), [ Cat.new("N_#{cas}_#{num}_#{gen}_3".to_sym)], {})
                g.rules << r
                r = Rule.new(Cat.new("NPX_#{cas}_#{num}_#{gen}_3".to_sym), [ Cat.new("ADJA_#{cas}_#{num}_#{gen}_3".to_sym), Cat.new("NPX_#{cas}_#{num}_#{gen}_3".to_sym)], {})
                g.rules << r
              #end
            end
          end
        end

        # NP rules, plural: nouns only
        CAS.each do |cas|
          GEN.each do |gen|
            r = Rule.new(Cat.new("NP_#{cas}_pl_#{gen}_3".to_sym), [ Cat.new("NPX_#{cas}_pl_#{gen}_3".to_sym)], {det: :no})
            g.rules << r
          end
        end

        return g
      end


      def self.define_lexicon
        lexicon = Lexicon.new()

        # Definite Artikel
        definite_articles = %w(der des dem den die der den die die der der die die der den die das des dem das die der den die)
        id = 0
        GEN.each do |gen|
          NUM.each do |num|
            CAS.each do |cas|
              form = definite_articles[id]
              id = id + 1
              semantics = {det: :yes}
              semantics[:number] = :singular if num=='sg'
              semantics[:number] = :plural if num=='pl'
              lexicon.add_wordform Wordform.new(form, "DETD_#{cas}_#{num}_#{gen}_3".to_sym, {}, semantics)
            end
          end
        end

        indefinite_articles = %w(ein eines einem einen eine einer einer eine ein eines einem ein)
        id = 0
        GEN.each do |gen|
          CAS.each do |cas|
            form = indefinite_articles[id]
            id = id + 1
            lexicon.add_wordform Wordform.new(form, "DETD_#{cas}_sg_#{gen}_3".to_sym, {}, {det: :yes})
          end
        end

        interrog =  %w(welcher welches welchem welchen welche welcher welchen welche)
        interrog << %w(welche welcher welcher welche welche welcher welchen welche)
        interrog << %w(welches welchen welchem welches welche welcher welchen welche)
        interrog.flatten!
        id=0
        GEN.each do |gen|
          NUM.each do |num|
            CAS.each do |cas|
              form = interrog[id]
              id = id + 1
              semantics = {det: :yes, pronoun_type: :interrogative}
              semantics[:number] = :singular if num=='sg'
              semantics[:number] = :plural if num=='pl'
              lexicon.add_wordform Wordform.new(form, "INTP_#{cas}_#{num}_#{gen}_3".to_sym, {}, semantics)
            end
          end
        end
        return lexicon
      end
    end
  end
end
