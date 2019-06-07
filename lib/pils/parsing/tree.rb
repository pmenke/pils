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
    class Tree
      attr_accessor :children
      attr_accessor :parent
      attr_accessor :obj
      attr_accessor :wordform

      def initialize(new_obj, new_parent=nil, new_children=[])
        @obj = new_obj
        @parent = new_parent
        @children = new_children
        @wordform = nil
      end

      def clone
        new_tree = Tree.new(@obj, @parent, [])
        self.children.each do |c|
          new_tree.children << c.clone
        end
        new_tree
      end

      def set_parent(new_parent)
        @parent = new_parent
      end

      def set_children(new_children, recurse=false)
        @children = new_children
        if recurse
          @children.each do |c|
            c.set_parent(self)
          end
        end
      end


      def ancestors
        return [] if @parent.nil?
        # Pils::log @parent.class.name
        tst = @parent.ancestors
        return [@parent, tst].flatten
      end

      def ancestors_from_root
        ancestors.reverse
      end

      def child_count
        @children.count
      end

      def leaf?
        self.child_count == 0
      end

      def leaf_count
        return 1 if self.leaf?
        @children.collect{|c| c.leaf_count}.inject(0){|sum,x| sum + x }
      end

      def leaves
        return [self] if self.leaf?
        result = []
        @children.each do |child|
          if child.leaf?
            result << child
          else
            child.leaves.each do |l|
              result << l
            end
          end
        end
        result.uniq.flatten
      end

      def leaf_at(n)
        self.leaves[n]
      end
      
      def set_wordform_at(n, value)
        set_wordform_for_nth_leaf(n, 0, value)
      end
      
      def set_wordform_for_nth_leaf(n, counter, value)
        # Pils::log "\nLooking for >#{value}< in #{obj.to_s}"
        @children.each do |child|
          # Pils::log "  Node: #{child.obj.to_s}, leaf? #{child.leaf?}, n: #{n.to_s}, counter: #{counter.to_s}"
          if child.leaf?
            # Pils::log "--FOUND A LEAF: #{child.wordform}"
            if counter==n
              # Pils::log "Setting word form >#{value}<"
              child.wordform = value
              counter = counter + 1
              # return true
            end
            # Pils::log "Not setting word form"
            counter = counter + 1
          else
            # Pils::log "no leaf: #{child.obj.to_s}"
            #counter
            counter = child.set_wordform_for_nth_leaf(n, counter, value)#.children.each do |l|
            # counter=resulting_counter if resulting_counter>counter
            # return true if counter===true
            #  counter = l.set_wordform_for_nth_leaf(n-counter, value)
            #end
          end
        end
        return counter
      end
        
      def display
        if self.leaf?
          if wordform
            return "[.%s %s ]" % [obj.to_s, wordform]
          else
            return obj.to_s
          end
        else
          # return "%s[ %s ]" % [@obj.to_s, children.collect{|c| c.display}.join(' ')]
          return "[.%s %s ]" % [@obj.to_s, children.collect{|c| c.display}.join(' ')]
        end

      end
      
      def to_s
        return display
      end
    end
  end
end