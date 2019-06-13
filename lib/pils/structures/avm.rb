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
  module Structures

    # This class models attribute value structures, based on hashes.
    class Avm < Hash

      def initialize(old_struct={})
        if old_struct
          old_struct.each do |k,v|
            self[k] = v
          end
        end
      end

      # retrieves the value stored under the given key.
      # @param [Object] key the key under which to look
      # @return [Object,nil] the found value or nil if no value was
      #  stored under the given key
      def get(key)
        if self.has_key?(key)
          return self[key]
        elsif self.has_key?(key.to_sym)
          return self[key.to_sym]
        elsif self.has_key?(key.to_s)
          return self[key.to_s]
        end
      end
      
      
      def <(other)
        self.keys.each do |k|
          if other.has_key?(k)
            return false if self.get(k) != other.get(k)
          else
            return false
          end
        end
        return true
      end

      # unifies (merges) this AVM with another one
      # @param [Pils::Structures::Avm] other the other AVM to unify
      # @return [Pils::Structures::Avm,nil] the result of the
      #  unification or `nil` if there were conflicts
      def +(other)
        new_hash = {}
        self.keys.each do |key|
          new_hash[key]=self[key]
        end
        other.keys.each do |key|
          return nil if new_hash.has_key?(key) && new_hash[key] != other[key]
          new_hash[key]=other[key]
        end
        return Avm.new(new_hash)
      end

      def fits_to_describe(other)
        self.keys.each do |k|
          sym_key = k.to_sym
          # Pils::log "   key: %s" % k
          Pils::log "     a: %s" % self[k]
          if other.has_key?(k.to_sym) || other.has_key?(k.to_s)
            Pils::log "     b: %s" % other[k]
            if self[k].kind_of?(Hash) && other[k].kind_of?(Hash)
              return false if !(self[k].fits_to_describe(other[k]))
            else
              return false if self[k] != other[k]
            end
          else
            return false
          end
        end
        return true
      end

    end
  end
end
