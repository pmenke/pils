namespace :minitest do
  
  desc "Test small course grammar"
  task :parse do 
    @grammar = Pils::De::Small.define_grammar
    @lexicon = Pils::De::Small.define_lexicon
    # @grammar.rules.each do |rule|
    #   Pils::log rule.display
    # end
    
    @parser = Pils::Parsing::Parser.new()
    @parser.grammar = @grammar
    @parser.lexicon = @lexicon
    
    @parser.lexicon.describe
    
    @parser.init(%w(die Schweine grunzen))
    @result = @parser.parse!(70)
    Pils::log @result[:syntax].display
    Pils::log @result[:semantics]
    
  end
end