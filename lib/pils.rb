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

require "pils/version"
require 'pils/structures'
require 'pils/parsing'
require 'pils/de'
require 'pils/tcf'


# The pils module is the overall container for all code snippets,
# classes and methods that deal with linguistic modelling.
module Pils
  # Your code goes here...

  # The output stream used for pils-internal writing.
  def self.out
    @out
  end

  def self.out=(new_out)
    @out=new_out
  end

  def self.err
    @err
  end

  def self.err=(new_err)
    @err=new_err
  end

  def self.log(msg, stream=:err)
    if stream==:err && !self.err.nil?
      self.err << msg
      self.err << "\n"
    end
    if stream==:out && !self.out.nil?
      self.out << msg
      self.out << "\n"
    end
  end

  self.out=STDOUT#nil#STDOUT
  self.err=nil#STDERR

end
