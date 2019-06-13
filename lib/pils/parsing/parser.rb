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
    class Parser

      attr_accessor :tokens

      attr_accessor :syntax
      attr_accessor :semantics

      attr_accessor :syntax_position
      attr_accessor :token_position

      attr_accessor :stack

      attr_accessor :grammar
      attr_accessor :lexicon


      def tokenize(str)
        str.split(/\s+/)
      end

      def init(ptokens)
        # set start states
        @tokens = ptokens
        @token_position = 0
        # syntactic state
        #   set state to first start symbol, stack to remaining start symbols

        @syntax = Tree.new(@grammar.starting_cats.first, nil) # Pils::Parsing::
        @syntax_position = 0

        # semantic state
        @semantics = {}
        # stack
        @stack = []

        Pils::log @tokens
      end

      def word_substitutions
        # current category in syntax
        # current word
        # is there a lexicon entry for form, cat, gram?

        @lexicon_matches = @lexicon.get({
                                            form: @tokens[@token_position],
                                            cat: @head_cat.obj.cat,
                                            grammar: @head_cat.obj.grammar
                                        })
        # Pils::log "Lexical matches: %i" % @lexicon_matches.count
        # Pils::log "Lexical matches:\n - %s" % @lexicon_matches.collect{|m| m.display }.join("\n - ")
        @lexicon_matches
      end

      def expand_cat
        rules = @grammar.expand(@head_cat.obj)
        # Pils::log "Erwartet wird: %s" % @head_cat.obj.display
        # exit(0) if @head_cat.obj.display == "NP_nom_sg_m_3"
        # Pils::log "    Ahnen       %s" % @head_cat.ancestors_from_root.collect{|a| a.obj }.join('>')
        # Pils::log "    Descriptor  %s" % @head_path.join('>')


        # Pils::log "Anwendbare Regeln: %i" %  rules.count
        # rules.each_with_index do |rule,ind|
        #   Pils::log "  %3i - %s ==> %s"% [ ind, rule.left.display, rule.right.collect{|r| r.display}.join(' ')]
        # end

        first_rule, *rules_tail = *rules

        if rules_tail.count>0
          rules_tail.each do |rule|
            # create a new alternative state.
            new_syntax = @syntax.clone
            new_semantics = @semantics.clone
            # apply rule!
            new_child_list = []
            new_head_cat = new_syntax.leaf_at(@syntax_position)
            rule.right.each do |x|
              new_child_list << Tree.new(x)
            end
            new_head_cat.set_children(new_child_list, true)
            new_state = [new_syntax, new_semantics, @syntax_position, @token_position]
            @stack << new_state
          end
        end
        # expand current tree
        # Pils::log @syntax.display
        new_child_list = []
        first_rule.right.each do |x|
          new_child_list << Tree.new(x)
        end
        @head_cat.set_children(new_child_list, true)
        # Pils::log @syntax.display
        sync

      end

      def sync
        @head_cat = @syntax.leaf_at(@syntax_position)
        if @head_cat
          @head_path = @head_cat.ancestors_from_root.collect{|a| a.obj.descriptor}.reject{|d| d.nil?}
        end
        # Pils::log @head_cat.obj.display

      end

      def parse!(max_iterations=50)
        @result = true
        @iter = 0
        puts @token_position
        puts @tokens
        while (@result===true || @result===false) && (@tokens.size-@token_position>=1) && @iter<max_iterations
          @result = parse
          @iter = @iter + 1
          # Pils::log ''
          # Pils::log '+---+'
          # Pils::log '+%3i+' % @iter
          # Pils::log '+---+'

        end
        # Pils::log Pils::log '+  ---  +'
        # Pils::log Pils::log @result
        # Pils::log Pils::log '+  ---  +'
        # Pils::log @result.class.name
        if @result.kind_of?(Hash)
          @tokens.each_with_index do |token,n|
            @result[:syntax].set_wordform_at(n, token)
          end
        end
        return @result
      end

      def parse
        # categorial replacement?
        # gibt es für das Blatt an aktueller Position eine Expansion?
        # Pils::log '*' * 48
        # Pils::log display_tokens
        # Pils::log '*' * 48
        # Pils::log @syntax.display
        # Pils::log '*' * 48
        # Pils::log @head_cat.obj if @head_cat
        # Pils::log '*' * 48
        # Pils::log @syntax.leaf_count
        # Pils::log @syntax_position
        # Pils::log @syntax.leaf_at(@syntax_position-1).obj unless @syntax_position==0
        # Pils::log '*' * 48
        sync
        # Pils::log @syntax.leaf_count
        # Pils::log @syntax.leaves
        # Pils::log @syntax.leaves.count
        # Pils::log @syntax.leaves.reject{|l| l.obj.nil? }
        # Pils::log @syntax.leaves.reject{|l| l.obj.nil? }.count

        # Pils::log @syntax_position
        (0..(@syntax.leaf_count-1)).each do |u|
          current_leaf = @syntax.leaf_at(u)
          # Pils::log "  %2i %s" % [u, current_leaf]
          # Pils::log "      %s" % [u, current_leaf.obj]
        end
        # stack:
        # Pils::log "STACK:"
        #@stack.each do |n|
        #  Pils::log "    -- %2i %2i %s" % [n[2], n[3], n[0].display]
        #end
        # Pils::log @syntax.leaf_at(@syntax_position-1).obj unless @syntax_position==0
        # Pils::log '*' * 48

        # Pils::log "# A. CATEGORY EXPANSION"
        # Pils::log @head_cat
        # gib fehler aus, wenn nach sync keine head cat da ist
        if @head_cat.nil? && !(@token_position > (@tokens.count-1))
          retrieve_from_stack
          return false
        end

        # Pils::log "     looking for expansions for #{@head_cat.obj}" if @head_cat

        # Jetzt: Wenn es fuer diese Kategorie eine Ableitung gibt, fuehre diese durch.
        success = false
        if @head_cat
          # Pils::log @grammar.expandible?(@head_cat.obj)
          if @grammar.expandible?(@head_cat.obj)
            # get first result.
            # extend tree.
            # set new tree as syntax.
            expand_cat
            success = true
          end
          return true if success
          # Pils::log  Pils::log "KEINE CATEXPANSION MOEGLICH. Daher jetzt Wortabgleich."
        end
        # Wortabgleich!
        # Passt das aktuelle Wort auf das momentane Token?
        # Wenn ja: Setze beide Positionen eins weiter.
        #   und trage die Semantik in die Semantikliste ein.
        # Pils::log "# B. WORD EXPANSION"
        # Pils::log "     looking for a word for #{@head_cat.obj}"
        subs = word_substitutions
        if subs.count > 0
          # wir haben Wortersetzungen! Nimm die erste. Erzeuge einen
          # neuen Zustand im aktuellen System.
          # Setze die restlichen in die Warteliste.
          head, *tail = *subs
          if tail
            tail.each do |t|
              new_syntax = @syntax.clone
              new_semantics = @semantics.clone
              new_state = [new_syntax, new_semantics, @syntax_position, @token_position]
              @stack << new_state
            end
            # Pils::log "Stack: %i" % @stack.size
            # @stack.each do |n|
            #   Pils::log "    -- %2i %2i %s" % [n[2], n[3], n[0].display]
            # end
          end
          if head
            # obtain semantics for word form
            # get path descriptor from tree
            # Pils::log "    --SEM- %s %s" % [head.form, head.semantics ]
            semobj = @semantics
            @head_path.each do |p|
              semobj[p] = {} unless semobj.has_key?(p)
              semobj = semobj[p]
            end

            head_path_descriptor = @head_path.collect{|h| "[:#{h}]"}.join('')
            # Pils::log "HP : %s" % @head_path.to_s
            # Pils::log "HPD: %s" % head_path_descriptor
            # Pils::log @head_cat.ancestors.collect{|a| a.display}
            # Pils::log @head_cat.ancestors_from_root.collect{|a| a.display}

            head.semantics.keys.each do |key|
              # Pils::log "      @semantics#{head_path_descriptor}[key] = head.semantics[key]"
              instance_eval("@semantics#{head_path_descriptor}[key] = head.semantics[key]")
              # semobj[key] = head[key]
            end


            @token_position = @token_position + 1
            @syntax_position = @syntax_position + 1
            sync
            # TODO: Store semantics
          end
          success = true
        end
        # Pils::log "     now looking at #{@head_cat ? @head_cat.obj : 'END'}"
        # Pils::log "     token pos %i / %i " % [@token_position, (@tokens.count-1)]
        # check if end is nigh
        if @head_cat.nil? && @token_position > (@tokens.count-1)
          # Pils::log "END IS NIGH!"
          # Pils::log @syntax.display
          # Pils::log @semantics # JSON.pretty_generate(@semantics)
          return {syntax: @syntax.clone, semantics: @semantics.clone}
          # exit(0)
        end
        return true if success

        retrieve_from_stack

        # Pils::log @syntax.display
        # Pils::log "Now expecting: %s" % @syntax.leaf_at(@syntax_position).obj.to_s

        # Pils::log @stack.size
        return success
      end

      # gets the next possible state from stack, discards the current one.
      def retrieve_from_stack
        # Pils::log "We retrieve the next object from the stack. %i" % @stack.size
        return nil if @stack.nil? || @stack.empty?
        new_state, *state_rest = @stack
        @stack = state_rest
        @syntax = new_state[0]
        @semantics = new_state[1]
        @syntax_position = new_state[2]
        @token_position = new_state[3]
        sync
        # Pils::log "   becomes %i" % @stack.size
        # @stack.each do |n|
        #   Pils::log "    -- %2i %2i %s" % [n[2], n[3], n[0].display]
        # end
      end


      def display_tokens
        r = @tokens.slice(0,@token_position)
        s = @tokens - r
        t = [r, "*", s].flatten
        t.join(" ")
      end
    end
  end
end
