# This file is part of FetaSuite.
#
#     FetaSuite is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as
#     published by the Free Software Foundation, either version 3 of
#     the License, or (at your option) any later version.
#
#     FetaSuite is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
#
#     You should have received a copy of the
#     GNU Lesser General Public License along with FetaSuite.
#     If not, see <http://www.gnu.org/licenses/>.

# This is a language config file.

module Pils
  module De
    module Small
      
      CAS = %w(nom gen dat acc) #[:nom, :gen, :dat, :acc]
      NUM = %w(sg pl) #[:sg, :pl]
      GEN = %w(m f n) # [:m, :f, :n]
      PER = %w(1 2 3) # [:er, :zw, :dr]
      MOD = %w(imp ind) # [:imp, :fin, :inf]
      TMP = %w(pres)

      def self.add_german_verb(lex, grundform, zweitform, praetform, partform, semantic_component)
        lex.add_wordform Wordform.new(normalize_forms("#{grundform}e"),   "V_fin_sg_1_pres".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{zweitform}st"),  "V_fin_sg_2_pres".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{zweitform}t"),   "V_fin_sg_3_pres".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{grundform}en"),  "V_fin_pl_1_pres".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{grundform}t"),   "V_fin_pl_2_pres".to_sym,   {}, semantic_component.clone )
        lex.add_wordform Wordform.new(normalize_forms("#{grundform}en"),  "V_fin_pl_3_pres".to_sym,   {}, semantic_component.clone )
      end
      
      def self.add_german_noun(lex, semantic_component, gender, forms)
        lex.add_wordform(Wordform.new(forms[0], "N_nom_sg_#{gender}_3".to_sym, {}, semantic_component.clone ))
        lex.add_wordform(Wordform.new(forms[1], "N_gen_sg_#{gender}_3".to_sym, {}, semantic_component.clone ))
        lex.add_wordform(Wordform.new(forms[2], "N_dat_sg_#{gender}_3".to_sym, {}, semantic_component.clone ))
        lex.add_wordform(Wordform.new(forms[3], "N_acc_sg_#{gender}_3".to_sym, {}, semantic_component.clone ))
        lex.add_wordform(Wordform.new(forms[4], "N_nom_pl_#{gender}_3".to_sym, {}, semantic_component.clone ))
        lex.add_wordform(Wordform.new(forms[5], "N_gen_pl_#{gender}_3".to_sym, {}, semantic_component.clone ))
        lex.add_wordform(Wordform.new(forms[6], "N_dat_pl_#{gender}_3".to_sym, {}, semantic_component.clone ))
        lex.add_wordform(Wordform.new(forms[7], "N_acc_pl_#{gender}_3".to_sym, {}, semantic_component.clone ))        
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
              
        # S -> NP VP, both numerus
        NUM.each do |num|
          PER.each do |per|
            TMP.each do |tmp|
              GEN.each do |gen|
                r = Rule.new(Cat.new(:S), [ Cat.new("NP_nom_#{num}_#{gen}_#{per}".to_sym, :agens), Cat.new("VP_fin_#{num}_#{per}_#{tmp}".to_sym, :agens)], {})
                g.rules << r
              end
              r = Rule.new(Cat.new("VP_fin_#{num}_#{per}_#{tmp}".to_sym, :agens), [ Cat.new("V_fin_#{num}_#{per}_#{tmp}".to_sym, :agens)], {})
              g.rules << r
            end
          end
        end
        
        # NP rules
        CAS.each do |cas|
          NUM.each do |num|
            GEN.each do |gen|
              #PER.each do |per|
                r = Rule.new(Cat.new("NP_#{cas}_#{num}_#{gen}_3".to_sym), [ Cat.new("DETD_#{cas}_#{num}_#{gen}_3".to_sym), Cat.new("NPX_#{cas}_#{num}_#{gen}_3".to_sym)], {})
                g.rules << r
                r = Rule.new(Cat.new("NPX_#{cas}_#{num}_#{gen}_3".to_sym), [ Cat.new("N_#{cas}_#{num}_#{gen}_3".to_sym, :agens)], {})
                g.rules << r
                #r = FetaRule.new(FetaCat.new("NPX_#{cas}_#{num}_#{gen}_#{per}".to_sym), [ FetaCat.new("ADJA_#{cas}_#{num}_#{gen}_#{per}".to_sym), FetaCat.new("NPX_#{cas}_#{num}_#{gen}_#{per}".to_sym)], {})
                #g.rules << r
                #end
            end
          end
        end 
        
        return g
      end
      
      def self.define_lexicon
        lexicon = Lexicon.new()
        
        # Definite Artikel
        
        defin = %w(der des dem den die der den die die der der die die der den die das des dem das die der den die)

        id = 0
        GEN.each do |gen|
          NUM.each do |num|
            CAS.each do |cas|
              form = defin[id]
              id = id + 1
              # DETD_nom_sg_f_3
              lexicon.add_wordform Wordform.new(form, "DETD_#{cas}_#{num}_#{gen}_3".to_sym, {}, {det: :yes})
            end
          end
        end
        
        # some nouns
        
        # add_german_noun(lexicon, :car, :n, %w(Auto Autos Auto Auto Autos Autos Autos Autos))
        add_german_noun(lexicon, {species: :dog}, :m, %w(Hund Hundes Hund Hund Hunde Hunde Hunden Hunde))
        add_german_noun(lexicon, {species: :cat}, :f, %w(Katze Katze Katze Katze Katzen Katzen Katzen Katzen))
        add_german_noun(lexicon, {species: :pig}, :n, %w(Schwein Schweins Schwein Schwein Schweine Schweine Schweinen Schweine))
        add_german_verb(lexicon, "fauch", "fauch", "faucht", "faucht", {sound: :hiss} )
        add_german_verb(lexicon, "miau",  "miau",  "miaut",  "miaut",  {sound: :meow} )
        add_german_verb(lexicon, "bell",  "bell",  "bellt",  "bellt",  {sound: :bark} )
        add_german_verb(lexicon, "grunz", "grunz", "grunzt", "grunzt", {sound: :oink} )
        
        return lexicon
      end
    end
  end
end